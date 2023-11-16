{-# LANGUAGE GADTs #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}

{-# HLINT ignore "Use tuple-section" #-}

module TypeChecker where

{-- TypeChecker

We will traverse the AST (CTranslationUnit a) defined in Syntax.hs
and update the environment with variable/functon definitions.

We will use these definitions to determine whether refrences to variables and
functions match the declarations.

If there are type errors we will catch them and present them to the user.
-}

import Control.Monad.State
import Data.Map (Map)
import Data.Map qualified as M
import Lexer (AlexPosn (AlexPn), Range)
import Lexer qualified as L
import Syntax

-- Shorten some AST Node names def. in Syntax.hs
type Type = CTypeSpecifier

type Storage = CStorageClassSpecifier

type Qualifier = CTypeQualifier

{--
Lexical scope for the program. Each scope has a pointer to the 
parent scope. This will allow us to migrate up to the global scope to
determine if an identifier was declared somewhere else in the program. 

Child scopes are scopes one level down from the encompassing scope.

varBindings represent the variables that are bound directly to this scope
via declarations in the block

funcBindings represent functions that are bound to this scope via function
definitions. Most likely global scope will be the only scope that maintains
function bindings.

TODO: We need to add struct/union/enum/typedef bindings as well.
--}
data Scope a = Scope
  { parentScope :: Maybe (Scope a),
    childScopes :: [Scope a],
    varBindings :: Map String (VarBinding a),
    funcBindings :: Map String (FuncBinding a)
  }
  deriving (Show)

{--
A default scope that is used to represent the programs global (or file)
scope.
--}
globalScope :: Scope a
globalScope = Scope Nothing [] M.empty M.empty


{--
Creates a local scope. This could be a function block, for loop block etc.
Anywhere the program defines { <stmts>? } we must open a local scope. 
--}
localScope :: Scope a -> Scope a
localScope parent = Scope (Just parent) [] M.empty M.empty

{--
Exit the current scope by returning the parent scope. If
there is no parent scope we return Nothing. This would signify
the end of the program since we are exiting the global scope 
param:: The current Scope
return:: Maybe the parent Scope
--}
exitScope :: Scope a -> Maybe (Scope a)
exitScope (Scope parent _ _ _) = parent

{--
A function binding represents an identifier that is bound
to a function. We need to update the scope with the function binding
so we can validate function calls later in the program.And

param: funcName - refers to the identifier 
param returnType - is the expected return type of the function
param parameters - are the input parameter declarations
--}
data FuncBinding a = FuncBinding
  { funcName :: String,
    returnType :: Type a,
    parameters :: [VarBinding a]
  }
  deriving (Show)

{--
A variable binding is constructed when we encounter variable declarations
within the program. We bind the variables to their identifier in the lexical
scope varBindings map. This exposes the binding to all child scopes.
--}
data VarBinding a = VarBinding
  { name :: String,
    -- c allows multiple types such as unsigned long etc.
    dtype :: [Type a],
    -- only one or none of register, static, auto, extern
    -- Default is static in external declarations or auto in local scope
    storage :: Storage a,
    -- either const/volatile or both
    qualifier :: [Qualifier a]
  }
  deriving (Show, Eq)

{--
Type errors that we will report to the user
--}
data TypeError
  = UndefinedName String
  | InvalidType String
  | TooManyStorageClassifiers
  | Redefine
  deriving (Show)

-- Create a shorthand type alias for the State monad
type  ScopeState = State (Scope Range) (Either TypeError ())

-- The entrypoint for the typechecker
typecheck :: CTranslationUnit Range -> ScopeState 
typecheck (CTranslationUnit _ extDecls) = do
  forM_ extDecls typeCheckExtDecl
  return $ Right ()

typeCheckExtDecl :: CExternalDeclaration Range -> ScopeState 
typeCheckExtDecl (CDeclExt _ (CDeclaration _ decl_specs inits)) = do
  let types = getTypes decl_specs
  let qual = getQualifier decl_specs
  let ids = processInitDecls inits
  let binds = map (buildVarBinding types stg qual) ids
  forM_ binds modifyVarBinding
  return $ Right ()
  where
    -- Take the first stg class if there are more or nothing
    stg = case getStorage decl_specs of
      (st : _) -> Just st
      [] -> Nothing
typeCheckExtDecl (CFuncDefExt _ _) = do
  _ <- get
  return $ Right ()

{--
Adds the binding to the Scope varBindings Map if it's valid.
--}
modifyVarBinding ::  VarBinding Range -> ScopeState 
modifyVarBinding vb =  isBindingValid vb >> addVarToScope vb

{--
Ensure the variable was not declared in the same scope with a different definition.
Returns unit if the variable is not already declared or if the declaration is identical.
Otherwise we return TypeError Redefine
--}
isBindingValid :: VarBinding Range -> ScopeState 
isBindingValid vb = do
  scope <- get
  case M.lookup (name vb) (varBindings scope) of
    Nothing -> return $ Right () 
    Just b -> if b /= vb then return $ Left Redefine else return $ Right () 

addVarToScope :: VarBinding Range -> ScopeState  
addVarToScope vb = do
  (Scope p c v f) <- get
  put $ Scope p c ( M.insert (name vb) vb v) f
  return $ Right ()

buildVarBinding :: [Type Range] -> Maybe (Storage Range) -> [Qualifier Range] -> String -> VarBinding Range
buildVarBinding types (Just s) q n = VarBinding {name = n, dtype = types, storage = s, qualifier = q}
buildVarBinding types Nothing q n =
  VarBinding
    { name = n,
      dtype = types,
      storage = CStatic $ L.Range (L.AlexPn 0 0 0) (AlexPn 0 0 0),
      qualifier = q
    }

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
