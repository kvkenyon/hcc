module Compiler where

-- import Syntax (CDeclaration (CDeclaration), CExternalDeclaration (CDeclExt, CFuncDefExt), CFunctionDef (CFunctionDef), CTranslationUnit (CTranslationUnit))

-- data CompileError = Undefined

-- compile :: CTranslationUnit a -> Either CompileError String
-- compile = undefined

-- compileCTranslationUnit :: CTranslationUnit a -> String
-- compileCTranslationUnit (CTranslationUnit []) = ""
-- compileCTranslationUnit (CTranslationUnit (x : xs)) =
--   compileCExternalDeclaration x
--     ++ compileCTranslationUnit (CTranslationUnit xs)

-- compileCExternalDeclaration :: CExternalDeclaration a -> String
-- compileCExternalDeclaration (CFuncDefExt funcDef) = compileCFunctionDef funcDef
-- compileCExternalDeclaration (CDeclExt decl) = compileCDeclaration decl

-- compileCFunctionDef :: CFunctionDef a -> String
-- compileCFunctionDef (CFunctionDef declSpecs declarator decls stmt) = undefined

-- compileCDeclaration :: CDeclaration a -> String
-- compileCDeclaration (CDeclaration declSpecs declar Nothing) = undefined
-- compileCDeclaration (CDeclaration declSpecs declar (Just inits)) = undefined