{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}

{-# HLINT ignore "Use $>" #-}
module Parser where

import Control.Applicative
import Parsing (GenLanguageDef (commentStart, reservedNames, reservedOpNames), Parser, TokenParser, anyChar, commentEnd, commentLine, emptyDef, eof, getIdentifier, getInteger, getParens, getReserved, getReservedOp, getSymbol, getWhiteSpace, makeTokenParser, optionMaybe, try)
import Syntax
import Text.Parsec (sepBy)
import Text.Parsec.Token (comma, float, semi)

lexer :: TokenParser u
lexer =
  makeTokenParser $
    emptyDef
      { reservedNames =
          [ "True",
            "False",
            "if",
            "else",
            "while",
            "int",
            "bool",
            "return",
            "auto",
            "register",
            "static",
            "extern",
            "typedef"
          ],
        reservedOpNames = ["=", "==", "<", "+", "-", "*", "!", "&&", "||"],
        commentLine = "//",
        commentStart = "/*",
        commentEnd = "*/"
      }

parens :: Parser a -> Parser a
parens = getParens lexer

reserved, reservedOp :: String -> Parser ()
reserved = getReserved lexer
reservedOp = getReservedOp lexer

symbol :: String -> Parser String
symbol = getSymbol lexer

ident :: Parser String
ident = getIdentifier lexer

integer :: Parser Integer
integer = getInteger lexer

whiteSpace :: Parser ()
whiteSpace = getWhiteSpace lexer

parseCExternalDeclaration :: Parser CExternalDeclaration
parseCExternalDeclaration = try parseCFunctionDef <|> CDeclExt <$> parseCDeclaration

parseCFunctionDef :: Parser CExternalDeclaration
parseCFunctionDef = CFuncDefExt <$> cFuncDef
  where
    cFuncDef =
      CFunctionDef
        <$> parseCDeclarationSpecifiers
        <*> parseCDeclarator
        <*> (symbol "{" *> parseCDeclarations)
        <*> parseCStatement
        <* symbol "}"

parseCStatement :: Parser CStatement
parseCStatement = CJmpStmt <$> parseReturn

parseReturn :: Parser CJmpStatement
parseReturn = do
  whiteSpace
  reserved "return"
  whiteSpace
  i <- optionMaybe integer
  whiteSpace
  _ <- symbol ";"
  whiteSpace
  return $
    CReturn
      ( case i of
          Just x -> Just $ CLiteral x
          _ -> Nothing
      )

parseCDeclarations :: Parser [CDeclaration]
parseCDeclarations = parseCDeclaration `sepBy` whiteSpace

parseCDeclarator :: Parser CDeclarator
parseCDeclarator = do
  ptr <- optionMaybe parseCPointer
  CDeclRoot ptr <$> parseDirectDecl

parseDirectDecl :: Parser CDeclarator
parseDirectDecl = try parseDirectDeclaratorParam <|> parseDirectDeclaratorIdent

parseDirectDeclaratorIdent :: Parser CDeclarator
parseDirectDeclaratorIdent = IdDecl <$> ident

parseDirectDeclaratorParam :: Parser CDeclarator
parseDirectDeclaratorParam = do
  iden <- parseDirectDeclaratorIdent
  params <- parens (parseCParameter `sepBy` symbol ",")
  return $ ParameterDecl iden params

parseCParameter :: Parser CParameter
parseCParameter = CParameter <$> parseCDeclarationSpecifiers <*> parseCDeclarator

parseCPointer :: Parser CPointer
parseCPointer = do
  _ <- symbol "*"
  tyQual <- optionMaybe (parseTypeQualifier `sepBy` whiteSpace)
  CPointer tyQual <$> optionMaybe parseCPointer

parseCDeclarationSpecifiers :: Parser [CDeclarationSpecifier]
parseCDeclarationSpecifiers = (parseStorageDeclSpec <|> parseTypeDeclSpec <|> parseTypeQualDeclSpec) `sepBy` whiteSpace

parseTypeQualDeclSpec :: Parser CDeclarationSpecifier
parseTypeQualDeclSpec = do
  typeQual <- parseTypeQualifier
  declSpec <- optionMaybe parseCDeclarationSpecifiers
  return $ CTypeQual typeQual declSpec

parseTypeDeclSpec :: Parser CDeclarationSpecifier
parseTypeDeclSpec = do
  typeSpec <- parseTypeSpecifier
  declSpec <- optionMaybe parseCDeclarationSpecifiers
  return $ CTypeSpec typeSpec declSpec

parseStorageDeclSpec :: Parser CDeclarationSpecifier
parseStorageDeclSpec = do
  stgClass <- parseStorageClassSpecifier
  declSpec <- optionMaybe parseCDeclarationSpecifiers
  return $ CStorageSpec stgClass declSpec

parseStorageClassSpecifier :: Parser CStorageClassSpecifier
parseStorageClassSpecifier = do
  (reserved "auto" >> return CAuto)
    <|> (reserved "register" >> return CRegister)
    <|> (reserved "static" >> return CStatic)
    <|> (reserved "extern" >> return CExtern)
    <|> (reserved "typedef" >> return CTypeDef)

parseTypeSpecifier :: Parser CTypeSpecifier
parseTypeSpecifier = do
  (reserved "void" >> return CVoidType)
    <|> (reserved "char" >> return CCharType)
    <|> (reserved "short" >> return CShortType)
    <|> (reserved "int" >> return CIntType)
    <|> (reserved "long" >> return CLongType)
    <|> (reserved "float" >> return CFloatType)
    <|> (reserved "double" >> return CDoubleType)
    <|> (reserved "signed" >> return CSignedType)
    <|> (reserved "unsigned" >> return CUnsignedType)

parseCAssignOp :: Parser CAssignOp
parseCAssignOp =
  (symbol "=" *> return Equal)
    <|> (symbol "*=" *> return TimesEq)
    <|> (symbol "/=" *> return DivEq)
    <|> (symbol "%=" *> return ModEq)
    <|> (symbol "+=" *> return PlusEq)
    <|> (symbol "-=" *> return MinusEq)
    <|> (symbol "<<=" *> return LShiftEq)
    <|> (symbol ">>=" *> return RShiftEq)
    <|> (symbol "&=" *> return BAndEq)
    <|> (symbol "^=" *> return BXOrEq)
    <|> (symbol "|=" *> return BOrEq)

parseCAssign :: Parser CExpression
parseCAssign = CAssign <$> parseCAssignOp <*> parseCExpression <*> parseCExpression

parseCExpression :: Parser CExpression
parseCExpression = do
  parseCConstExpr

parseCConstExpr :: Parser CExpression
parseCConstExpr = CConstExpr <$> ((IntConst <$> integer) <|> (DblConst <$> float lexer) <|> (CharConst <$> (symbol "'" *> anyChar <* symbol "'")))

parseCComma :: Parser CExpression
parseCComma = CComma <$> parseCExpression `sepBy` comma lexer

parseCCond :: Parser CExpression
parseCCond = CCond <$> parseCExpression <* symbol "?" <*> optionMaybe parseCExpression <* symbol ":" <*> parseCExpression

parseCInitializer :: Parser CInitializer
parseCInitializer = CInitializer <$> parseCExpression `sepBy` comma lexer

parseTypeQualifier :: Parser CTypeQualifier
parseTypeQualifier = (CConst <$ reserved "const") <|> (CVolatile <$ reserved "volatile")

parseCDeclaration :: Parser CDeclaration
parseCDeclaration =
  CDeclaration
    <$> parseCDeclarationSpecifiers
    <*> parseCDeclarator
    <*> optionMaybe (symbol "=" *> (parseCInitializer `sepBy` comma lexer))
    <* symbol ";"

parseCTranslationUnit :: Parser CTranslationUnit
parseCTranslationUnit = CTranslationUnit <$> parseCExternalDeclaration `sepBy` whiteSpace

clang :: Parser CTranslationUnit
clang = whiteSpace *> parseCTranslationUnit <* eof