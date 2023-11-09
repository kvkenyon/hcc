{
-- At the top of the file, we define the module and its imports, similarly to Haskell.
module Lexer
  ( -- * Invoking Alex
    Alex
  , AlexPosn (..)
  , alexGetInput
  , alexError
  , runAlex
  , alexMonadScan
  , alexGetStartCode

  , Range (..)
  , RangedToken (..)
  , Token (..)
  , scanMany,
  ) where

import Data.Text (Text)
import qualified Data.Text as T
import Control.Monad (when)
import Data.ByteString.Lazy.Char8 (ByteString)
import qualified Data.ByteString.Lazy.Char8 as BS
}

-- In the middle, we insert our definitions for the lexer, which will generate the lexemes for our grammar.
%wrapper "monadUserState-bytestring"

$digit = [0-9]
$alpha = [a-zA-Z]
$char = $printable
$escape_chars = [ \' \" \\ [abfnrt] ]

$octdig = [0-7]
$hexdig = [0-9A-Fa-f]
$floating_suffix = [flFL]
$exponent_suffix = [eE]
$u = [U]
$l = [L]

-- Numerical Lexemes
-- Integers
@decinteger = (0 | [1-9]([$digit])*)
@hexinteger   = ([0][xX]($hexdig)+)
@octinteger = (0[oO]($octdig)+)
@integer = (@decinteger | @hexinteger | @octinteger)
@unsigned_int = ([Uu]@integer)
@long_int = ([Ll]@integer)
@unsigned_long_int = ( @integer)

-- Floating 
@@sign = "+"|"-"
@exponent_part = $exponent_suffix  @sign? @decinteger+
@fractional_const= (@decinteger+ "." @decinteger*) | (@decinteger* "." @decinteger+)
@floating_point_const = (@fractional_const @exponent_part? $floating_suffix?) | (@decinteger @exponent_part $floating_suffix?)

-- Char Lexical Grammar
@escape_seq = ("\\" $escape_chars) | ("\\" $octdig+ $octdig+ $octdig) | ("\x" $hexdig+)
@char_const = (\' ($char | @escape_seq)* \') 

-- Identifier
@id = ($alpha | \_) ($alpha | $digit | \_ | \' | \?)*

-- String Literals
@string_literal = (\" ($char | @escape_seq)* \") | (L \"($char | @escape_seq)*  \")

tokens :-
-- Constants 
<0> @floating_point_const {tokFloat}
<0> "UL"@integer {tokInteger}
<0> @integer { tokInteger }
<0> @long_int {tokInteger}
<0> @unsigned_int {tokInteger}
<0> @char_const { tokChar }
-- Keywords
<0> auto {tok Auto}
<0> break {tok Break}
<0> case {tok Case}
<0> char {tok Char}
<0> const {tok Const}
<0> continue {tok Continue}
<0> default {tok Default}
<0> do {tok Do}
<0> double {tok Double}
<0> else {tok Else}
<0> enum {tok Enum}
<0> extern {tok Extern}
<0> float {tok Float}
<0> for {tok For}
<0> goto {tok Goto}
<0> if {tok If}
<0> int {tok Int}
<0> long {tok Long}
<0> register {tok Register}
<0> return {tok Return}
<0> short {tok Short}
<0> signed {tok Signed}
<0> sizeof {tok Sizeof}
<0> static {tok Static}
<0> struct {tok Struct}
<0> switch {tok Switch}
<0> typedef {tok Typedef}
<0> union {tok Union}
<0> unsigned {tok Unsigned}
<0> void {tok Void}
<0> volatile = {tok Volatile}
<0> while = {tok While}
-- Operators/Punctuators
<0> "+" {tok Plus}
<0> "-" {tok Minus}
<0> "*" {tok Times}
<0> "!" {tok Bang}
<0> "&&" {tok LAnd}
<0> "||" {tok LOr}
<0> "~" {tok Complement}
<0> "[" {tok LBracket}
<0> "]" {tok RBracket}
<0> "(" {tok LParen}
<0> ")" {tok RParen}
<0> "." {tok Dot}
<0> "->" {tok Arrow}
<0> "++" {tok Inc}
<0> "--" {tok Dec}
<0> "&" {tok Amp}
<0> "sizeof" {tok SizeOfOp}
<0> "/" {tok Div}
<0> "%" {tok Mod}
<0> "<<" {tok LShift}
<0> ">>" {tok RShift}
<0> "==" {tok Eq}
<0> "<=" {tok Le}
<0> ">" {tok Gr}
<0> "<=" {tok LEq}
<0> ">=" {tok GEq}
<0> "!=" {tok NotEq}
<0> "^" {tok Xor}
<0> "?" {tok QMark}
<0> ":" {tok Colon}
<0> "="  {tok AEq}
<0> "*="  {tok TimesEq}
<0> "/="  {tok DivEq}
<0> "%="  {tok ModEq}
<0> "+="  {tok PlusEq}
<0> "-="  {tok MinusEq}
<0> "<<="  {tok LShiftEq}
<0> ">>="  {tok RShiftEq}
<0> "&=" {tok AndEq}
<0> "|=" {tok OrEq}
<0> "^=" {tok XorEq}
<0> "," {tok Comma}
<0> "#" {tok Pnd}
<0> "##" {tok DblPnd}
<0> "{" {tok LBrace}
<0> "}" {tok RBrace}
<0> "*" {tok Star}
<0> ";" {tok SemiColon}
<0> "..." {tok Ellipsis}
-- Strings
<0> @string_literal { tokStringLit }
-- Identifier
<0> @id     { tokId }

-- Comments
<0>       "/*" { nestComment `andBegin` comment }
<0>       "*/" { \_ _ -> alexError "Error: unexpected closing comment" }
<comment> "/*" { nestComment }
<comment> "*/" { unnestComment }
<comment> .    ;
<comment> \n   ;

-- Whitespace
<0> $white+ ;
{

data AlexUserState = AlexUserState
  { nestLevel :: Int
  }

alexInitUserState :: AlexUserState
alexInitUserState = AlexUserState
  { nestLevel = 0
  }

get :: Alex AlexUserState
get = Alex $ \s -> Right (s, alex_ust s)

put :: AlexUserState -> Alex ()
put s' = Alex $ \s -> Right (s{alex_ust = s'}, ())

modify :: (AlexUserState -> AlexUserState) -> Alex ()
modify f = Alex $ \s -> Right (s{alex_ust = f (alex_ust s)}, ())

alexEOF :: Alex RangedToken
alexEOF = do
  startCode <- alexGetStartCode
  when (startCode == comment) $
    alexError "Error: unclosed comment"
  (pos, _, _, _) <- alexGetInput
  pure $ RangedToken EOF (Range pos pos)

data Range = Range
  { start :: AlexPosn
  , stop :: AlexPosn
  } deriving (Eq, Show)

data RangedToken = RangedToken
  { rtToken :: Token
  , rtRange :: Range
  } deriving (Eq, Show)

data Token =
  Identifier ByteString |
  -- Keywords
  Auto |
  Break |
  Case | 
  Char | 
  Const | 
  Continue | 
  Default | 
  Do | 
  Double | 
  Else | 
  Enum | 
  Extern | 
  Float | 
  For | 
  Goto | 
  If | 
  Int | 
  Long | 
  Register | 
  Return | 
  Short | 
  Signed | 
  Sizeof | 
  Static | 
  Struct | 
  Switch | 
  Typedef | 
  Union | 
  Unsigned | 
  Void | 
  Volatile | 
  While |
  -- Operators
  Plus |
  Minus |
  Times |
  Bang |
  LAnd |
  LOr |
  Complement|
  LBracket |
  RBracket |
  LParen |
  RParen |
  Dot |
  Arrow |
  Inc |
  Dec |
  Amp |
  SizeOfOp |
  Div |
  Mod |
  LShift |
  RShift |
  Eq |
  Le |
  Gr |
  LEq |
  GEq |
  NotEq |
  Xor |
  Or |
  QMark |
  Colon |
  AEq |
  TimesEq |
  DivEq |
  ModEq |
  PlusEq |
  MinusEq |
  LShiftEq |
  RShiftEq |
  AndEq |
  XorEq |
  OrEq |
  Comma |
  Pnd |
  DblPnd | 
  -- Punctuators
  LBrace |
  RBrace |
  Star |
  SemiColon |
  Ellipsis |
  -- Constants
  IntConst ByteString |
  CharConst ByteString |
  StringLit ByteString |
  FloatConst ByteString |
  EnumConst ByteString |
  EOF
  deriving (Eq, Show)

mkRange :: AlexInput -> Int64 -> Range
mkRange (start, _, str, _) len = Range{start = start, stop = stop}
  where
    stop = BS.foldl' alexMove start $ BS.take len str

scanMany :: ByteString -> Either String [RangedToken]
scanMany input = runAlex input go
  where
    go = do
      output <- alexMonadScan
      if rtToken output == EOF
        then pure [output]
        else (output :) <$> go

tok :: Token -> AlexAction RangedToken
tok ctor inp len =
  pure RangedToken
    { rtToken = ctor
    , rtRange = mkRange inp len
    }

tokId :: AlexAction RangedToken
tokId inp@(_, _, str, _) len =
  pure RangedToken
    { rtToken = Identifier $ BS.take len str
    , rtRange = mkRange inp len
    }

tokInteger :: AlexAction RangedToken
tokInteger inp@(_, _, str, _) len =
  pure RangedToken
    { rtToken =  IntConst $ BS.take len str
    , rtRange = mkRange inp len
    }

tokFloat :: AlexAction RangedToken
tokFloat inp@(_, _, str, _) len =
  pure RangedToken
    { rtToken = FloatConst $ BS.take len str
    , rtRange = mkRange inp len
    }

tokChar :: AlexAction RangedToken
tokChar inp@(_, _, str, _) len =
  pure RangedToken
    {
      rtToken = CharConst $ BS.take len str
    , rtRange = mkRange inp len
    }

tokStringLit :: AlexAction RangedToken
tokStringLit inp@(_, _, str, _) len =
  pure RangedToken
    {
      rtToken = StringLit $ BS.take len str
    , rtRange = mkRange inp len
    }

nestComment, unnestComment :: AlexAction RangedToken
nestComment input len = do
  modify $ \s -> s{nestLevel = nestLevel s + 1}
  skip input len
unnestComment input len = do
  state <- get
  let level = nestLevel state - 1
  put state{nestLevel = level}
  when (level == 0) $
    alexSetStartCode 0
  skip input len

} 