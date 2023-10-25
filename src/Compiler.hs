module Compiler where

import Syntax (CDeclaration (CDeclaration), CExternalDeclaration (CDeclExt, CFuncDefExt), CFunctionDef (CFunctionDef), CTranslationUnit (CTranslationUnit))

data CompileError = Undefined

compile :: CTranslationUnit -> Either CompileError String
compile = undefined

compileCTranslationUnit :: CTranslationUnit -> String
compileCTranslationUnit (CTranslationUnit []) = ""
compileCTranslationUnit (CTranslationUnit (x : xs)) =
  compileCExternalDeclaration x
    ++ compileCTranslationUnit (CTranslationUnit xs)

compileCExternalDeclaration :: CExternalDeclaration -> String
compileCExternalDeclaration (CFuncDefExt funcDef) = compileCFunctionDef funcDef
compileCExternalDeclaration (CDeclExt decl) = compileCDeclaration decl

compileCFunctionDef :: CFunctionDef -> String
compileCFunctionDef (CFunctionDef declSpecs declarator decls stmt) = undefined

compileCDeclaration :: CDeclaration -> String
compileCDeclaration (CDeclaration declSpecs Nothing) = undefined
compileCDeclaration (CDeclaration declSpecs (Just inits)) = undefined