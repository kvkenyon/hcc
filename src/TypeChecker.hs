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

import Control.Monad.Loops (untilM)
import Control.Monad.State
import Data.Functor.Identity (Identity)
import Data.Map qualified as M
import EitherT (EitherT (..), throwE)
import Lexer (Range)
import Lexer qualified as L
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
  let qual = getQualifiers decl_specs
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
getTypes :: [CDeclarationSpecifier Range] -> [CTypeSpecifier Range]
getTypes [] = []
getTypes ((CTypeSpec _ type_spec) : decl_specs) = type_spec : getTypes decl_specs
getTypes (_ : xs) = getTypes xs

getQualifiers :: [CDeclarationSpecifier Range] -> [CTypeQualifier Range]
getQualifiers [] = []
getQualifiers ((CTypeQual _ type_qual) : decl_specs) = type_qual : getQualifiers decl_specs
getQualifiers (_ : xs) = getQualifiers xs

getStorage :: [CDeclarationSpecifier Range] -> [CStorageClassSpecifier Range]
getStorage [] = []
getStorage ((CStorageSpec _ strg) : decl_specs) = strg : getStorage decl_specs
getStorage (_ : xs) = getStorage xs

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

type Stack = [String]

pop :: State Stack String
pop = state $ \(x : xs) -> (x, xs)

push :: String -> State Stack ()
push x = state $ \xs -> ((), x : xs)

describeDecl :: CDeclaration L.Range -> State Stack String
describeDecl (CDeclaration _ decl_specs inits) = do
  let declstr = map show decl_specs
  forM_ declstr push
  x <- mapM describeInitDecl inits
  return $ concat x

describeInitDecl :: CInitDeclarator L.Range -> State Stack String
describeInitDecl (CInitDeclarator _ decl _) = describeDeclarator decl

describeDeclarator :: CDeclarator L.Range -> State Stack String
describeDeclarator (PtrDeclarator _ ptr dd) = do
  describePtr ptr
  describeDirectDecl dd
describeDeclarator (Declarator _ dd) = undefined
describeDeclarator (StructDecl _ decl expr) = undefined

describePtr :: CPointer L.Range -> State Stack ()
describePtr (CPointer _ _ (Just ptr)) = do
  push "*"
  describePtr ptr
describePtr (CPointer _ _ Nothing) = push "*"

describeDirectDecl :: CDirectDeclarator a -> State Stack String
describeDirectDecl (CIdentDecl _ (CId _ ident) (Just typeMod)) = undefined
describeDirectDecl (CIdentDecl _ (CId _ ident) Nothing) = do
  ptrs <- popUntilLeftTerminator
  return $ ident ++ " " ++ unwords ptrs
describeDirectDecl (NestedDecl _ decl Nothing) = undefined
describeDirectDecl (NestedDecl _ decl (Just typemod)) = undefined

describeTypeMod :: CTypeModifier L.Range -> State Stack String
describeTypeMod (ArrayModifier _ _ Nothing) = return "array of "
describeTypeMod (ArrayModifier _ _ (Just type_mod)) = undefined
describeTypeMod (FuncModifier _ ids Nothing) = undefined
describeTypeMod (FuncModifier _ _ (Just params)) = undefined

-- Helpers

leftTerminators :: [String]
leftTerminators = ["CVoidType", "CCharType", "CShortType", "CIntType", "("]

popUntilLeftTerminator :: StateT Stack Identity [String]
popUntilLeftTerminator = loop id
  where
    loop f = do
      x <- pop
      if x == "*"
        then loop (f . (x :))
        else do
          push x
          return (f [])
