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

  , Range (..)
  , RangedToken (..)
  , Token (..)
  , scanMany,
  ) where

import Data.Text (Text)
import qualified Data.Text as T

import Data.ByteString.Lazy.Char8 (ByteString)
import qualified Data.ByteString.Lazy.Char8 as BS
}


-- In the middle, we insert our definitions for the lexer, which will generate the lexemes for our grammar.
%wrapper "monadUserState-bytestring"

$digit = [0-9]
$alpha = [a-zA-Z]
$char = $printable 
$escape_chars = [ \' \" \\ abfnrt ]

$octdig = [0-7]
$hexdig = [0-9A-Fa-f]
$floating_suffix = [flFL]
$exponent_suffix = [eE]


-- Numerical Lexemes
-- Integers
@decinteger = (0 | [1-9]([$digit])*)
@hexinteger   = ([0][xX]($hexdig)+)
@octinteger = (0[oO]($octdig)+)
@integer = (@decinteger | @hexinteger | @octinteger)
@unsigned_int = (Uu @integer)
@long_int = (Ll @integer)
@unsigned_long_int = ("UL" @integer)
@integer_const = @integer | @unsigned_int | @long_int | @unsigned_long_int 

-- Floating 
@@sign = "+"|"-"
@exponent_part = $exponent_suffix  @sign? $digit+
@fractional_const= ($digit+ . $digit+) | (. $digit+)
@floating_point_const = (@fractional_const @exponent_part? $floating_suffix?) | ((digit+) @exponent_part $floating_suffix?)

-- Char Lexical Grammar
@escape_seq = ("\\" $escape_chars) | ("\\" $octdig+ $octdig+ $octdig) | ("\x" $hexdig+)
@char_const = (\' ($char | @escape_seq)* \') 


-- Identifier
@id = ($alpha | \_) ($alpha | $digit | \_ | \' | \?)*


tokens :-
-- Constants 
<0> @integer_const  { tokInteger }
<0> @char_const { tokChar }
<0> @floating_point_const {tokFloat}
-- Keywords
<0> auto {tok Auto}
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
-- Operators
<0> "+" {tok Plus}
<0> "="  {tok Eq}
-- Strings

-- Identifier
<0> @id     { tokId }
-- Whitespace
<0> $white+ ;
{

-- At the bottom, we may insert more Haskell definitions, such as data structures, auxiliary functions, etc.
data AlexUserState = AlexUserState
  {
  }

alexInitUserState :: AlexUserState
alexInitUserState = AlexUserState

alexEOF :: Alex RangedToken
alexEOF = do
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
  Eq |
  Plus |
  Minus |
  LAnd |
  LOr |
  Neg |
  -- Constants
  Integer Int |
  CharConst ByteString |
  String ByteString |
  Floating Double |
  Enumeration ByteString |
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
    { rtToken = Integer $ read $ BS.unpack $ BS.take len str
    , rtRange = mkRange inp len
    }

tokFloat :: AlexAction RangedToken
tokFloat inp@(_, _, str, _) len =
  pure RangedToken
    { rtToken = Floating $ read $ BS.unpack $ BS.take len str
    , rtRange = mkRange inp len
    }

tokChar :: AlexAction RangedToken
tokChar inp@(_, _, str, _) len =
  pure RangedToken
    {
      rtToken = CharConst $ BS.take len str
    , rtRange = mkRange inp len
    }
} 