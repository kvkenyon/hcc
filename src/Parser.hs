{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}

{-# HLINT ignore "Use $>" #-}
module Parser where

import Control.Applicative
import qualified Data.Functor.Identity as I
import Parsing
import Syntax
import qualified Text.Parsec.Prim

lexer :: TokenParser u
lexer =
  makeTokenParser $
    emptyDef
      { opStart = oneOf "-+/*=<>&|!",
        opLetter = oneOf "-+/*=<>&|!]",
        reservedNames =
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
            "typedef",
            "for",
            "char",
            "double",
            "float",
            "void",
            "short",
            "do",
            "long",
            "signed",
            "unsigned",
            "volatile",
            "const",
            "break",
            "case",
            "switch",
            "default"
          ],
        reservedOpNames =
          [ "=",
            "==",
            "<",
            "+",
            "-",
            "*",
            "!",
            "&&",
            "||"
          ],
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

comma :: Parser String
comma = getComma lexer

float :: Parser Double
float = getDouble lexer

semi :: Parser String
semi = getSemi lexer

braces :: Parser a -> Parser a
braces = getBraces lexer

brackets :: Text.Parsec.Prim.ParsecT String u I.Identity a -> Text.Parsec.Prim.ParsecT String u I.Identity a
brackets = getBrackets lexer

operator :: String -> Parser ()
operator = getReservedOp lexer

binary :: String -> (a -> a -> a) -> Assoc -> Operator String () I.Identity a
binary name fun = Infix (do operator name; return fun)

prefix :: String -> (a -> a) -> Operator String () I.Identity a
prefix name fun = Prefix (do operator name; return fun)

postfix :: String -> (a -> a) -> Operator String () I.Identity a
postfix name fun = Postfix (do operator name; return fun)

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
        <*> parseCCmpStatement
        <* symbol "}"

parseCCmpStatement :: Parser CStatement
parseCCmpStatement =
  CCompStmt
    <$> optionMaybe parseCDeclarations
    <*> optionMaybe (parseCStatement `sepBy` whiteSpace)

parseCStatement :: Parser CStatement
parseCStatement =
  (CJmpStmt <$> parseReturn)
    <|> (CExprStmt <$> optionMaybe parseCExpression <* semi)
    <|> parseIfStmt
    <|> parseWhileLoop
    <|> parseForLoop
    <|> parseSwitchStmt
    <|> parseCaseStmt
    <|> parseDefaultCaseStmt
    <|> parseBreakStmt

parseReturn :: Parser CJmpStatement
parseReturn = do
  whiteSpace
  reserved "return"
  whiteSpace
  expr <- optionMaybe parseCExpression
  whiteSpace
  _ <- symbol ";"
  whiteSpace
  return $
    CReturn
      ( case expr of
          Just e -> Just e
          _ -> Nothing
      )

{--
selection-statement:
  switch ( expression ) statement

labeled-statement:
  case constant-expression : statement
  default : statement
--}
parseSwitchStmt :: Parser CStatement
parseSwitchStmt = do
  reserved "switch"
  test <- parens parseCExpression
  body <- braces parseCCmpStatement
  let switch = SwitchStmt test body
  return $ CSelectStmt switch

parseCaseStmt :: Parser CStatement
parseCaseStmt = do
  reserved "case"
  expr <- parseCConstExpr
  _ <- symbol ":"
  CCaseStmt . CaseStmt expr <$> parseCStatement

parseDefaultCaseStmt :: Parser CStatement
parseDefaultCaseStmt = do
  reserved "default"
  _ <- symbol ":"
  CCaseStmt . DefaultStmt CDefaultTag <$> parseCStatement

parseBreakStmt :: Parser CStatement
parseBreakStmt = reserved "break" *> semi *> return (CJmpStmt CBreak)

parseIfStmt :: Parser CStatement
parseIfStmt = do
  reserved "if"
  test <- parens parseCExpression
  a <- braces parseCCmpStatement
  reserved "else"
  b <- optionMaybe (braces parseCCmpStatement)
  return $ CSelectStmt $ IfStmt test a b

parseWhileLoop :: Parser CStatement
parseWhileLoop = do
  reserved "while"
  test <- parens parseCExpression
  block <- braces parseCCmpStatement
  return $ CIterStmt $ CWhile test block

parseForLoop :: Parser CStatement
parseForLoop = do
  reserved "for"
  (a, b, c) <- parens loopConds
  block <- braces parseCCmpStatement
  return $ CIterStmt $ CFor a b c block
  where
    loopConds =
      do
        a <- optionMaybe parseCExpression <* semi
        b <- optionMaybe parseCExpression <* semi
        c <- optionMaybe parseCExpression
        return (a, b, c)

parseCDeclarations :: Parser [CDeclaration]
parseCDeclarations = try parseCDeclaration `sepBy` whiteSpace

parseCDeclarator :: Parser CDeclarator
parseCDeclarator = parsePtrDeclarator <|> parseDeclarator

parsePtrDeclarator :: Parser CDeclarator
parsePtrDeclarator = do
  ptr <- parseCPointer
  PtrDeclarator ptr <$> parseCDirectDecl

parseCPointer :: Parser CPointer
parseCPointer = do
  _ <- symbol "*"
  tyQual <- option [] $ parseTypeQualifier `sepBy` whiteSpace
  CPointer tyQual <$> optionMaybe parseCPointer

parseDeclarator :: Parser CDeclarator
parseDeclarator = Declarator <$> parseCDirectDecl

parseCDirectDecl :: Parser CDirectDeclarator
parseCDirectDecl =
  ( NestedDecl
      <$> parens parseCDeclarator
      <*> optionMaybe parseTypeModifier
  )
    <|> CIdentDecl <$> ident <*> optionMaybe parseTypeModifier

parseTypeModifier :: Parser CTypeModifier
parseTypeModifier = parseArrayModifier <|> parseFuncModifier

parseArrayModifier :: Parser CTypeModifier
parseArrayModifier = ArrayModifier <$> brackets parseCConstExpr <*> optionMaybe parseArrayModifier

parseFuncModifier :: Parser CTypeModifier
parseFuncModifier = do
  _ <- symbol "("
  ids <- option [] (ident `sepBy` comma)
  params <- option [] $ parseCParameter `sepBy` comma
  _ <- symbol ")"
  return $ FuncModifier ids params

parseCParameter :: Parser CParameter
parseCParameter =
  CParameter
    <$> parseCDeclarationSpecifiers
    <*> parseCDeclarator

parseCDeclarationSpecifiers :: Parser [CDeclarationSpecifier]
parseCDeclarationSpecifiers =
  ( parseStorageDeclSpec
      <|> parseTypeDeclSpec
      <|> parseTypeQualDeclSpec
  )
    `sepBy` whiteSpace

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
    <|> (reserved "struct" >> parseStructTypeSpec STRUCT)
    <|> (reserved "union" >> parseStructTypeSpec UNION)

parseStructTypeSpec :: StructOrUnion -> Parser CTypeSpecifier
parseStructTypeSpec su =
  do
    iden <- optionMaybe ident
    decls <- option [] $ braces parseStruct
    return $ CStructType $ CStruct su iden decls

parseStruct :: Parser [CStructDeclaration]
parseStruct = parseStructDeclaration `sepBy` semi

parseStructDeclaration :: Parser CStructDeclaration
parseStructDeclaration = do
  declSpecs <- parseCDeclarationSpecifiers
  decls <- parseCDeclarator `sepBy` comma
  return $ CStructDecl declSpecs decls

parseCInitializer :: Parser CInitializer
parseCInitializer = CInitializer <$> parseCExpression `sepBy` comma

parseTypeQualifier :: Parser CTypeQualifier
parseTypeQualifier =
  (CConst <$ reserved "const")
    <|> (CVolatile <$ reserved "volatile")

parseCDeclaration :: Parser CDeclaration
parseCDeclaration =
  CDeclaration
    <$> parseCDeclarationSpecifiers
    <*> parseCDeclarator `sepBy` comma
    <*> optionMaybe (symbol "=" *> (parseCInitializer `sepBy` comma))
    <* symbol ";"

parseCTranslationUnit :: Parser CTranslationUnit
parseCTranslationUnit =
  CTranslationUnit
    <$> parseCExternalDeclaration `sepBy` whiteSpace

-- Parse Expressions
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
parseCAssign = do
  lvalue <- parseCExpression
  op <- parseCAssignOp
  CAssign op lvalue <$> parseCExpression

parseCConstExpr :: Parser CExpression
parseCConstExpr =
  CConstExpr
    <$> ( (IntConst <$> integer)
            <|> (DblConst <$> float)
            <|> (CharConst <$> (symbol "'" *> anyChar <* symbol "'"))
        )

parseCVar :: Parser CExpression
parseCVar = CVar <$> ident

parseCComma :: Parser CExpression
parseCComma = CComma <$> parseCExpression `sepBy` comma

bottomParser :: Parser CExpression
bottomParser = do
  test <- topParser
  ternary test <|> assg test <|> return test
  where
    ternary test = do
      _ <- symbol "?"
      a <- optionMaybe parseCExpression
      _ <- symbol ":"
      CCond test a <$> parseCExpression
    assg lvalue = do
      op <- parseCAssignOp
      CAssign op lvalue <$> parseCExpression

term :: Text.Parsec.Prim.ParsecT String () I.Identity CExpression
term =
  try $
    parens parseCExpression
      <|> try parseCConstExpr
      <|> parseCVar

table :: [[Operator String () I.Identity CExpression]]
table =
  [ [prefix "!" (CUnary CNegOp), prefix "-" (CUnary CMinOp)],
    [postfix "++" (CUnary CPostIncOp), postfix "--" (CUnary CPostDecOp)],
    [ binary "*" (CBinary CMulOp) AssocLeft,
      binary "/" (CBinary CDivOp) AssocLeft,
      binary "%" (CBinary CRmdOp) AssocLeft
    ],
    [ binary "+" (CBinary CAddOp) AssocLeft,
      binary "-" (CBinary CSubOp) AssocLeft
    ],
    [ binary "==" (CBinary CEqOp) AssocNone,
      binary "<" (CBinary CLeOp) AssocNone,
      binary "<=" (CBinary CLeqOp) AssocNone,
      binary ">=" (CBinary CGeqOp) AssocNone,
      binary ">" (CBinary CGrOp) AssocNone
    ],
    [ binary "&&" (CBinary CLandOp) AssocLeft,
      binary "||" (CBinary CLorOp) AssocLeft
    ]
  ]

topParser :: Parser CExpression
topParser = buildExpressionParser table term

parseCExpression :: Text.Parsec.Prim.ParsecT String () I.Identity CExpression
parseCExpression = buildExpressionParser [] bottomParser

clang :: Parser CTranslationUnit
clang = whiteSpace *> parseCTranslationUnit <* eof