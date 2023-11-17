{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TypeSynonymInstances #-}

module Scope (Scope (..), globalScope, localScope, exitScope, VarBinding (..), FuncBinding (..), buildVarBinding) where

import Data.Map (Map)
import Data.Map qualified as M
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
data Scope = Scope
  { parentScope :: Maybe Scope,
    childScopes :: [Scope],
    varBindings :: Map String VarBinding,
    funcBindings :: Map String FuncBinding
  }
  deriving (Show)

{--
A default scope that is used to represent the programs global (or file)
scope.
--}
globalScope :: Scope
globalScope = Scope Nothing [] M.empty M.empty

{--
Creates a local scope. This could be a function block, for loop block etc.
Anywhere the program defines { <stmts>? } we must open a local scope.
--}
localScope :: Scope -> Scope
localScope parent = Scope (Just parent) [] M.empty M.empty

{--
Exit the current scope by returning the parent scope. If
there is no parent scope we return Nothing. This would signify
the end of the program since we are exiting the global scope
param:: The current Scope
return:: Maybe the parent Scope
--}
exitScope :: Scope -> Maybe Scope
exitScope (Scope parent _ _ _) = parent

{--
A function binding represents an identifier that is bound
to a function. We need to update the scope with the function binding
so we can validate function calls later in the program.

param: funcName - refers to the identifier
param returnType - is the expected return type of the function
param parameters - are the input parameter declarations
--}
data FuncBinding = FuncBinding
  { funcName :: String,
    returnType :: Type L.Range,
    parameters :: [VarBinding]
  }
  deriving (Show)

{--
A variable binding is constructed when we encounter variable declarations
within the program. We bind the variables to their identifier in the lexical
scope varBindings map. This exposes the binding to all child scopes.
--}
data VarBinding = VarBinding
  { name :: String,
    -- c allows multiple types such as unsigned long etc.
    dtype :: [Type L.Range],
    -- only one or none of register, static, auto, extern
    -- Default is static in external declarations or auto in local scope
    storage :: Storage L.Range,
    -- either const/volatile or both
    qualifier :: [Qualifier L.Range]
  }
  deriving (Show, Eq)

buildVarBinding :: [Type L.Range] -> Maybe (Storage L.Range) -> [Qualifier L.Range] -> String -> VarBinding
buildVarBinding types (Just s) q n = VarBinding {name = n, dtype = types, storage = s, qualifier = q}
buildVarBinding types Nothing q n =
  VarBinding
    { name = n,
      dtype = types,
      storage = CStatic $ L.Range (L.AlexPn 0 0 0) (L.AlexPn 0 0 0),
      qualifier = q
    }
