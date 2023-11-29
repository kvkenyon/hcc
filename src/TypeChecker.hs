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
import Data.Functor.Identity (Identity)
import Data.List (intercalate)
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
pop = state f
  where
    f [] = ("", [])
    f (x : xs) = (x, xs)

push :: String -> State Stack ()
push x = state $ \xs -> ((), x : xs)

describeCTU :: CTranslationUnit L.Range -> State Stack String
describeCTU (CTranslationUnit _ ext_decs) = do
  es <- forM ext_decs describeExtDec
  return $ concat es

describeExtDec :: CExternalDeclaration L.Range -> State Stack String
describeExtDec (CDeclExt _ decl) = describeDecl decl
describeExtDec (CFuncDefExt _ decl) = describeFunc decl

describeFunc :: CFunctionDef L.Range -> State Stack String
describeFunc (CFunctionDef _ decl_specs declarator _ _) = do
  forM_ decl_specs describeDeclSpec
  declar <- describeDeclarator declarator
  rest <- purgeStack
  return $ declar ++ unwords rest ++ "\n"

describeDecl :: CDeclaration L.Range -> State Stack String
describeDecl (CDeclaration _ decl_specs inits) = do
  forM_ decl_specs describeDeclSpec
  x <- mapM describeInitDecl inits
  rest <- purgeStack
  return $ concat x ++ " " ++ unwords rest ++ "\n"

describeDeclSpec :: CDeclarationSpecifier L.Range -> State Stack ()
describeDeclSpec (CStorageSpec _ (CStatic _)) = push "static"
describeDeclSpec (CStorageSpec _ (CAuto _)) = push "auto"
describeDeclSpec (CStorageSpec _ (CRegister _)) = push "register"
describeDeclSpec (CStorageSpec _ (CExtern _)) = push "extern"
describeDeclSpec (CStorageSpec _ (CTypeDef _)) = push "typedef"
describeDeclSpec (CTypeSpec _ (CDoubleType _)) = push "double"
describeDeclSpec (CTypeSpec _ (CCharType _)) = push "char"
describeDeclSpec (CTypeSpec _ (CFloatType _)) = push "float"
describeDeclSpec (CTypeSpec _ (CLongType _)) = push "long"
describeDeclSpec (CTypeSpec _ (CShortType _)) = push "short"
describeDeclSpec (CTypeSpec _ (CVoidType _)) = push "void"
describeDeclSpec (CTypeSpec _ (CIntType _)) = push "int"
describeDeclSpec (CTypeSpec _ (CSignedType _)) = push "signed"
describeDeclSpec (CTypeSpec _ (CUnsignedType _)) = push "unsigned"
describeDeclSpec (CTypeSpec _ (CStructType _ _)) = push "struct"
describeDeclSpec (CTypeSpec _ (CEnumType _ _)) = push "enum"
describeDeclSpec (CTypeQual _ (CConst _)) = push "const"
describeDeclSpec (CTypeQual _ (CVolatile _)) = push "volatile"

describeTypeQual :: CTypeQualifier L.Range -> State Stack ()
describeTypeQual ((CConst _)) = push "const"
describeTypeQual ((CVolatile _)) = push "volatile"

describeInitDecl :: CInitDeclarator L.Range -> State Stack String
describeInitDecl (CInitDeclarator _ decl _) = describeDeclarator decl

describeDeclarator :: CDeclarator L.Range -> State Stack String
describeDeclarator (PtrDeclarator _ ptr dd) = do
  describePtr ptr
  describeDirectDecl dd
describeDeclarator (Declarator _ dd) = describeDirectDecl dd
describeDeclarator (StructDecl _ decl expr) = undefined

describePtr :: CPointer L.Range -> State Stack ()
describePtr (CPointer _ type_quals (Just ptr)) = do
  push "*"
  forM_ type_quals describeTypeQual
  describePtr ptr
describePtr (CPointer _ type_quals Nothing) = do
  push "*"
  forM_ type_quals describeTypeQual

describeDirectDecl :: CDirectDeclarator L.Range -> State Stack String
describeDirectDecl (CIdentDecl _ (CId _ ident) (Just typeMod)) = do
  typeModStr <- describeTypeMod typeMod
  ptrs <- popUntilLeftTerminator
  return $ ident ++ " " ++ typeModStr ++ " " ++ unwords ptrs
describeDirectDecl (CIdentDecl _ (CId _ ident) Nothing) = do
  -- process type mods right (there are none due to nothing)
  ptrs <- popUntilLeftTerminator

  return $ ident ++ " " ++ unwords ptrs
describeDirectDecl (NestedDecl _ decl Nothing) = do
  push "("
  s <- describeDeclarator decl
  ptrs <- popUntilLeftTerminator
  return $ s ++ " " ++ unwords ptrs
describeDirectDecl (NestedDecl _ decl (Just typemod)) = do
  push "("
  s <- describeDeclarator decl
  tm <- describeTypeMod typemod
  ptrs <- popUntilLeftTerminator
  return $ s ++ " " ++ tm ++ unwords ptrs

describeTypeMod :: CTypeModifier L.Range -> State Stack String
describeTypeMod (ArrayModifier _ _ Nothing) = return "array "
describeTypeMod (ArrayModifier _ _ (Just type_mod)) = do
  tm <- describeTypeMod type_mod
  return $ "array " ++ tm
describeTypeMod (FuncModifier _ [] Nothing) = return "func returning"
describeTypeMod (FuncModifier _ ids Nothing) = do
  return $ "func of idents (" ++ intercalate ", " idstrs ++ ") returning"
  where
    idstr (CId _ s) = s
    idstrs = map idstr ids
describeTypeMod (FuncModifier _ _ (Just (CParamTypeList _ params Nothing))) = do
  x <- forM params describeParam
  return $ "func of params (" ++ intercalate ", " x ++ ") returning"
describeTypeMod (FuncModifier _ _ (Just (CParamTypeList _ params (Just _)))) = do
  x <- forM params describeParam
  return $ "variadic func of params (" ++ intercalate ", " x ++ ") returning"

describeParam :: CParameter L.Range -> State Stack String
describeParam (CParameter _ decl_specs decl) = do
  forM_ decl_specs describeDeclSpec
  x <- describeDeclarator decl
  rest <- popN (length decl_specs)
  return $ x ++ unwords rest
describeParam _ = return "abstract func"

-- Helpers

popN :: Int -> StateT Stack Identity [String]
popN n = replicateM n pop

purgeStack :: StateT Stack Identity [String]
purgeStack = loop id
  where
    loop f = do
      x <- pop
      if x /= ""
        then loop (f . (x :))
        else return (f [])

popUntilLeftTerminator :: StateT Stack Identity [String]
popUntilLeftTerminator = loop id
  where
    loop f = do
      x <- pop
      if x == "*" || x == "CConst" || x == "CVolatile"
        then loop (f . (x :))
        else do
          if x == "("
            then return (f [])
            else
              ( do
                  push x
                  return (f [])
              )
