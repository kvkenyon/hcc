{-# LANGUAGE GADTs #-}

module Syntax where

type CId = String

data CTranslationUnit where
  CTranslationUnit :: [CExternalDeclaration] -> CTranslationUnit
  deriving (Show)

data CExternalDeclaration where
  CFuncDefExt :: CFunctionDef -> CExternalDeclaration
  CDeclExt :: CDeclaration -> CExternalDeclaration
  deriving (Show)

data CFunctionDef where
  CFunctionDef :: [CDeclarationSpecifier] -> CDeclarator -> [CDeclaration] -> CStatement -> CFunctionDef
  deriving (Show)

{--
DeclSpecs -> Declarator
DeclSpecs -> Declarator -> = -> Initializer

Initializer
AssignmentExpr
{[Initializer]}
--}
data CDeclaration where
  CDeclaration :: [CDeclarationSpecifier] -> CDeclarator -> Maybe [CInitializer] -> CDeclaration
  deriving (Show)

data CDeclarationSpecifier where
  CStorageSpec :: CStorageClassSpecifier -> Maybe [CDeclarationSpecifier] -> CDeclarationSpecifier
  CTypeSpec :: CTypeSpecifier -> Maybe [CDeclarationSpecifier] -> CDeclarationSpecifier
  CTypeQual :: CTypeQualifier -> Maybe [CDeclarationSpecifier] -> CDeclarationSpecifier
  deriving (Show)

data CStorageClassSpecifier where
  CAuto :: CStorageClassSpecifier
  CRegister :: CStorageClassSpecifier
  CStatic :: CStorageClassSpecifier
  CExtern :: CStorageClassSpecifier
  CTypeDef :: CStorageClassSpecifier
  deriving (Show)

data CTypeSpecifier where
  CVoidType :: CTypeSpecifier
  CCharType :: CTypeSpecifier
  CShortType :: CTypeSpecifier
  CIntType :: CTypeSpecifier
  CLongType :: CTypeSpecifier
  CFloatType :: CTypeSpecifier
  CDoubleType :: CTypeSpecifier
  CSignedType :: CTypeSpecifier
  CUnsignedType :: CTypeSpecifier
  deriving (Show)

data CTypeQualifier where
  CConst :: CTypeQualifier
  CVolatile :: CTypeQualifier
  deriving (Show)

data CDeclarator where
  CDeclRoot :: Maybe CPointer -> CDeclarator -> CDeclarator
  IdDecl :: CId -> CDeclarator
  ConstExprDecl :: CDeclarator -> Maybe CExpression -> CDeclarator
  ParameterDecl :: CDeclarator -> [CParameter] -> CDeclarator
  IdentifierDecl :: CDeclarator -> Maybe [CId] -> CDeclarator
  deriving (Show)

data CPointer where
  CPointer :: Maybe [CTypeQualifier] -> Maybe CPointer -> CPointer
  deriving (Show)

data CParameter where
  CParameter :: [CDeclarationSpecifier] -> CDeclarator -> CParameter
  deriving (Show)

data CInitializer where
  CInitializer :: [CExpression] -> CInitializer
  deriving (Show)

data CTypeName where
  CTypeName :: [CDeclaration] -> Maybe CAbstractDeclarator -> CTypeName
  deriving (Show)

data CAbstractDeclarator where
  CAbstDeclRoot :: Maybe CPointer -> Maybe CAbstractDeclarator -> CAbstractDeclarator
  ConstExprAbstDecl :: Maybe CAbstractDeclarator -> Maybe [CExpression] -> CAbstractDeclarator
  ParameterAbstDecl :: Maybe CAbstractDeclarator -> Maybe [CParameter] -> CAbstractDeclarator
  deriving (Show)

type CTypeDefName = CId

data CStatement where
  CCaseStmt :: CCaseStatement -> CStatement
  CExprStmt :: Maybe CExpression -> CStatement
  CCompStmt :: Maybe [CDeclaration] -> Maybe [CStatement] -> CStatement
  CSelectStmt :: CSelectStatement -> CStatement
  CIterStmt :: CIterStatement -> CStatement
  CJmpStmt :: CJmpStatement -> CStatement
  deriving (Show)

data CSelectStatement where
  IfStmt :: CExpression -> CStatement -> Maybe CStatement -> CSelectStatement
  SwitchStmt :: CExpression -> CStatement -> CSelectStatement
  deriving (Show)

data CDefaultTag = CDefaultTag
  deriving (Show)

data CCaseStatement where
  CaseRoot :: CExpression -> CStatement -> CCaseStatement
  CaseStmt :: CId -> CStatement -> CCaseStatement
  DefaultStmt :: CDefaultTag -> CStatement -> CCaseStatement
  deriving (Show)

data CIterStatement where
  CWhile :: CExpression -> CStatement -> CIterStatement
  CFor :: Maybe CExpression -> Maybe CExpression -> Maybe CExpression -> CStatement -> CIterStatement
  CDoWhile :: CStatement -> CExpression -> CIterStatement
  deriving (Show)

data CJmpStatement where
  CGoto :: CId -> CJmpStatement
  CContinue :: CJmpStatement
  CBreak :: CJmpStatement
  CReturn :: Maybe CExpression -> CJmpStatement
  deriving (Show)

data CConstant = IntConst Integer | DblConst Double | CharConst Char
  deriving (Show)

data CAssignOp
  = Equal
  | TimesEq
  | DivEq
  | ModEq
  | PlusEq
  | MinusEq
  | LShiftEq
  | RShiftEq
  | BAndEq
  | BXOrEq
  | BOrEq
  deriving (Show, Eq)

-- | C binary operators (K&R A7.6-15)
data CBinaryOp
  = CMulOp
  | CDivOp
  | -- | remainder of division
    CRmdOp
  | CAddOp
  | CSubOp
  | -- | shift left
    CShlOp
  | -- | shift right
    CShrOp
  | -- | less
    CLeOp
  | -- | greater
    CGrOp
  | -- | less or equal
    CLeqOp
  | -- | greater or equal
    CGeqOp
  | -- | equal
    CEqOp
  | -- | not equal
    CNeqOp
  | -- | bitwise and
    CAndOp
  | -- | exclusive bitwise or
    CXorOp
  | -- | inclusive bitwise or
    COrOp
  | -- | logical and
    CLndOp
  | -- | logical or
    CLorOp
  deriving (Eq, Ord, Show)

data CExpression
  = CComma
      [CExpression] -- comma expression list, n >= 2
  | CAssign
      CAssignOp -- assignment operator
      CExpression -- l-value
      CExpression -- r-value
  | CCond
      CExpression -- conditional
      (Maybe CExpression) -- true-expression (GNU allows omitting)
      CExpression -- false-expression
  | CBinary
      CBinaryOp -- binary operator
      CExpression -- lhs
      CExpression -- rhs
  | CCast
      CDeclaration -- type name
      CExpression
  | CUnary
      CUnaryOp -- unary operator
      CExpression
  | CSizeofExpr
      CExpression
  | CSizeofType
      CDeclaration -- type name
  | CAlignofExpr
      CExpression
  | CAlignofType
      CDeclaration -- type name
  | CComplexReal
      CExpression -- real part of complex number
  | CComplexImag
      CExpression -- imaginary part of complex number
  | CIndex
      CExpression -- array
      CExpression -- index
  | CCall
      CExpression -- function
      [CExpression] -- arguments
  | CMember
      CExpression -- structure
      CId -- member name
      Bool -- deref structure? (True for `->')
  | CVar
      CId -- identifier (incl. enumeration const)
  | CLiteral
      Integer
  | --   | -- | integer, character, floating point and string constants
    CConstExpr CConstant
  deriving (Show)

-- | C unary operator (K&R A7.3-4)
data CUnaryOp
  = -- | prefix increment operator
    CPreIncOp
  | -- | prefix decrement operator
    CPreDecOp
  | -- | postfix increment operator
    CPostIncOp
  | -- | postfix decrement operator
    CPostDecOp
  | -- | address operator
    CAdrOp
  | -- | indirection operator
    CIndOp
  | -- | prefix plus
    CPlusOp
  | -- | prefix minus
    CMinOp
  | -- | one's complement
    CCompOp
  | -- | logical negation
    CNegOp
  deriving (Eq, Ord, Show)
