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
  ) where

import Data.ByteString.Lazy.Char8 (ByteString)
import qualified Data.ByteString.Lazy.Char8 as BS
}


-- In the middle, we insert our definitions for the lexer, which will generate the lexemes for our grammar.
%wrapper "monadUserState-bytestring"

$digit = [0-9]
$alpha = [a-zA-Z]

@id = ($alpha | \_) ($alpha | $digit | \_ | \' | \?)*

tokens :-

-- Identifiers

-- Keywords

-- Constatns

-- Strings

-- Ops

-- Separators (blanks, tabs, newlines, formfeeds and comments (Whitespace)

-- 

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
  -- Constants
  Integer Int |
  String ByteString |
  Floating Double |
  Enumeration ByteString |
  EOF
  deriving (Eq, Show)
} 