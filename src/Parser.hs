module Parser where

import Control.Applicative
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
            "main",
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
parseCExternalDeclaration = parseCFunctionDef <|> parseCDecleration

parseCFunctionDef :: Parser CExternalDeclaration
parseCFunctionDef = CFuncDefExt <$> cFuncDef
  where
    cFuncDef =
      CFunctionDef
        <$> parseCDeclarationSpecifiers
        <*> parseCDeclarator
        <*> parseCDeclarations
        <*> parseCStatement

parseCStatement :: Parser CStatement
parseCStatement = undefined

parseCDeclarations :: Parser [CDeclaration]
parseCDeclarations = undefined

parseCDeclarator :: Parser CDeclarator
parseCDeclarator = undefined

parseCDeclarationSpecifiers :: Parser [CDeclarationSpecifier]
parseCDeclarationSpecifiers =
  ( CTypeSpec
      <$> parseTypeSpecifier
      <*> ( do
              decSpecs <- parseCDeclarationSpecifiers
              case decSpecs of
                [] -> return Nothing
                x -> return $ Just x
          )
  )
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

parseCDecleration :: Parser CExternalDeclaration
parseCDecleration = undefined

parseCTranslationUnit :: Parser CTranslationUnit
parseCTranslationUnit = CTranslationUnit <$> parseCExternalDeclaration `sepBy` (symbol ";" <|> symbol "}")

clang :: Parser CTranslationUnit
clang = whiteSpace *> parseCTranslationUnit <* eof