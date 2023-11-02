{-# LANGUAGE GADTs #-}

module TypeChecker where

{-- Symbol Table

First we construct a symbol table for:
a. Formal Parameters and Variable names
b. Method Name
c. Struct/Union/Enum

We will represent each symbol name as a String for now (TODO: Use Data.Text for strings)

A symbol will point to a binding which is the type.

Parameter Name -> Type
Variable Name -> Type
Method Name -> [Parameter] ResultType [Variable]
Struct/Union -> [Variables]

-}

import Data.Map (Map)
import qualified Data.Map as M
import Syntax

-- data Env where
--   Global ::
{--

Global (Holds External Declarations)
  -> Functions
  -> Global Variables

Functions
  -> Parameters
  -> Return Type
  -> Local Variables

Variables
  -> Type

--}
type Type = CTypeSpecifier

data Binding where
  -- Variable Type
  VarBinding :: Type -> Binding
  -- Return Type -> Local Env (Vars and Params)
  FuncBinding :: Env -> Type -> Binding
  -- Struct Type -> Struct Env
  StructBinding :: Type -> Env -> Binding

type Env = Map String Binding

data TypeError where
  Undefined :: String -> TypeError

inferCExpression :: Env -> CExpression -> Either TypeError Type
inferCExpression _ (CConstExpr (IntConst _)) = Right CIntType
inferCExpression _ (CConstExpr (DblConst _)) = Right CFloatType
inferCExpression _ (CConstExpr (CharConst _)) = Right CCharType

symbolCDeclaration :: Env -> CDeclaration -> Either TypeError ()
symbolCDeclaration e (CDeclaration specs [(Declarator (CIdentDecl ident Nothing))] Nothing) = undefined

-- infer :: Global -> a -> Either TypeError Type
-- infer genv ctu = undefined

-- check :: Global -> a -> Type -> Either TypeError ()
-- check genv ast typ = undefined

-- typeCheck :: Global -> CTranslationUnit -> Either TypeError ()
-- typeCheck _ (CTranslationUnit []) = Right ()
-- typeCheck env (CTranslationUnit xs) = typeCheckExtDecls env xs

-- typeCheckExtDecls :: Global -> [CExternalDeclaration] -> Either TypeError ()
-- typeCheckExtDecls _ [] = Right ()
-- typeCheckExtDecls env xs = undefined

-- inferCExternalDeclaration :: Global -> CExternalDeclaration -> Either TypeError ()
-- inferCExternalDeclaration env (CFuncDefExt funcDef) = inferFuncDef env funcDef >> return ()

-- inferFuncDef :: Global -> CFunctionDef -> Either TypeError Type
-- inferFuncDef env funcDef = undefined