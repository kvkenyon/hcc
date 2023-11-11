{-# LANGUAGE DeriveFoldable #-}
{-# LANGUAGE GADTs #-}

module Syntax where

data CId a = CId a String
  deriving (Show, Foldable)

data CTranslationUnit a where
  CTranslationUnit :: a -> [CExternalDeclaration a] -> CTranslationUnit a
  deriving (Show, Foldable)

data CExternalDeclaration a where
  CFuncDefExt :: a -> CFunctionDef a -> CExternalDeclaration a
  CDeclExt :: a -> CDeclaration a -> CExternalDeclaration a
  deriving (Show, Foldable)

data CFunctionDef a where
  CFunctionDef :: a -> CDeclarationSpecifier a -> CDeclarator a -> [CDeclaration a] -> CStatement a -> CFunctionDef a
  deriving (Show, Foldable)

data CDeclaration a where
  CDeclaration :: a -> CDeclarationSpecifier a -> [CDeclarator a] -> Maybe [CInitializer a] -> CDeclaration a
  deriving (Show, Foldable)

data CDeclarationSpecifier a where
  CStorageSpec :: a -> CStorageClassSpecifier a -> Maybe [CDeclarationSpecifier a] -> CDeclarationSpecifier a
  CTypeSpec :: a -> CTypeSpecifier a -> Maybe [CDeclarationSpecifier a] -> CDeclarationSpecifier a
  CTypeQual :: a -> CTypeQualifier a -> Maybe [CDeclarationSpecifier a] -> CDeclarationSpecifier a
  deriving (Show, Foldable)

data CStorageClassSpecifier a where
  CAuto :: a -> CStorageClassSpecifier a
  CRegister :: a -> CStorageClassSpecifier a
  CStatic :: a -> CStorageClassSpecifier a
  CExtern :: a -> CStorageClassSpecifier a
  CTypeDef :: a -> CStorageClassSpecifier a
  deriving (Show, Foldable)

data CTypeSpecifier a where
  CVoidType :: a -> CTypeSpecifier a
  CCharType :: a -> CTypeSpecifier a
  CShortType :: a -> CTypeSpecifier a
  CIntType :: a -> CTypeSpecifier a
  CLongType :: a -> CTypeSpecifier a
  CFloatType :: a -> CTypeSpecifier a
  CDoubleType :: a -> CTypeSpecifier a
  CSignedType :: a -> CTypeSpecifier a
  CUnsignedType :: a -> CTypeSpecifier a
  CStructType :: a -> CStructTypeSpecifier a -> CTypeSpecifier a
  deriving (Show, Foldable)

data CStructTypeSpecifier a where
  CStruct :: a -> StructOrUnion a -> Maybe (CId a) -> [CStructDeclaration a] -> CStructTypeSpecifier a
  deriving (Show, Foldable)

data StructOrUnion a = STRUCT a | UNION a
  deriving (Show, Foldable)

data CStructDeclaration a where
  CStructDecl :: a -> [CDeclarationSpecifier a] -> [CDeclarator a] -> CStructDeclaration a
  deriving (Show, Foldable)

data CTypeQualifier a where
  CConst :: a -> CTypeQualifier a
  CVolatile :: a -> CTypeQualifier a
  deriving (Show, Foldable)

data CDeclarator a where
  PtrDeclarator :: a -> CPointer a -> CDirectDeclarator a -> CDeclarator a
  Declarator :: a -> CDirectDeclarator a -> CDeclarator a
  StructDecl :: a -> CDeclarator a -> CExpression a -> CDeclarator a
  deriving (Show, Foldable)

data CPointer a where
  CPointer :: a -> [CTypeQualifier a] -> Maybe (CPointer a) -> CPointer a
  deriving (Show, Foldable)

data CDirectDeclarator a where
  CIdentDecl :: a -> CId a -> Maybe (CTypeModifier a) -> CDirectDeclarator a
  NestedDecl :: a -> CDeclarator a -> Maybe (CTypeModifier a) -> CDirectDeclarator a
  deriving (Show, Foldable)

data CTypeModifier a where
  ArrayModifier :: a -> CExpression a -> Maybe (CTypeModifier a) -> CTypeModifier a
  FuncModifier :: a -> [CId a] -> [CParameter a] -> CTypeModifier a
  deriving (Show, Foldable)

data CParameter a where
  CParameter :: a -> CDeclarationSpecifier a -> CDeclarator a -> CParameter a
  deriving (Show, Foldable)

data CInitializer a where
  CInitializer :: a -> [CExpression a] -> CInitializer a
  deriving (Show, Foldable)

data CTypeName a where
  CTypeName :: a -> [CDeclaration a] -> Maybe (CAbstractDeclarator a) -> CTypeName a
  deriving (Show, Foldable)

data CAbstractDeclarator a where
  CAbstDeclRoot :: a -> Maybe (CPointer a) -> Maybe (CAbstractDeclarator a) -> CAbstractDeclarator a
  ConstExprAbstDecl :: a -> Maybe (CAbstractDeclarator a) -> Maybe [CExpression a] -> CAbstractDeclarator a
  ParameterAbstDecl :: a -> Maybe (CAbstractDeclarator a) -> Maybe [CParameter a] -> CAbstractDeclarator a
  deriving (Show, Foldable)

data CTypeDefName a = CTypeDefName a (CId a)

data CStatement a where
  CCaseStmt :: a -> CCaseStatement a -> CStatement a
  CExprStmt :: a -> Maybe (CExpression a) -> CStatement a
  CCompStmt :: a -> Maybe [CDeclaration a] -> Maybe [CStatement a] -> CStatement a
  CSelectStmt :: a -> CSelectStatement a -> CStatement a
  CIterStmt :: a -> CIterStatement a -> CStatement a
  CJmpStmt :: a -> CJmpStatement a -> CStatement a
  deriving (Show, Foldable)

data CSelectStatement a where
  IfStmt :: a -> (CExpression a) -> CStatement a -> Maybe (CStatement a) -> CSelectStatement a
  SwitchStmt :: a -> (CExpression a) -> CStatement a -> CSelectStatement a
  deriving (Show, Foldable)

newtype CDefaultTag a = CDefaultTag a
  deriving (Show, Foldable)

data CCaseStatement a where
  CaseStmt :: a -> (CExpression a) -> CStatement a -> CCaseStatement a
  DefaultStmt :: a -> CDefaultTag a -> CStatement a -> CCaseStatement a
  deriving (Show, Foldable)

data CIterStatement a where
  CWhile :: a -> (CExpression a) -> CStatement a -> CIterStatement a
  CFor :: a -> Maybe (CExpression a) -> Maybe (CExpression a) -> Maybe (CExpression a) -> CStatement a -> CIterStatement a
  CDoWhile :: a -> CStatement a -> (CExpression a) -> CIterStatement a
  deriving (Show, Foldable)

data CJmpStatement a where
  CGoto :: a -> CId a -> CJmpStatement a
  CContinue :: a -> CJmpStatement a
  CBreak :: a -> CJmpStatement a
  CReturn :: a -> Maybe (CExpression a) -> CJmpStatement a
  deriving (Show, Foldable)

data CConstant a = IntConst a Integer | DblConst a Double | CharConst a Char
  deriving (Show, Foldable)

data CAssignOp a
  = Equal a
  | TimesEq a
  | DivEq a
  | ModEq a
  | PlusEq a
  | MinusEq a
  | LShiftEq a
  | RShiftEq a
  | BAndEq a
  | BXorEq a
  | BOrEq a
  deriving (Show, Eq, Foldable)

-- | C binary operators (K&R A7.6-15)
data CBinaryOp a
  = CMulOp a
  | CDivOp a
  | -- | remainder of division
    CRmdOp a
  | CAddOp a
  | CSubOp a
  | -- | shift left
    CShlOp a
  | -- | shift right
    CShrOp a
  | -- | less
    CLeOp a
  | -- | greater
    CGrOp a
  | -- | less or equal
    CLeqOp a
  | -- | greater or equal
    CGeqOp a
  | -- | equal
    CEqOp a
  | -- | not equal
    CNeqOp a
  | -- | bitwise and
    CAndOp a
  | -- | exclusive bitwise or
    CXorOp a
  | -- | inclusive bitwise or
    COrOp a
  | -- | logical and
    CLandOp a
  | -- | logical or
    CLorOp a
  deriving (Eq, Ord, Show, Foldable)

-- | C unary operator (K&R A7.3-4)
data CUnaryOp a
  = -- | prefix increment operator
    CPreIncOp a
  | -- | prefix decrement operator
    CPreDecOp a
  | -- | postfix increment operator
    CPostIncOp a
  | -- | postfix decrement operator
    CPostDecOp a
  | -- | address operator
    CAdrOp a
  | -- | indirection operator
    CIndOp a
  | -- | prefix plus
    CPlusOp a
  | -- | prefix minus
    CMinOp a
  | -- | one's complement
    CCompOp a
  | -- | logical negation
    CNegOp a
  -- TODO: Sizeof op
  deriving (Eq, Ord, Show, Foldable)

data CExpression a
  = CComma
      a
      [CExpression a] -- comma expression list, n >= 2
  | CAssign
      a
      (CAssignOp a) -- assignment operator
      (CExpression a) -- l-value
      (CExpression a)
  | -- r-value
    CCond
      a
      (CExpression a)
      -- conditional
      (Maybe (CExpression a)) -- true-expression (GNU allows omitting)
      (CExpression a)
  | -- false-expression
    CBinary
      a
      (CBinaryOp a) -- binary operator
      (CExpression a)
      -- lhs
      (CExpression a)
  | -- rhs
    CCast
      a
      (CDeclaration a) -- type name
      (CExpression a)
  | CUnary
      a
      (CUnaryOp a)
      -- unary operator
      (CExpression a)
  | CSizeofExpr
      a
      (CExpression a)
  | CSizeofType
      a
      (CDeclaration a) -- type name
  | CIndex
      a
      (CExpression a)
      -- array
      (CExpression a)
  | -- index
    CCall
      a
      (CExpression a)
      -- function
      [CExpression a] -- arguments
  | CMember
      a
      (CExpression a)
      -- structure
      (CId a)
      -- member name
      Bool -- deref structure? (True for `->')
  | CVar
      (CId a)
  | -- integer, character, floating point and string constants
    CConstExpr (CConstant a)
  deriving (Show, Foldable)
