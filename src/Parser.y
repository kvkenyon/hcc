{
{-# LANGUAGE DeriveFoldable #-}
module Parser
  ( clang 
  ) where

import Data.ByteString.Lazy.Char8 (ByteString)
import Data.Maybe (fromJust)
import Data.Monoid (First (..))
import Syntax

import qualified Lexer as L
}

%name clang
%tokentype { L.RangedToken }
%error { parseError }
%monad { L.Alex } { >>= } { pure }
%lexer { lexer } { L.RangedToken L.EOF _ }
%token
  -- Identifiers
  identifier { L.RangedToken (L.Identifier _) _ }
  -- Constants
  string { L.RangedToken (L.StringLit _) _ }
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
  default       { L.RangedToken L.Default _}
  do       { L.RangedToken L.Do _}
  double       { L.RangedToken L.Double _}
  enum       { L.RangedToken L.Enum _}
  extern       { L.RangedToken L.Extern _}
  float       { L.RangedToken L.Float _}
  for       { L.RangedToken L.For _}
  int       { L.RangedToken L.Int _}
  long       { L.RangedToken L.Long _}
  register       { L.RangedToken L.Register _}
  return       { L.RangedToken L.Return _}
  short       { L.RangedToken L.Short _}
  signed       { L.RangedToken L.Signed _}
  sizeof       { L.RangedToken L.Sizeof _}
  static       { L.RangedToken L.Static _}
  struct      { L.RangedToken L.Struct _}
  switch       { L.RangedToken L.Switch _}
  typedef       { L.RangedToken L.Typedef _}
  union       { L.RangedToken L.Union _}
  unsigned       { L.RangedToken L.Unsigned _}
  void       { L.RangedToken L.Void _}
  volatile       { L.RangedToken L.Volatile _}
  while       { L.RangedToken L.While _}
  '+'        { L.RangedToken L.Plus _ }
  '-'        { L.RangedToken L.Minus _ }
  '*'        { L.RangedToken L.Times _ }
  '/'        { L.RangedToken L.Div _ }
  '++'        { L.RangedToken L.Inc _ }
  '--'        { L.RangedToken L.Dec _ }
  '&&'        { L.RangedToken L.LAnd _ }
  '||'        { L.RangedToken L.LOr _ }
  'sizeof'        { L.RangedToken L.SizeOfOp _ }
  '%'        { L.RangedToken L.Mod _ }
  '='        { L.RangedToken L.AEq _ }
  '=='        { L.RangedToken L.Eq _ }
  '!='       { L.RangedToken L.NotEq _ }
  '!'       { L.RangedToken L.Bang _ }
  '<'        { L.RangedToken L.Le _ }
  '<='       { L.RangedToken L.LEq _ }
  '>'        { L.RangedToken L.Gr _ }
  '>='       { L.RangedToken L.GEq _ }
  '~'       { L.RangedToken L.Complement _ }
  '&'        { L.RangedToken L.And _ }
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
  '^'       { L.RangedToken L.Xor _ }
  '?'       { L.RangedToken L.QMark _ }
  '*='       { L.RangedToken L.TimesEq _ }
  '%='       { L.RangedToken L.DivEq _ }
  '+='       { L.RangedToken L.PlusEq _ }
  '-='       { L.RangedToken L.MinusEq _ }
  '<<='       { L.RangedToken L.LShiftEq _ }
  '>>='       { L.RangedToken L.RShiftEq _ }
  '&='       { L.RangedToken L.AndEq _ }
  '|='       { L.RangedToken L.OrEq _ }
  '^='       { L.RangedToken L.XorEq _ }
  ','       { L.RangedToken L.Comma _ }
  '#'       { L.RangedToken L.Pnd _ }
  '##'       { L.RangedToken L.DblPnd _ }
  '{'       { L.RangedToken L.LBrace _ }
  '}'       { L.RangedToken L.RBrace _ }
  ';'       { L.RangedToken L.SemiColon _ }
  '...'       { L.RangedToken L.Ellipsis _ }
%%

empty : {}  -- only to get the file compiling; we will remove this

{
parseError :: L.RangedToken -> L.Alex a
parseError _ = do
  (L.AlexPn _ line column, _, _, _) <- L.alexGetInput
  L.alexError $ "Parse error at line " <> show line <> ", column " <> show column

lexer :: (L.RangedToken -> L.Alex a) -> L.Alex a
lexer = (=<< L.alexMonadScan)
}
