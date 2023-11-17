{-# HLINT ignore "Use tuple-section" #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE InstanceSigs #-}
{-# OPTIONS_GHC -Wno-noncanonical-monad-instances #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}

module TypeChecker where

{-- TypeChecker

We will traverse the AST (CTranslationUnit a) defined in Syntax.hs
and update the environment with variable/functon definitions.

We will use these definitions to determine whether refrences to variables and
functions match the declarations.

If there are type errors we will catch them and present them to the user.
-}

import Control.Monad.State
import Data.Map qualified as M
import EitherT (EitherT (..), throwE)
import Lexer (Range)
import Scope
import Syntax

{--
Type errors that we will report to the user
--}
data TypeError
  = UndefinedName String
  | InvalidType String
  | TooManyStorageClassifiers
  | Redefine
  deriving (Show)

instance Functor TypeChecker where
  fmap :: (a -> b) -> TypeChecker a -> TypeChecker b
  fmap = liftM

instance Applicative TypeChecker where
  pure :: a -> TypeChecker a
  pure = return
  (<*>) :: TypeChecker (a -> b) -> TypeChecker a -> TypeChecker b
  (<*>) = ap

newtype TypeChecker a = TC
  { runTC :: EitherT TypeError (State Scope) a
  }
  deriving (Monad, MonadState Scope)

runTypeChecker :: TypeChecker a -> Scope -> (Either TypeError a, Scope)
runTypeChecker m = runState (runEitherT (runTC m))

noop :: a -> TypeChecker a
noop x = TC $ return x

-- -- Create a shorthand type alias for the State monad
-- type ScopeState = State (Scope Range) (Either TypeError ())

-- The entrypoint for the typechecker
typecheck :: CTranslationUnit Range -> TypeChecker ()
typecheck (CTranslationUnit _ extDecls) = do
  forM_ extDecls typeCheckExtDecl

typeCheckExtDecl :: CExternalDeclaration Range -> TypeChecker ()
typeCheckExtDecl (CDeclExt _ (CDeclaration _ decl_specs inits)) = TC $ do
  let types = getTypes decl_specs
  let qual = getQualifier decl_specs
  let ids = processInitDecls inits
  let binds = map (buildVarBinding types stg qual) ids
  forM_ binds modifyVarBinding
  where
    -- Take the first stg class if there are more or nothing
    stg = case getStorage decl_specs of
      (st : _) -> Just st
      [] -> Nothing
typeCheckExtDecl (CFuncDefExt _ _) = do
  _ <- get
  return ()

{--
Adds the binding to the Scope varBindings Map if it's valid.
--}
modifyVarBinding :: VarBinding -> EitherT TypeError (State Scope) ()
modifyVarBinding vb = isBindingValid vb >> addVarToScope vb

{--
Ensure the variable was not declared in the same scope with a different definition.
Returns unit if the variable is not already declared or if the declaration is identical.
Otherwise we return TypeError Redefine
--}
isBindingValid :: VarBinding -> EitherT TypeError (State Scope) ()
isBindingValid vb = do
  scope <- get
  case M.lookup (name vb) (varBindings scope) of
    Nothing -> return ()
    Just b -> when (b /= vb) $ throwE Redefine

addVarToScope :: VarBinding -> EitherT TypeError (State Scope) ()
addVarToScope vb = do
  (Scope p c v f) <- get
  lift $ put $ Scope p c (M.insert (name vb) vb v) f
  return ()

-- Process Declaration Specifiers
getTypes :: CDeclarationSpecifier Range -> [CTypeSpecifier Range]
getTypes (CTypeSpec _ type_spec Nothing) = [type_spec]
getTypes (CTypeSpec _ type_spec (Just next_decl)) = type_spec : getTypes next_decl
getTypes _ = []

getQualifier :: CDeclarationSpecifier Range -> [CTypeQualifier Range]
getQualifier (CTypeQual _ type_qual Nothing) = [type_qual]
getQualifier (CTypeQual _ type_qual (Just next_decl)) = type_qual : getQualifier next_decl
getQualifier _ = []

getStorage :: CDeclarationSpecifier Range -> [CStorageClassSpecifier Range]
getStorage (CStorageSpec _ storage_spec Nothing) = [storage_spec]
getStorage (CStorageSpec _ storage_spec (Just next_decl)) = storage_spec : getStorage next_decl
getStorage _ = []

-- Process Initializers
-- getInitializer :: CInitDeclarator Range ->
processInitDecls :: [CInitDeclarator Range] -> [String]
processInitDecls [] = []
processInitDecls ((CInitDeclarator _ decl _) : cids) = getIdentifier decl : processInitDecls cids

getIdentifier :: CDeclarator Range -> String
getIdentifier
  ( Declarator
      _
      (CIdentDecl _ (CId _ identifier) Nothing)
    ) = show identifier

describeDecl :: CDeclaration a -> String
describeDecl (CDeclaration _ decl inits) = undefined

describeIdent :: CInitDeclarator a -> String
describeIdent (CInitDeclarator _ decl _) = undefined

describeDeclarator :: CDeclarator a -> String
describeDeclarator (PtrDeclarator _ ptr dd) = undefined
describeDeclarator (Declarator _ dd) = undefined
describeDeclarator (StructDecl _ decl expr) = undefined

describeDirectDecl :: CDirectDeclarator a -> String
describeDirectDecl (CIdentDecl _ ident (Just typeMod)) = undefined
describeDirectDecl (CIdentDecl _ (CId _ ident) Nothing) = "Declare " ++ ident ++ "as "
describeDirectDecl (NestedDecl _ decl Nothing) = undefined
describeDirectDecl (NestedDecl _ decl (Just typemod)) = undefined