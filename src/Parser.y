{
{-# LANGUAGE DeriveFoldable #-}
module Parser
  ( clang 
  ) where

import Data.ByteString.Lazy.Char8 (ByteString)
import Data.ByteString.Lazy.Char8 qualified as BS
import Data.Maybe (fromJust)
import Data.Monoid (First (..))
import Syntax

import qualified Lexer as L
}

%name clang translation_unit 
%tokentype { L.RangedToken }
%error { parseError }
%monad { L.Alex } { >>= } { pure }
%lexer { lexer } { L.RangedToken L.EOF _ }
%token
  -- Identifiers
  identifier { L.RangedToken (L.Identifier _) _ }
  -- Constants
  string           { L.RangedToken (L.StringLit _) _ }
  integer_const    { L.RangedToken (L.IntConst _) _ }
  float_const      { L.RangedToken (L.FloatConst _) _}
  char_const       { L.RangedToken (L.CharConst _) _}
  -- Keywords
  if         { L.RangedToken L.If _ }
  else       { L.RangedToken L.Else _ }
  auto       { L.RangedToken L.Auto _ }
  break      { L.RangedToken L.Break _ }
  case       { L.RangedToken L.Case _}
  char       { L.RangedToken L.Char _}
  const      { L.RangedToken L.Const _}
  continue   { L.RangedToken L.Continue _}
  default    { L.RangedToken L.Default _}
  do         { L.RangedToken L.Do _}
  double     { L.RangedToken L.Double _}
  enum       { L.RangedToken L.Enum _}
  extern     { L.RangedToken L.Extern _}
  float      { L.RangedToken L.Float _}
  for        { L.RangedToken L.For _}
  int        { L.RangedToken L.Int _}
  long       { L.RangedToken L.Long _}
  register   { L.RangedToken L.Register _}
  return     { L.RangedToken L.Return _}
  goto       { L.RangedToken L.Goto _}
  short      { L.RangedToken L.Short _}
  signed     { L.RangedToken L.Signed _}
  sizeof     { L.RangedToken L.Sizeof _}
  static     { L.RangedToken L.Static _}
  struct     { L.RangedToken L.Struct _}
  switch     { L.RangedToken L.Switch _}
  typedef    { L.RangedToken L.Typedef _}
  union      { L.RangedToken L.Union _}
  unsigned   { L.RangedToken L.Unsigned _}
  void       { L.RangedToken L.Void _}
  volatile   { L.RangedToken L.Volatile _}
  while      { L.RangedToken L.While _}
  '+'        { L.RangedToken L.Plus _ }
  '-'        { L.RangedToken L.Minus _ }
  '*'        { L.RangedToken L.Times _ }
  '/'        { L.RangedToken L.Div _ }
  '++'       { L.RangedToken L.Inc _ }
  '--'       { L.RangedToken L.Dec _ }
  '&&'       { L.RangedToken L.LAnd _ }
  '||'       { L.RangedToken L.LOr _ }
  '%'        { L.RangedToken L.Mod _ }
  '='        { L.RangedToken L.AEq _ }
  '=='       { L.RangedToken L.Eq _ }
  '!='       { L.RangedToken L.NotEq _ }
  '!'        { L.RangedToken L.Bang _ }
  '<'        { L.RangedToken L.Le _ }
  '<='       { L.RangedToken L.LEq _ }
  '>'        { L.RangedToken L.Gr _ }
  '>='       { L.RangedToken L.GEq _ }
  '~'        { L.RangedToken L.Complement _ }
  '&'        { L.RangedToken L.Amp _ }
  '|'        { L.RangedToken L.Or _ }
  '('        { L.RangedToken L.LParen _ }
  ')'        { L.RangedToken L.RParen _ }
  '['        { L.RangedToken L.LBracket _ }
  ']'        { L.RangedToken L.RBracket _ }
  '.'        { L.RangedToken L.Dot _ }
  ':'        { L.RangedToken L.Colon _ }
  '->'       { L.RangedToken L.Arrow _ }
  '<<'       { L.RangedToken L.LShift _ }
  '>>'       { L.RangedToken L.RShift _ }
  '^'        { L.RangedToken L.Xor _ }
  '?'        { L.RangedToken L.QMark _ }
  '*='       { L.RangedToken L.TimesEq _ }
  '/='       { L.RangedToken L.DivEq _ }
  '%='       { L.RangedToken L.ModEq _ }
  '+='       { L.RangedToken L.PlusEq _ }
  '-='       { L.RangedToken L.MinusEq _ }
  '<<='      { L.RangedToken L.LShiftEq _ }
  '>>='      { L.RangedToken L.RShiftEq _ }
  '&='       { L.RangedToken L.AndEq _ }
  '|='       { L.RangedToken L.OrEq _ }
  '^='       { L.RangedToken L.XorEq _ }
  ','        { L.RangedToken L.Comma _ }
  '#'        { L.RangedToken L.Pnd _ }
  '##'       { L.RangedToken L.DblPnd _ }
  '{'        { L.RangedToken L.LBrace _ }
  '}'        { L.RangedToken L.RBrace _ }
  ';'        { L.RangedToken L.SemiColon _ }
  '...'      { L.RangedToken L.Ellipsis _ }

%expect 0 
%left ',' 
%right '=' '*=' '/=' '%=' '+=' '-=' '<<=' '>>=' '&=' '|=' '^='
%right '?' ':'
%left '||' 
%left '&&'
%left '|'
%left '^'
%left '&'
%nonassoc '==' '!='
%nonassoc '<' '>'  '<=' '>='  
%left '<<' '>>'
%left '+' '-' 
%left '*' '/' '%' 
%right PRE DRF ADR POS NEG '~' '!' sizeof
%left '++' '--' '->' '.' '(' ')' '[' ']'
%%

translation_unit :: {CTranslationUnit L.Range}
  : external_declarations {CTranslationUnit (infos $1) (reverse $1)}

external_declaration :: {CExternalDeclaration L.Range}
  : function_definition {CFuncDefExt (info $1) $1}
  | declaration {CDeclExt (info $1) $1} 

external_declarations :: {[CExternalDeclaration L.Range]}
  : external_declaration {[$1]}
  | external_declarations external_declaration {$2:$1}

function_definition :: {CFunctionDef L.Range}
  : decl_specs declarator block {CFunctionDef (infos $1 <-> info $3) $1 $2 [] $3}

declaration :: {CDeclaration L.Range}
  : decl_specs ';' {CDeclaration (infos $1) $1 []}
  | decl_specs init_declarator_list ';' {CDeclaration (infos $1 <-> L.rtRange $3) $1 $2}

init_declarator_list :: {[CInitDeclarator L.Range]}
  : init_declarator {[$1]}
  | init_declarator_list ',' init_declarator {$3:$1}

init_declarator :: {CInitDeclarator L.Range}
  : declarator {CInitDeclarator (info $1) $1 Nothing}
  | declarator '=' initializer {CInitDeclarator (info $1 <-> info $3) $1 (Just $3)}

initializer :: {CInitializer L.Range}
  : expr  {CInitializer (info $1) [$1] []}
  | '{' initializer_list '}' {CInitializer (L.rtRange $1 <-> L.rtRange $3) [] $2} 
  | '{' initializer_list ',' '}' {CInitializer (L.rtRange $1 <-> L.rtRange $4) [] $2}

initializer_list :: {[CInitializer L.Range]}
  : initializer {[$1]}
  | initializer_list ',' initializer {$3:$1}

decl_specs :: {[CDeclarationSpecifier L.Range]}
  : decl_spec {[$1]}
  | decl_specs decl_spec {$2:$1}

decl_spec :: {CDeclarationSpecifier L.Range}
  : storage_spec {CStorageSpec (info $1) $1 }
  | type_spec {CTypeSpec (info $1) $1 }
  | type_qual {CTypeQual(info $1) $1 }

storage_spec :: {CStorageClassSpecifier L.Range}
  : auto {CAuto (L.rtRange $1)}
  | register {CRegister (L.rtRange $1)}
  | static {CStatic (L.rtRange $1)}
  | extern {CExtern (L.rtRange $1)}
  | typedef {CTypeDef (L.rtRange $1)}

type_spec :: {CTypeSpecifier L.Range}
  : void {CVoidType (L.rtRange $1)}
  | char {CCharType (L.rtRange $1)}
  | short {CShortType (L.rtRange $1)}
  | int {CIntType (L.rtRange $1)}
  | long {CLongType (L.rtRange $1)}
  | float {CFloatType (L.rtRange $1)}
  | double {CDoubleType (L.rtRange $1)}
  | signed {CSignedType (L.rtRange $1)}
  | unsigned {CUnsignedType (L.rtRange $1)}
  | struct_type_specifier {CStructType (info $1) $1}
  | enum_specifier {CEnumType (info $1) $1}

struct_type_specifier :: {CStructTypeSpecifier L.Range}
  : struct variable '{' struct_declaration_list '}' {CStruct (L.rtRange $1 <-> L.rtRange $5) (STRUCT (L.rtRange $1)) (Just $2) (reverse $4)}
  | struct '{' struct_declaration_list '}' {CStruct (L.rtRange $1 <-> L.rtRange $4) (STRUCT (L.rtRange $1)) Nothing (reverse $3)} 
  | struct variable {CStruct (L.rtRange $1 <->  info $2) (STRUCT(L.rtRange $1)) Nothing []}
  | union variable '{' struct_declaration_list '}' {CStruct (L.rtRange $1 <-> L.rtRange $5) (UNION(L.rtRange $1)) (Just $2) (reverse $4)}
  | union '{' struct_declaration_list '}'{CStruct (L.rtRange $1 <-> L.rtRange $4) (UNION (L.rtRange $1)) Nothing (reverse $3)}
  | union variable {CStruct (L.rtRange $1 <->  info $2) (UNION (L.rtRange $1)) Nothing []}

struct_declaration_list :: {[CStructDeclaration L.Range]}
  : {- empty -}  {[]}
  | struct_declaration_list struct_declaration {$2:$1}

struct_declaration :: {CStructDeclaration L.Range}
  : specifier_qualifier_list struct_declarator_list ';' {CStructDecl (infos $1 <-> L.rtRange $3) $1 $2} 

struct_declarator_list :: {[CStructDeclarator L.Range]}
  : struct_declarator {[$1]}
  | struct_declarator_list ',' struct_declarator {$3:$1}

struct_declarator :: {CStructDeclarator L.Range}
  : declarator {CStructDeclarator (info $1) (Just $1) Nothing} 
  | ':' expr   {CStructDeclarator (L.rtRange $1 <-> info $2) Nothing (Just $2)}
  | declarator ':' expr  {CStructDeclarator (info $1 <-> info $3) (Just $1) (Just $3)}

enum_specifier :: {CEnumTypeSpecifier L.Range}
  : enum '{' enumerator_list '}' {CEnumSpecifier (L.rtRange $1 <-> L.rtRange $4) Nothing (reverse $3)}
  | enum variable '{' enumerator_list '}' {CEnumSpecifier (L.rtRange $1 <-> L.rtRange $5) (Just $2) (reverse $4)}
  | enum variable {CEnumSpecifier (L.rtRange $1 <-> info $2) (Just $2) []}

enumerator_list :: {[CEnumerator L.Range]}
  : enumerator {[$1]}
  | enumerator_list ',' enumerator {$3:$1}

enumerator :: {CEnumerator L.Range}
  : variable {CEnumerator (info $1) $1 Nothing}
  | variable '=' expr {CEnumerator (info $1 <-> info $3)  $1 (Just $3)}

type_qual :: {CTypeQualifier L.Range}
  : const {CConst (L.rtRange $1)}
  | volatile {CVolatile (L.rtRange $1)}

declarator :: {CDeclarator L.Range}
  : pointer direct_decl {PtrDeclarator (info $1 <-> info $2) $1 $2}
  | direct_decl {Declarator (info $1) $1} 

type_qualifier_list :: {[CTypeQualifier L.Range]}
  : type_qual {[$1]}
  | type_qualifier_list type_qual {$2 : $1}
 
pointer :: {CPointer L.Range}
  : '*' {CPointer (L.rtRange $1) [] Nothing}
  | '*' pointer {CPointer (L.rtRange $1 <-> info $2) [] (Just $2)} 
  | '*' type_qualifier_list {CPointer (L.rtRange $1) $2 Nothing}
  | '*' type_qualifier_list pointer {CPointer (L.rtRange $1 <-> info $3) $2 (Just $3)}

direct_decl :: {CDirectDeclarator L.Range}
  : ident_decl {$1}
  | '(' declarator ')' {NestedDecl (info $2) $2 Nothing}
  | '(' declarator ')' type_modifier {NestedDecl (L.rtRange $1 <-> info $4) $2 (Just $4)}   

ident_decl :: {CDirectDeclarator L.Range}
  : variable type_modifier {CIdentDecl (info $1 <-> info $2) $1 (Just $2)}
  | variable {CIdentDecl (info $1) $1 Nothing}

type_modifier :: {CTypeModifier L.Range}
  : array_modifier {$1}
  | func_modifier  {$1}

array_modifier :: {CTypeModifier L.Range}
  : '[' expr ']' array_modifier {ArrayModifier (L.rtRange $1 <-> info $4) (Just $2) (Just $4)}
  | '[' expr ']' {ArrayModifier (L.rtRange $1 <-> L.rtRange $3) (Just $2) Nothing}
  | '[' ']' {ArrayModifier (L.rtRange $1 <-> L.rtRange $2) Nothing Nothing}
  | '[' ']' array_modifier  {ArrayModifier (L.rtRange $1 <->info $3) Nothing (Just $3)}

func_modifier :: {CTypeModifier L.Range}
  : '(' ')' {FuncModifier (L.rtRange $1 <-> L.rtRange $2) [] Nothing}
  | '(' variables ')' {FuncModifier (L.rtRange $1 <-> L.rtRange $3) (reverse $2) Nothing}
  | '(' parameter_type_list ')' {FuncModifier (L.rtRange $1 <-> L.rtRange $3) [] (Just $2)}

parameter :: {CParameter L.Range}
  :  decl_specs declarator {CParameter (infos $1 <-> info $2) $1 $2}
  | decl_specs abstract_declarator {CAbstractParam (infos $1 <-> info $2) $1 $2}
  | decl_specs {CNoDeclaratorParam (infos $1) $1}

parameter_type_list :: { CParameterTypeList L.Range }
  : parameters {CParamTypeList (infos $1) $1 Nothing}
  | parameters ',' '...' {CParamTypeList (infos $1) $1 (Just $ CEllipsis (L.rtRange $3))}

parameters ::  {[CParameter L.Range]}
  : parameter {[$1]}
  | parameters ',' parameter {$3 : $1}

type_name :: {CTypeName L.Range}
  : specifier_qualifier_list {CTypeName (infos $1) $1 Nothing}
  | specifier_qualifier_list abstract_declarator {CTypeName (infos $1 <-> info $2) $1 (Just $2)}

specifier_qualifier_list :: {[CSpecifierQualifier L.Range]}
  : specifier_qualifier {[$1]}
  | specifier_qualifier_list specifier_qualifier {$2:$1}

specifier_qualifier :: {CSpecifierQualifier L.Range}
  : type_spec {CTypeS (info $1) $1}
  | type_qual {CTypeQ (info $1) $1}

abstract_declarator :: {CAbstractDeclarator L.Range}
  : pointer {CAbstractDeclarator (info $1) (Just $1) Nothing}
  | direct_abstract_declarator {CAbstractDeclarator (info $1) Nothing (Just $1)}
  | pointer direct_abstract_declarator {CAbstractDeclarator (info $1 <-> info $2) (Just $1) (Just $2)}

direct_abstract_declarator :: {CDirectAbstractDeclarator L.Range}
  : '(' abstract_declarator ')' {CDirectAbstractDeclarator (L.rtRange $1 <-> L.rtRange $3) $2}
  | '[' ']' {CDirectArrayAbstractDeclarator (L.rtRange $1 <-> L.rtRange $2) Nothing Nothing}
  | '[' expr ']' {CDirectArrayAbstractDeclarator (L.rtRange $1 <-> L.rtRange $3) Nothing (Just $2) }
  | direct_abstract_declarator '[' ']' {CDirectArrayAbstractDeclarator (info $1 <-> L.rtRange $3) (Just $1) Nothing}
  | direct_abstract_declarator '[' expr ']' {CDirectArrayAbstractDeclarator (info $1 <-> L.rtRange $4) (Just $1) (Just $3) }
  | '(' ')' {CDirectFunctionAbstractDeclarator (L.rtRange $1 <-> L.rtRange $2) Nothing Nothing}
  | '(' parameter_type_list ')' {CDirectFunctionAbstractDeclarator (L.rtRange $1 <-> L.rtRange $3) Nothing (Just $2)}
  | direct_abstract_declarator '(' ')' {CDirectFunctionAbstractDeclarator (info $1 <-> L.rtRange $3) (Just $1) Nothing}
  | direct_abstract_declarator '(' parameter_type_list ')' {CDirectFunctionAbstractDeclarator (info $1 <-> L.rtRange $4) (Just $1) (Just $3)}

variable :: { CId L.Range }
  : identifier { unTok $1 (\range (L.Identifier iden) -> CId range $ BS.unpack iden) }

variables :: {[CId L.Range]}
  : variable {[$1]}
  | variables ',' variable {$3 : $1}

assign :: {CExpression L.Range}
  : expr '=' expr {unTok $2 (\range (L.AEq) -> CAssign range (Equal range) $1 $3)}
  | expr '*=' expr {unTok $2 (\range (L.TimesEq) -> CAssign range (TimesEq range) $1 $3)}
  | expr '/=' expr {unTok $2 (\range (L.DivEq) -> CAssign range (DivEq range) $1 $3)}
  | expr '%=' expr {unTok $2 (\range (L.ModEq) -> CAssign range (ModEq range) $1 $3)}
  | expr '+=' expr {unTok $2 (\range (L.PlusEq) -> CAssign range (PlusEq range) $1 $3)}
  | expr '-=' expr {unTok $2 (\range (L.MinusEq) -> CAssign range (MinusEq range) $1 $3)}
  | expr '>>=' expr {unTok $2 (\range (L.RShiftEq) -> CAssign range (RShiftEq range) $1 $3)}
  | expr '<<=' expr {unTok $2 (\range (L.LShiftEq) -> CAssign range (LShiftEq range) $1 $3)}
  | expr '&=' expr {unTok $2 (\range (L.AndEq) -> CAssign range (BAndEq range) $1 $3)}
  | expr '^=' expr {unTok $2 (\range (L.XorEq) -> CAssign range (BXorEq range) $1 $3)}
  | expr '|=' expr {unTok $2 (\range (L.OrEq) -> CAssign range (BOrEq range) $1 $3)}

member :: {CExpression L.Range}
  : expr '->' variable {unTok $2 (\range (L.Arrow) -> CMember range $1 $3 True)}
  | expr '.' variable {unTok $2 (\range (L.Dot) -> CMember range $1 $3 False)}

call :: {CExpression L.Range}
  : expr '(' exprs ')'  {CCall (info $1 <-> L.rtRange $4) $1 (reverse $3)}

exprs :: {[CExpression L.Range]}
exprs : {- empty -}    { [] } 
      | expr           { [$1] }
      | exprs ',' expr { $3 : $1 }

index :: {CExpression L.Range}
  : expr '[' expr ']' {CIndex (info $1 <-> L.rtRange $4) $1 $3}

cast :: {CExpression L.Range}
  : '(' type_name ')' expr {CCast (L.rtRange $1 <-> L.rtRange $3) $2 $4}

unary :: {CExpression L.Range}
  : '++' expr %prec PRE {unTok $1 (\range (L.Inc) -> CUnary range (CPreIncOp range) $2)}
  | expr '++' {unTok $2 (\range (L.Inc) -> CUnary range (CPostIncOp range) $1)}
  | '--' expr  %prec PRE {unTok $1 (\range (L.Dec) -> CUnary range (CPreDecOp range) $2)}
  | expr '--' {unTok $2 (\range (L.Dec) -> CUnary range (CPostDecOp range) $1)}
  | '&' expr %prec ADR  {unTok $1 (\range (L.Amp) -> CUnary range (CAdrOp range) $2)}
  | '*' expr %prec DRF  {unTok $1 (\range (L.Times) -> CUnary range (CIndOp range) $2)}
  | '+' expr %prec POS  {unTok $1 (\range (L.Plus) -> CUnary range (CPlusOp range) $2)}
  | '-' expr  %prec NEG {unTok $1 (\range (L.Minus) -> CUnary range (CMinOp range) $2)}
  | '~' expr  {unTok $1 (\range (L.Complement) -> CUnary range (CCompOp range) $2)}
  | '!' expr  {unTok $1 (\range (L.Bang) -> CUnary range (CNegOp range) $2)}
  | sizeof expr {CSizeofExpr (L.rtRange $1 <-> info $2) $2}
  | sizeof '(' type_name ')' {CSizeofType (L.rtRange $1 <-> L.rtRange $4) $3}

binary :: {CExpression L.Range}
  : expr '+' expr {unTok $2 (\range (L.Plus) -> CBinary range (CAddOp range) $1 $3)}
  | expr '*' expr {unTok $2 (\range (L.Times) -> CBinary range (CMulOp range) $1 $3)}
  | expr '-' expr {unTok $2 (\range (L.Minus) -> CBinary range (CSubOp range) $1 $3)}
  | expr '/' expr {unTok $2 (\range (L.Div) -> CBinary range (CDivOp range) $1 $3)}
  | expr '%' expr {unTok $2 (\range (L.Mod) -> CBinary range (CRmdOp range) $1 $3)}
  | expr '<<' expr {unTok $2 (\range (L.LShift) -> CBinary range (CShlOp range) $1 $3)}
  | expr '>>' expr {unTok $2 (\range (L.RShift) -> CBinary range (CShrOp range) $1 $3)}
  | expr '<' expr {unTok $2 (\range (L.Le) -> CBinary range (CLeOp range) $1 $3)}
  | expr '>' expr {unTok $2 (\range (L.Gr) -> CBinary range (CGrOp range) $1 $3)}
  | expr '>=' expr {unTok $2 (\range (L.GEq) -> CBinary range (CGeqOp range) $1 $3)}
  | expr '<=' expr {unTok $2 (\range (L.LEq) -> CBinary range (CLeqOp range) $1 $3)}
  | expr '==' expr {unTok $2 (\range (L.Eq) -> CBinary range (CEqOp range) $1 $3)}
  | expr '!=' expr {unTok $2 (\range (L.NotEq) -> CBinary range (CNeqOp range) $1 $3)}
  | expr '&&' expr {unTok $2 (\range (L.LAnd) -> CBinary range (CLandOp range) $1 $3)}
  | expr '||' expr {unTok $2 (\range (L.LOr) -> CBinary range (CLorOp range) $1 $3)}
  | expr '^' expr {unTok $2 (\range (L.Xor) -> CBinary range (CXorOp range) $1 $3)}
  | expr '&' expr {unTok $2 (\range (L.Amp) -> CBinary range (CAndOp range) $1 $3)}
  | expr '|' expr {unTok $2 (\range (L.Or) -> CBinary range (COrOp range) $1 $3)}

ternary :: {CExpression L.Range}
  : expr '?' expr ':' expr {CCond (info $1 <-> info $5) $1 (Just $3) $5}
  | expr '?' ':' expr {CCond (info $1 <-> info $4) $1 Nothing $4}

-- TODO: Update types to handle weird c-types like char with multiple chars
expr :: {CExpression L.Range }
  : variable {CVar $1}
  | integer_const {unTok $1 (\range (L.IntConst int) -> CConstExpr $ IntConst range $ BS.unpack int)}
  | float_const {unTok $1 (\range (L.FloatConst f) -> CConstExpr $ DblConst range $ BS.unpack f)}
  | char_const {unTok $1 (\range (L.CharConst c) -> CConstExpr $ CharConst range $ read $ BS.unpack c)}
  | string {unTok $1 (\range (L.StringLit s) -> CStringLit range (BS.unpack s))}
  | ternary {$1}
  | binary {$1}
  | unary {$1}
  | assign {$1}
  | member {$1}
  | call {$1}
  | index {$1}
  | '(' expr ')' {$2}
  | cast {$1}

stmt :: {CStatement L.Range}
  : if_stmt {CSelectStmt (info $1) $1}
  | block {$1}
  | expr ';'  {CExprStmt (info $1) (Just $1)}
  | for_loop {CIterStmt (info $1) $1}
  | while_loop {CIterStmt (info $1) $1}
  | do_while {CIterStmt (info $1) $1}
  | jump_stmt {CJmpStmt (info $1) $1}
  | switch_stmt {CSelectStmt (info $1) $1}
  | case_stmt {CCaseStmt (info $1) $1}

block :: {CStatement L.Range}
  : '{' stmts '}' {CCompStmt (L.rtRange $1 <-> L.rtRange $3) Nothing (Just $ reverse $2)}
  | '{' declarations stmts '}' {CCompStmt (L.rtRange $1 <-> L.rtRange $4) (Just $ reverse $2) (Just $ reverse $3)}

stmts :: {[CStatement L.Range]}
  : stmt {[$1]} 
  | stmts stmt {$2:$1}
 
declarations :: {[CDeclaration L.Range]}
  : declaration { [$1] }
  | declarations declaration {$2:$1}

if_stmt :: {CSelectStatement L.Range}
  : if '(' expr ')' stmt %shift {IfStmt (L.rtRange $1 <-> info $5) $3 $5 Nothing}
  | if '(' expr ')' stmt else stmt {IfStmt (L.rtRange $1 <->info $7) $3 $5 (Just $7)}

expr_stmt :: {CExpression L.Range}
  : ';' {% pure $ CNoOp (L.rtRange $1)}
  | expr ';' {$1}

while_loop :: {CIterStatement L.Range}
  : while '(' expr ')' block {CWhile (L.rtRange $1 <-> info $5) $3 $5}

for_loop :: {CIterStatement L.Range}
  : for '(' expr_stmt expr_stmt ')' stmt {CFor (L.rtRange $1 <-> info $6) (Just $3) (Just $4) Nothing $6}
  | for '(' expr_stmt expr_stmt expr ')' stmt {CFor (L.rtRange $1 <-> info $7) (Just $3) (Just $4) (Just $5) $7}

do_while :: {CIterStatement L.Range}
  : do stmt while '(' expr ')' ';' {CDoWhile (L.rtRange $1 <-> L.rtRange $7) $2 $5}

jump_stmt :: {CJmpStatement L.Range}
  : goto variable ';' {CGoto (L.rtRange $1 <-> L.rtRange $3) $2}
  | continue ';' {CContinue (L.rtRange $1 <-> L.rtRange $2)}
  | break ';' {CBreak (L.rtRange $1 <-> L.rtRange $2)}
  | return ';' {CReturn (L.rtRange $1 <-> L.rtRange $2) Nothing}
  | return expr ';' {CReturn (L.rtRange $1 <-> L.rtRange $3) (Just $2)}

switch_stmt :: {CSelectStatement L.Range}
  : switch '(' expr ')' stmt {SwitchStmt (L.rtRange $1 <-> info $5) $3 $5}

case_stmt :: {CCaseStatement L.Range}
  : case  expr ':' stmt {CaseStmt (L.rtRange $1 <-> info $4) $2 $4} 
  | default ':' stmt {DefaultStmt (L.rtRange $1 <-> info $3) (CDefaultTag (L.rtRange $1)) $3}

{

  -- | Build a simple node by extracting its token type and range.
unTok :: L.RangedToken -> (L.Range -> L.Token -> a) -> a
unTok (L.RangedToken tok range) ctor = ctor range tok

-- | Unsafely extracts the the metainformation field of a node.
info :: Foldable f => f a -> a
info = fromJust . getFirst . foldMap pure

infos :: Foldable f => [f L.Range] -> L.Range 
infos [x] = info x
infos (x:xs) = (info x) <-> info  (last xs)

-- | Performs the union of two ranges by creating a new range starting at the
-- start position of the first range, and stopping at the stop position of the
-- second range.
-- Invariant: The LHS range starts before the RHS range.
(<->) :: L.Range -> L.Range -> L.Range
L.Range a1 _ <-> L.Range _ b2 = L.Range a1 b2

parseError :: L.RangedToken -> L.Alex a
parseError _ = do
  (L.AlexPn _ line column, _, _, _) <- L.alexGetInput
  L.alexError $ "Parse error at line " <> show line <> ", column " <> show column

lexer :: (L.RangedToken -> L.Alex a) -> L.Alex a
lexer = (L.alexMonadScan >>=)

}
