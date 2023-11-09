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

%name clang expr
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
  'sizeof'   { L.RangedToken L.SizeOfOp _ }
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
-- %left ','
-- %right '=' '+=' '-=' '/=' '%=' '<<=' '>>=' '&=' 
-- %right TERN
-- %left '||'
--- %left BAND XOR
-- %right '~' 
-- %right PRE PLUS MINUS INDIRECT '&'  '!'
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
%right PRE DRF ADR POS NEG '~' '!'
%left '++' '--' 
%%


variable :: { CId L.Range }
  : identifier { unTok $1 (\range (L.Identifier iden) -> CId range $ BS.unpack iden) }

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
  | expr '^' expr {unTok $2 (\range (L.Or) -> CBinary range (CLorOp range) $1 $3)}
  | expr '&' expr {unTok $2 (\range (L.Amp) -> CBinary range (CAndOp range) $1 $3)}
  | expr '|' expr {unTok $2 (\range (L.Or) -> CBinary range (CLorOp range) $1 $3)}
   

-- TODO: Update types to handle weird c-types like char const with multiple chars
expr :: {CExpression L.Range }
  : variable {CVar $1}
  | integer_const {unTok $1 (\range (L.IntConst int) -> CConstExpr $ IntConst range $ read $ BS.unpack int)}
  | float_const {unTok $1 (\range (L.FloatConst f) -> CConstExpr $ DblConst range $ read $ BS.unpack f)}
  | char_const {unTok $1 (\range (L.CharConst c) -> CConstExpr $ CharConst range $ read $ BS.unpack c)}
  | binary {$1}
  | unary {$1}
{
  -- | Build a simple node by extracting its token type and range.
unTok :: L.RangedToken -> (L.Range -> L.Token -> a) -> a
unTok (L.RangedToken tok range) ctor = ctor range tok

-- | Unsafely extracts the the metainformation field of a node.
info :: Foldable f => f a -> a
info = fromJust . getFirst . foldMap pure

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
lexer = (=<< L.alexMonadScan)
}
