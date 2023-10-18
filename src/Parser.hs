module Parser where

import Parsing

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

