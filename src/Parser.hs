module Parser where

import Control.Applicative
import Data.Maybe
import Parsing
  ( GenLanguageDef (reservedNames, reservedOpNames),
    Parser,
    TokenParser,
    emptyDef,
    eof,
    getIdentifier,
    getInteger,
    getParens,
    getReserved,
    getReservedOp,
    getSymbol,
    getWhiteSpace,
    makeTokenParser,
    optionMaybe,
    try,
  )
import Syntax
import Text.Parsec (sepBy)

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
            "return"
          ],
        reservedOpNames = ["=", "==", "<", "+", "-", "*", "!", "&&", "||"]
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
parseCExternalDeclaration = parseCFunctionDef <|> parseCDeclaration

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
parseCDeclarations = return []

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
  reserved "*"
  tyQual <- optionMaybe (parseTypeQualifier `sepBy` whiteSpace)
  CPointer tyQual <$> optionMaybe parseCPointer

parseCDeclarationSpecifiers :: Parser [CDeclarationSpecifier]
parseCDeclarationSpecifiers =
  (CTypeSpec <$> parseTypeSpecifier <*> optionMaybe parseCDeclarationSpecifiers)
    `sepBy` whiteSpace

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

parseTypeQualifier :: Parser CTypeQualifier
parseTypeQualifier = (CConst <$ reserved "const") <|> (CVolatile <$ reserved "volatile")

parseCDeclaration :: Parser CExternalDeclaration
parseCDeclaration = undefined

parseCTranslationUnit :: Parser CTranslationUnit
parseCTranslationUnit = CTranslationUnit <$> parseCExternalDeclaration `sepBy` (symbol ";" <|> symbol "}")

clang :: Parser CTranslationUnit
clang = whiteSpace *> parseCTranslationUnit <* eof