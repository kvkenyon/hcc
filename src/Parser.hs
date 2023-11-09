{-# OPTIONS_GHC -w #-}
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
import qualified Data.Array as Happy_Data_Array
import qualified Data.Bits as Bits
import Control.Applicative(Applicative(..))
import Control.Monad (ap)

-- parser produced by Happy Version 1.20.1.1

data HappyAbsSyn 
	= HappyTerminal (L.RangedToken)
	| HappyErrorToken Prelude.Int
	| HappyAbsSyn4 (CId L.Range)
	| HappyAbsSyn5 (CExpression L.Range)

{- to allow type-synonyms as our monads (likely
 - with explicitly-specified bind and return)
 - in Haskell98, it seems that with
 - /type M a = .../, then /(HappyReduction M)/
 - is not allowed.  But Happy is a
 - code-generator that can just substitute it.
type HappyReduction m = 
	   Prelude.Int 
	-> (L.RangedToken)
	-> HappyState (L.RangedToken) (HappyStk HappyAbsSyn -> m HappyAbsSyn)
	-> [HappyState (L.RangedToken) (HappyStk HappyAbsSyn -> m HappyAbsSyn)] 
	-> HappyStk HappyAbsSyn 
	-> m HappyAbsSyn
-}

action_0,
 action_1,
 action_2,
 action_3,
 action_4,
 action_5,
 action_6,
 action_7,
 action_8,
 action_9,
 action_10,
 action_11,
 action_12,
 action_13,
 action_14,
 action_15,
 action_16,
 action_17,
 action_18,
 action_19,
 action_20,
 action_21,
 action_22,
 action_23,
 action_24,
 action_25,
 action_26,
 action_27,
 action_28,
 action_29,
 action_30,
 action_31,
 action_32,
 action_33,
 action_34,
 action_35,
 action_36,
 action_37,
 action_38,
 action_39,
 action_40,
 action_41,
 action_42,
 action_43,
 action_44,
 action_45,
 action_46,
 action_47,
 action_48,
 action_49,
 action_50,
 action_51,
 action_52,
 action_53,
 action_54,
 action_55,
 action_56,
 action_57,
 action_58,
 action_59,
 action_60,
 action_61,
 action_62,
 action_63 :: () => Prelude.Int -> ({-HappyReduction (L.Alex) = -}
	   Prelude.Int 
	-> (L.RangedToken)
	-> HappyState (L.RangedToken) (HappyStk HappyAbsSyn -> (L.Alex) HappyAbsSyn)
	-> [HappyState (L.RangedToken) (HappyStk HappyAbsSyn -> (L.Alex) HappyAbsSyn)] 
	-> HappyStk HappyAbsSyn 
	-> (L.Alex) HappyAbsSyn)

happyReduce_1,
 happyReduce_2,
 happyReduce_3,
 happyReduce_4,
 happyReduce_5,
 happyReduce_6,
 happyReduce_7,
 happyReduce_8,
 happyReduce_9,
 happyReduce_10,
 happyReduce_11,
 happyReduce_12,
 happyReduce_13,
 happyReduce_14,
 happyReduce_15,
 happyReduce_16,
 happyReduce_17,
 happyReduce_18,
 happyReduce_19,
 happyReduce_20,
 happyReduce_21,
 happyReduce_22,
 happyReduce_23,
 happyReduce_24,
 happyReduce_25,
 happyReduce_26,
 happyReduce_27,
 happyReduce_28,
 happyReduce_29,
 happyReduce_30,
 happyReduce_31,
 happyReduce_32,
 happyReduce_33,
 happyReduce_34,
 happyReduce_35,
 happyReduce_36 :: () => ({-HappyReduction (L.Alex) = -}
	   Prelude.Int 
	-> (L.RangedToken)
	-> HappyState (L.RangedToken) (HappyStk HappyAbsSyn -> (L.Alex) HappyAbsSyn)
	-> [HappyState (L.RangedToken) (HappyStk HappyAbsSyn -> (L.Alex) HappyAbsSyn)] 
	-> HappyStk HappyAbsSyn 
	-> (L.Alex) HappyAbsSyn)

happyExpList :: Happy_Data_Array.Array Prelude.Int Prelude.Int
happyExpList = Happy_Data_Array.listArray (0,425) ([7424,0,28672,49667,0,0,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,56063,28699,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,464,0,14080,3104,0,0,116,0,3520,776,0,0,29,0,880,194,0,16384,7,0,32988,48,0,53248,1,0,8247,12,0,29696,0,49152,2061,3,0,7424,0,28672,49667,0,0,1856,0,56320,12416,0,0,0,0,12288,0,0,0,0,0,3072,0,0,0,0,0,768,0,0,0,0,0,192,0,0,0,0,0,48,0,0,0,0,0,12,0,0,0,0,0,3,0,0,0,0,49152,0,0,0,464,0,14080,3104,0,0,116,0,3520,776,0,0,29,0,880,194,0,16384,7,0,32988,48,0,0,0,0,0,0,0,0,0,0,0,0,0,7424,0,28672,49667,0,0,1856,0,56320,12416,0,0,464,0,14080,3104,0,0,116,0,3520,776,0,0,29,0,880,194,0,16384,7,0,32988,48,0,53248,1,0,8247,12,0,29696,0,49152,2061,3,0,7424,0,28672,49667,0,0,1856,0,56320,12416,0,0,464,0,14080,3104,0,0,116,0,3520,776,0,0,29,0,880,194,0,16384,7,0,32988,48,0,0,0,0,55871,12299,0,0,0,49152,143,0,0,0,0,61440,35,0,0,0,0,64512,12136,448,0,0,0,16128,986,48,0,0,0,36800,0,12,0,0,0,9200,0,3,0,0,0,2300,49152,0,0,0,0,575,12288,0,0,0,49152,61583,3072,0,0,0,61440,15395,768,0,0,0,49152,0,0,0,0,0,32512,7130,112,0,0,0,36800,1782,28,0,0,0,768,0,0,0,0,0,192,0,0,0,0,0,572,0,0,0,0,0,143,0,0,0
	])

{-# NOINLINE happyExpListPerState #-}
happyExpListPerState st =
    token_strs_expected
  where token_strs = ["error","%dummy","%start_clang","variable","assign","unary","binary","expr","identifier","string","integer_const","float_const","char_const","if","else","auto","break","case","char","const","continue","default","do","double","enum","extern","float","for","int","long","register","return","short","signed","sizeof","static","struct","switch","typedef","union","unsigned","void","volatile","while","'+'","'-'","'*'","'/'","'++'","'--'","'&&'","'||'","'sizeof'","'%'","'='","'=='","'!='","'!'","'<'","'<='","'>'","'>='","'~'","'&'","'|'","'('","')'","'['","']'","'.'","':'","'->'","'<<'","'>>'","'^'","'?'","'*='","'/='","'%='","'+='","'-='","'<<='","'>>='","'&='","'|='","'^='","','","'#'","'##'","'{'","'}'","';'","'...'","%eof"]
        bit_start = st Prelude.* 94
        bit_end = (st Prelude.+ 1) Prelude.* 94
        read_bit = readArrayBit happyExpList
        bits = Prelude.map read_bit [bit_start..bit_end Prelude.- 1]
        bits_indexed = Prelude.zip bits [0..93]
        token_strs_expected = Prelude.concatMap f bits_indexed
        f (Prelude.False, _) = []
        f (Prelude.True, nr) = [token_strs Prelude.!! nr]

action_0 (9) = happyShift action_2
action_0 (11) = happyShift action_7
action_0 (12) = happyShift action_8
action_0 (13) = happyShift action_9
action_0 (45) = happyShift action_10
action_0 (46) = happyShift action_11
action_0 (47) = happyShift action_12
action_0 (49) = happyShift action_13
action_0 (50) = happyShift action_14
action_0 (58) = happyShift action_15
action_0 (63) = happyShift action_16
action_0 (64) = happyShift action_17
action_0 (4) = happyGoto action_3
action_0 (6) = happyGoto action_4
action_0 (7) = happyGoto action_5
action_0 (8) = happyGoto action_6
action_0 _ = happyFail (happyExpListPerState 0)

action_1 (9) = happyShift action_2
action_1 _ = happyFail (happyExpListPerState 1)

action_2 _ = happyReduce_1

action_3 _ = happyReduce_31

action_4 _ = happyReduce_36

action_5 _ = happyReduce_35

action_6 (45) = happyShift action_26
action_6 (46) = happyShift action_27
action_6 (47) = happyShift action_28
action_6 (48) = happyShift action_29
action_6 (49) = happyShift action_30
action_6 (50) = happyShift action_31
action_6 (51) = happyShift action_32
action_6 (52) = happyShift action_33
action_6 (54) = happyShift action_34
action_6 (56) = happyShift action_35
action_6 (57) = happyShift action_36
action_6 (59) = happyShift action_37
action_6 (60) = happyShift action_38
action_6 (61) = happyShift action_39
action_6 (62) = happyShift action_40
action_6 (64) = happyShift action_41
action_6 (65) = happyShift action_42
action_6 (73) = happyShift action_43
action_6 (74) = happyShift action_44
action_6 (75) = happyShift action_45
action_6 (94) = happyAccept
action_6 _ = happyFail (happyExpListPerState 6)

action_7 _ = happyReduce_32

action_8 _ = happyReduce_33

action_9 _ = happyReduce_34

action_10 (9) = happyShift action_2
action_10 (11) = happyShift action_7
action_10 (12) = happyShift action_8
action_10 (13) = happyShift action_9
action_10 (45) = happyShift action_10
action_10 (46) = happyShift action_11
action_10 (47) = happyShift action_12
action_10 (49) = happyShift action_13
action_10 (50) = happyShift action_14
action_10 (58) = happyShift action_15
action_10 (63) = happyShift action_16
action_10 (64) = happyShift action_17
action_10 (4) = happyGoto action_3
action_10 (6) = happyGoto action_4
action_10 (7) = happyGoto action_5
action_10 (8) = happyGoto action_25
action_10 _ = happyFail (happyExpListPerState 10)

action_11 (9) = happyShift action_2
action_11 (11) = happyShift action_7
action_11 (12) = happyShift action_8
action_11 (13) = happyShift action_9
action_11 (45) = happyShift action_10
action_11 (46) = happyShift action_11
action_11 (47) = happyShift action_12
action_11 (49) = happyShift action_13
action_11 (50) = happyShift action_14
action_11 (58) = happyShift action_15
action_11 (63) = happyShift action_16
action_11 (64) = happyShift action_17
action_11 (4) = happyGoto action_3
action_11 (6) = happyGoto action_4
action_11 (7) = happyGoto action_5
action_11 (8) = happyGoto action_24
action_11 _ = happyFail (happyExpListPerState 11)

action_12 (9) = happyShift action_2
action_12 (11) = happyShift action_7
action_12 (12) = happyShift action_8
action_12 (13) = happyShift action_9
action_12 (45) = happyShift action_10
action_12 (46) = happyShift action_11
action_12 (47) = happyShift action_12
action_12 (49) = happyShift action_13
action_12 (50) = happyShift action_14
action_12 (58) = happyShift action_15
action_12 (63) = happyShift action_16
action_12 (64) = happyShift action_17
action_12 (4) = happyGoto action_3
action_12 (6) = happyGoto action_4
action_12 (7) = happyGoto action_5
action_12 (8) = happyGoto action_23
action_12 _ = happyFail (happyExpListPerState 12)

action_13 (9) = happyShift action_2
action_13 (11) = happyShift action_7
action_13 (12) = happyShift action_8
action_13 (13) = happyShift action_9
action_13 (45) = happyShift action_10
action_13 (46) = happyShift action_11
action_13 (47) = happyShift action_12
action_13 (49) = happyShift action_13
action_13 (50) = happyShift action_14
action_13 (58) = happyShift action_15
action_13 (63) = happyShift action_16
action_13 (64) = happyShift action_17
action_13 (4) = happyGoto action_3
action_13 (6) = happyGoto action_4
action_13 (7) = happyGoto action_5
action_13 (8) = happyGoto action_22
action_13 _ = happyFail (happyExpListPerState 13)

action_14 (9) = happyShift action_2
action_14 (11) = happyShift action_7
action_14 (12) = happyShift action_8
action_14 (13) = happyShift action_9
action_14 (45) = happyShift action_10
action_14 (46) = happyShift action_11
action_14 (47) = happyShift action_12
action_14 (49) = happyShift action_13
action_14 (50) = happyShift action_14
action_14 (58) = happyShift action_15
action_14 (63) = happyShift action_16
action_14 (64) = happyShift action_17
action_14 (4) = happyGoto action_3
action_14 (6) = happyGoto action_4
action_14 (7) = happyGoto action_5
action_14 (8) = happyGoto action_21
action_14 _ = happyFail (happyExpListPerState 14)

action_15 (9) = happyShift action_2
action_15 (11) = happyShift action_7
action_15 (12) = happyShift action_8
action_15 (13) = happyShift action_9
action_15 (45) = happyShift action_10
action_15 (46) = happyShift action_11
action_15 (47) = happyShift action_12
action_15 (49) = happyShift action_13
action_15 (50) = happyShift action_14
action_15 (58) = happyShift action_15
action_15 (63) = happyShift action_16
action_15 (64) = happyShift action_17
action_15 (4) = happyGoto action_3
action_15 (6) = happyGoto action_4
action_15 (7) = happyGoto action_5
action_15 (8) = happyGoto action_20
action_15 _ = happyFail (happyExpListPerState 15)

action_16 (9) = happyShift action_2
action_16 (11) = happyShift action_7
action_16 (12) = happyShift action_8
action_16 (13) = happyShift action_9
action_16 (45) = happyShift action_10
action_16 (46) = happyShift action_11
action_16 (47) = happyShift action_12
action_16 (49) = happyShift action_13
action_16 (50) = happyShift action_14
action_16 (58) = happyShift action_15
action_16 (63) = happyShift action_16
action_16 (64) = happyShift action_17
action_16 (4) = happyGoto action_3
action_16 (6) = happyGoto action_4
action_16 (7) = happyGoto action_5
action_16 (8) = happyGoto action_19
action_16 _ = happyFail (happyExpListPerState 16)

action_17 (9) = happyShift action_2
action_17 (11) = happyShift action_7
action_17 (12) = happyShift action_8
action_17 (13) = happyShift action_9
action_17 (45) = happyShift action_10
action_17 (46) = happyShift action_11
action_17 (47) = happyShift action_12
action_17 (49) = happyShift action_13
action_17 (50) = happyShift action_14
action_17 (58) = happyShift action_15
action_17 (63) = happyShift action_16
action_17 (64) = happyShift action_17
action_17 (4) = happyGoto action_3
action_17 (6) = happyGoto action_4
action_17 (7) = happyGoto action_5
action_17 (8) = happyGoto action_18
action_17 _ = happyFail (happyExpListPerState 17)

action_18 (49) = happyShift action_30
action_18 (50) = happyShift action_31
action_18 _ = happyReduce_7

action_19 (49) = happyShift action_30
action_19 (50) = happyShift action_31
action_19 _ = happyReduce_11

action_20 (49) = happyShift action_30
action_20 (50) = happyShift action_31
action_20 _ = happyReduce_12

action_21 (49) = happyShift action_30
action_21 (50) = happyShift action_31
action_21 _ = happyReduce_5

action_22 (49) = happyShift action_30
action_22 (50) = happyShift action_31
action_22 _ = happyReduce_3

action_23 (49) = happyShift action_30
action_23 (50) = happyShift action_31
action_23 _ = happyReduce_8

action_24 (49) = happyShift action_30
action_24 (50) = happyShift action_31
action_24 _ = happyReduce_10

action_25 (49) = happyShift action_30
action_25 (50) = happyShift action_31
action_25 _ = happyReduce_9

action_26 (9) = happyShift action_2
action_26 (11) = happyShift action_7
action_26 (12) = happyShift action_8
action_26 (13) = happyShift action_9
action_26 (45) = happyShift action_10
action_26 (46) = happyShift action_11
action_26 (47) = happyShift action_12
action_26 (49) = happyShift action_13
action_26 (50) = happyShift action_14
action_26 (58) = happyShift action_15
action_26 (63) = happyShift action_16
action_26 (64) = happyShift action_17
action_26 (4) = happyGoto action_3
action_26 (6) = happyGoto action_4
action_26 (7) = happyGoto action_5
action_26 (8) = happyGoto action_63
action_26 _ = happyFail (happyExpListPerState 26)

action_27 (9) = happyShift action_2
action_27 (11) = happyShift action_7
action_27 (12) = happyShift action_8
action_27 (13) = happyShift action_9
action_27 (45) = happyShift action_10
action_27 (46) = happyShift action_11
action_27 (47) = happyShift action_12
action_27 (49) = happyShift action_13
action_27 (50) = happyShift action_14
action_27 (58) = happyShift action_15
action_27 (63) = happyShift action_16
action_27 (64) = happyShift action_17
action_27 (4) = happyGoto action_3
action_27 (6) = happyGoto action_4
action_27 (7) = happyGoto action_5
action_27 (8) = happyGoto action_62
action_27 _ = happyFail (happyExpListPerState 27)

action_28 (9) = happyShift action_2
action_28 (11) = happyShift action_7
action_28 (12) = happyShift action_8
action_28 (13) = happyShift action_9
action_28 (45) = happyShift action_10
action_28 (46) = happyShift action_11
action_28 (47) = happyShift action_12
action_28 (49) = happyShift action_13
action_28 (50) = happyShift action_14
action_28 (58) = happyShift action_15
action_28 (63) = happyShift action_16
action_28 (64) = happyShift action_17
action_28 (4) = happyGoto action_3
action_28 (6) = happyGoto action_4
action_28 (7) = happyGoto action_5
action_28 (8) = happyGoto action_61
action_28 _ = happyFail (happyExpListPerState 28)

action_29 (9) = happyShift action_2
action_29 (11) = happyShift action_7
action_29 (12) = happyShift action_8
action_29 (13) = happyShift action_9
action_29 (45) = happyShift action_10
action_29 (46) = happyShift action_11
action_29 (47) = happyShift action_12
action_29 (49) = happyShift action_13
action_29 (50) = happyShift action_14
action_29 (58) = happyShift action_15
action_29 (63) = happyShift action_16
action_29 (64) = happyShift action_17
action_29 (4) = happyGoto action_3
action_29 (6) = happyGoto action_4
action_29 (7) = happyGoto action_5
action_29 (8) = happyGoto action_60
action_29 _ = happyFail (happyExpListPerState 29)

action_30 _ = happyReduce_4

action_31 _ = happyReduce_6

action_32 (9) = happyShift action_2
action_32 (11) = happyShift action_7
action_32 (12) = happyShift action_8
action_32 (13) = happyShift action_9
action_32 (45) = happyShift action_10
action_32 (46) = happyShift action_11
action_32 (47) = happyShift action_12
action_32 (49) = happyShift action_13
action_32 (50) = happyShift action_14
action_32 (58) = happyShift action_15
action_32 (63) = happyShift action_16
action_32 (64) = happyShift action_17
action_32 (4) = happyGoto action_3
action_32 (6) = happyGoto action_4
action_32 (7) = happyGoto action_5
action_32 (8) = happyGoto action_59
action_32 _ = happyFail (happyExpListPerState 32)

action_33 (9) = happyShift action_2
action_33 (11) = happyShift action_7
action_33 (12) = happyShift action_8
action_33 (13) = happyShift action_9
action_33 (45) = happyShift action_10
action_33 (46) = happyShift action_11
action_33 (47) = happyShift action_12
action_33 (49) = happyShift action_13
action_33 (50) = happyShift action_14
action_33 (58) = happyShift action_15
action_33 (63) = happyShift action_16
action_33 (64) = happyShift action_17
action_33 (4) = happyGoto action_3
action_33 (6) = happyGoto action_4
action_33 (7) = happyGoto action_5
action_33 (8) = happyGoto action_58
action_33 _ = happyFail (happyExpListPerState 33)

action_34 (9) = happyShift action_2
action_34 (11) = happyShift action_7
action_34 (12) = happyShift action_8
action_34 (13) = happyShift action_9
action_34 (45) = happyShift action_10
action_34 (46) = happyShift action_11
action_34 (47) = happyShift action_12
action_34 (49) = happyShift action_13
action_34 (50) = happyShift action_14
action_34 (58) = happyShift action_15
action_34 (63) = happyShift action_16
action_34 (64) = happyShift action_17
action_34 (4) = happyGoto action_3
action_34 (6) = happyGoto action_4
action_34 (7) = happyGoto action_5
action_34 (8) = happyGoto action_57
action_34 _ = happyFail (happyExpListPerState 34)

action_35 (9) = happyShift action_2
action_35 (11) = happyShift action_7
action_35 (12) = happyShift action_8
action_35 (13) = happyShift action_9
action_35 (45) = happyShift action_10
action_35 (46) = happyShift action_11
action_35 (47) = happyShift action_12
action_35 (49) = happyShift action_13
action_35 (50) = happyShift action_14
action_35 (58) = happyShift action_15
action_35 (63) = happyShift action_16
action_35 (64) = happyShift action_17
action_35 (4) = happyGoto action_3
action_35 (6) = happyGoto action_4
action_35 (7) = happyGoto action_5
action_35 (8) = happyGoto action_56
action_35 _ = happyFail (happyExpListPerState 35)

action_36 (9) = happyShift action_2
action_36 (11) = happyShift action_7
action_36 (12) = happyShift action_8
action_36 (13) = happyShift action_9
action_36 (45) = happyShift action_10
action_36 (46) = happyShift action_11
action_36 (47) = happyShift action_12
action_36 (49) = happyShift action_13
action_36 (50) = happyShift action_14
action_36 (58) = happyShift action_15
action_36 (63) = happyShift action_16
action_36 (64) = happyShift action_17
action_36 (4) = happyGoto action_3
action_36 (6) = happyGoto action_4
action_36 (7) = happyGoto action_5
action_36 (8) = happyGoto action_55
action_36 _ = happyFail (happyExpListPerState 36)

action_37 (9) = happyShift action_2
action_37 (11) = happyShift action_7
action_37 (12) = happyShift action_8
action_37 (13) = happyShift action_9
action_37 (45) = happyShift action_10
action_37 (46) = happyShift action_11
action_37 (47) = happyShift action_12
action_37 (49) = happyShift action_13
action_37 (50) = happyShift action_14
action_37 (58) = happyShift action_15
action_37 (63) = happyShift action_16
action_37 (64) = happyShift action_17
action_37 (4) = happyGoto action_3
action_37 (6) = happyGoto action_4
action_37 (7) = happyGoto action_5
action_37 (8) = happyGoto action_54
action_37 _ = happyFail (happyExpListPerState 37)

action_38 (9) = happyShift action_2
action_38 (11) = happyShift action_7
action_38 (12) = happyShift action_8
action_38 (13) = happyShift action_9
action_38 (45) = happyShift action_10
action_38 (46) = happyShift action_11
action_38 (47) = happyShift action_12
action_38 (49) = happyShift action_13
action_38 (50) = happyShift action_14
action_38 (58) = happyShift action_15
action_38 (63) = happyShift action_16
action_38 (64) = happyShift action_17
action_38 (4) = happyGoto action_3
action_38 (6) = happyGoto action_4
action_38 (7) = happyGoto action_5
action_38 (8) = happyGoto action_53
action_38 _ = happyFail (happyExpListPerState 38)

action_39 (9) = happyShift action_2
action_39 (11) = happyShift action_7
action_39 (12) = happyShift action_8
action_39 (13) = happyShift action_9
action_39 (45) = happyShift action_10
action_39 (46) = happyShift action_11
action_39 (47) = happyShift action_12
action_39 (49) = happyShift action_13
action_39 (50) = happyShift action_14
action_39 (58) = happyShift action_15
action_39 (63) = happyShift action_16
action_39 (64) = happyShift action_17
action_39 (4) = happyGoto action_3
action_39 (6) = happyGoto action_4
action_39 (7) = happyGoto action_5
action_39 (8) = happyGoto action_52
action_39 _ = happyFail (happyExpListPerState 39)

action_40 (9) = happyShift action_2
action_40 (11) = happyShift action_7
action_40 (12) = happyShift action_8
action_40 (13) = happyShift action_9
action_40 (45) = happyShift action_10
action_40 (46) = happyShift action_11
action_40 (47) = happyShift action_12
action_40 (49) = happyShift action_13
action_40 (50) = happyShift action_14
action_40 (58) = happyShift action_15
action_40 (63) = happyShift action_16
action_40 (64) = happyShift action_17
action_40 (4) = happyGoto action_3
action_40 (6) = happyGoto action_4
action_40 (7) = happyGoto action_5
action_40 (8) = happyGoto action_51
action_40 _ = happyFail (happyExpListPerState 40)

action_41 (9) = happyShift action_2
action_41 (11) = happyShift action_7
action_41 (12) = happyShift action_8
action_41 (13) = happyShift action_9
action_41 (45) = happyShift action_10
action_41 (46) = happyShift action_11
action_41 (47) = happyShift action_12
action_41 (49) = happyShift action_13
action_41 (50) = happyShift action_14
action_41 (58) = happyShift action_15
action_41 (63) = happyShift action_16
action_41 (64) = happyShift action_17
action_41 (4) = happyGoto action_3
action_41 (6) = happyGoto action_4
action_41 (7) = happyGoto action_5
action_41 (8) = happyGoto action_50
action_41 _ = happyFail (happyExpListPerState 41)

action_42 (9) = happyShift action_2
action_42 (11) = happyShift action_7
action_42 (12) = happyShift action_8
action_42 (13) = happyShift action_9
action_42 (45) = happyShift action_10
action_42 (46) = happyShift action_11
action_42 (47) = happyShift action_12
action_42 (49) = happyShift action_13
action_42 (50) = happyShift action_14
action_42 (58) = happyShift action_15
action_42 (63) = happyShift action_16
action_42 (64) = happyShift action_17
action_42 (4) = happyGoto action_3
action_42 (6) = happyGoto action_4
action_42 (7) = happyGoto action_5
action_42 (8) = happyGoto action_49
action_42 _ = happyFail (happyExpListPerState 42)

action_43 (9) = happyShift action_2
action_43 (11) = happyShift action_7
action_43 (12) = happyShift action_8
action_43 (13) = happyShift action_9
action_43 (45) = happyShift action_10
action_43 (46) = happyShift action_11
action_43 (47) = happyShift action_12
action_43 (49) = happyShift action_13
action_43 (50) = happyShift action_14
action_43 (58) = happyShift action_15
action_43 (63) = happyShift action_16
action_43 (64) = happyShift action_17
action_43 (4) = happyGoto action_3
action_43 (6) = happyGoto action_4
action_43 (7) = happyGoto action_5
action_43 (8) = happyGoto action_48
action_43 _ = happyFail (happyExpListPerState 43)

action_44 (9) = happyShift action_2
action_44 (11) = happyShift action_7
action_44 (12) = happyShift action_8
action_44 (13) = happyShift action_9
action_44 (45) = happyShift action_10
action_44 (46) = happyShift action_11
action_44 (47) = happyShift action_12
action_44 (49) = happyShift action_13
action_44 (50) = happyShift action_14
action_44 (58) = happyShift action_15
action_44 (63) = happyShift action_16
action_44 (64) = happyShift action_17
action_44 (4) = happyGoto action_3
action_44 (6) = happyGoto action_4
action_44 (7) = happyGoto action_5
action_44 (8) = happyGoto action_47
action_44 _ = happyFail (happyExpListPerState 44)

action_45 (9) = happyShift action_2
action_45 (11) = happyShift action_7
action_45 (12) = happyShift action_8
action_45 (13) = happyShift action_9
action_45 (45) = happyShift action_10
action_45 (46) = happyShift action_11
action_45 (47) = happyShift action_12
action_45 (49) = happyShift action_13
action_45 (50) = happyShift action_14
action_45 (58) = happyShift action_15
action_45 (63) = happyShift action_16
action_45 (64) = happyShift action_17
action_45 (4) = happyGoto action_3
action_45 (6) = happyGoto action_4
action_45 (7) = happyGoto action_5
action_45 (8) = happyGoto action_46
action_45 _ = happyFail (happyExpListPerState 45)

action_46 (45) = happyShift action_26
action_46 (46) = happyShift action_27
action_46 (47) = happyShift action_28
action_46 (48) = happyShift action_29
action_46 (49) = happyShift action_30
action_46 (50) = happyShift action_31
action_46 (54) = happyShift action_34
action_46 (56) = happyShift action_35
action_46 (57) = happyShift action_36
action_46 (59) = happyShift action_37
action_46 (60) = happyShift action_38
action_46 (61) = happyShift action_39
action_46 (62) = happyShift action_40
action_46 (64) = happyShift action_41
action_46 (73) = happyShift action_43
action_46 (74) = happyShift action_44
action_46 _ = happyReduce_28

action_47 (45) = happyShift action_26
action_47 (46) = happyShift action_27
action_47 (47) = happyShift action_28
action_47 (48) = happyShift action_29
action_47 (49) = happyShift action_30
action_47 (50) = happyShift action_31
action_47 (54) = happyShift action_34
action_47 _ = happyReduce_19

action_48 (45) = happyShift action_26
action_48 (46) = happyShift action_27
action_48 (47) = happyShift action_28
action_48 (48) = happyShift action_29
action_48 (49) = happyShift action_30
action_48 (50) = happyShift action_31
action_48 (54) = happyShift action_34
action_48 _ = happyReduce_18

action_49 (45) = happyShift action_26
action_49 (46) = happyShift action_27
action_49 (47) = happyShift action_28
action_49 (48) = happyShift action_29
action_49 (49) = happyShift action_30
action_49 (50) = happyShift action_31
action_49 (54) = happyShift action_34
action_49 (56) = happyShift action_35
action_49 (57) = happyShift action_36
action_49 (59) = happyShift action_37
action_49 (60) = happyShift action_38
action_49 (61) = happyShift action_39
action_49 (62) = happyShift action_40
action_49 (64) = happyShift action_41
action_49 (73) = happyShift action_43
action_49 (74) = happyShift action_44
action_49 (75) = happyShift action_45
action_49 _ = happyReduce_30

action_50 (45) = happyShift action_26
action_50 (46) = happyShift action_27
action_50 (47) = happyShift action_28
action_50 (48) = happyShift action_29
action_50 (49) = happyShift action_30
action_50 (50) = happyShift action_31
action_50 (54) = happyShift action_34
action_50 (56) = happyShift action_35
action_50 (57) = happyShift action_36
action_50 (59) = happyShift action_37
action_50 (60) = happyShift action_38
action_50 (61) = happyShift action_39
action_50 (62) = happyShift action_40
action_50 (73) = happyShift action_43
action_50 (74) = happyShift action_44
action_50 _ = happyReduce_29

action_51 (45) = happyShift action_26
action_51 (46) = happyShift action_27
action_51 (47) = happyShift action_28
action_51 (48) = happyShift action_29
action_51 (49) = happyShift action_30
action_51 (50) = happyShift action_31
action_51 (54) = happyShift action_34
action_51 (59) = happyFail []
action_51 (60) = happyFail []
action_51 (61) = happyFail []
action_51 (62) = happyFail []
action_51 (73) = happyShift action_43
action_51 (74) = happyShift action_44
action_51 _ = happyReduce_22

action_52 (45) = happyShift action_26
action_52 (46) = happyShift action_27
action_52 (47) = happyShift action_28
action_52 (48) = happyShift action_29
action_52 (49) = happyShift action_30
action_52 (50) = happyShift action_31
action_52 (54) = happyShift action_34
action_52 (59) = happyFail []
action_52 (60) = happyFail []
action_52 (61) = happyFail []
action_52 (62) = happyFail []
action_52 (73) = happyShift action_43
action_52 (74) = happyShift action_44
action_52 _ = happyReduce_21

action_53 (45) = happyShift action_26
action_53 (46) = happyShift action_27
action_53 (47) = happyShift action_28
action_53 (48) = happyShift action_29
action_53 (49) = happyShift action_30
action_53 (50) = happyShift action_31
action_53 (54) = happyShift action_34
action_53 (59) = happyFail []
action_53 (60) = happyFail []
action_53 (61) = happyFail []
action_53 (62) = happyFail []
action_53 (73) = happyShift action_43
action_53 (74) = happyShift action_44
action_53 _ = happyReduce_23

action_54 (45) = happyShift action_26
action_54 (46) = happyShift action_27
action_54 (47) = happyShift action_28
action_54 (48) = happyShift action_29
action_54 (49) = happyShift action_30
action_54 (50) = happyShift action_31
action_54 (54) = happyShift action_34
action_54 (59) = happyFail []
action_54 (60) = happyFail []
action_54 (61) = happyFail []
action_54 (62) = happyFail []
action_54 (73) = happyShift action_43
action_54 (74) = happyShift action_44
action_54 _ = happyReduce_20

action_55 (45) = happyShift action_26
action_55 (46) = happyShift action_27
action_55 (47) = happyShift action_28
action_55 (48) = happyShift action_29
action_55 (49) = happyShift action_30
action_55 (50) = happyShift action_31
action_55 (54) = happyShift action_34
action_55 (56) = happyFail []
action_55 (57) = happyFail []
action_55 (59) = happyShift action_37
action_55 (60) = happyShift action_38
action_55 (61) = happyShift action_39
action_55 (62) = happyShift action_40
action_55 (73) = happyShift action_43
action_55 (74) = happyShift action_44
action_55 _ = happyReduce_25

action_56 (45) = happyShift action_26
action_56 (46) = happyShift action_27
action_56 (47) = happyShift action_28
action_56 (48) = happyShift action_29
action_56 (49) = happyShift action_30
action_56 (50) = happyShift action_31
action_56 (54) = happyShift action_34
action_56 (56) = happyFail []
action_56 (57) = happyFail []
action_56 (59) = happyShift action_37
action_56 (60) = happyShift action_38
action_56 (61) = happyShift action_39
action_56 (62) = happyShift action_40
action_56 (73) = happyShift action_43
action_56 (74) = happyShift action_44
action_56 _ = happyReduce_24

action_57 (49) = happyShift action_30
action_57 (50) = happyShift action_31
action_57 _ = happyReduce_17

action_58 (45) = happyShift action_26
action_58 (46) = happyShift action_27
action_58 (47) = happyShift action_28
action_58 (48) = happyShift action_29
action_58 (49) = happyShift action_30
action_58 (50) = happyShift action_31
action_58 (51) = happyShift action_32
action_58 (54) = happyShift action_34
action_58 (56) = happyShift action_35
action_58 (57) = happyShift action_36
action_58 (59) = happyShift action_37
action_58 (60) = happyShift action_38
action_58 (61) = happyShift action_39
action_58 (62) = happyShift action_40
action_58 (64) = happyShift action_41
action_58 (65) = happyShift action_42
action_58 (73) = happyShift action_43
action_58 (74) = happyShift action_44
action_58 (75) = happyShift action_45
action_58 _ = happyReduce_27

action_59 (45) = happyShift action_26
action_59 (46) = happyShift action_27
action_59 (47) = happyShift action_28
action_59 (48) = happyShift action_29
action_59 (49) = happyShift action_30
action_59 (50) = happyShift action_31
action_59 (54) = happyShift action_34
action_59 (56) = happyShift action_35
action_59 (57) = happyShift action_36
action_59 (59) = happyShift action_37
action_59 (60) = happyShift action_38
action_59 (61) = happyShift action_39
action_59 (62) = happyShift action_40
action_59 (64) = happyShift action_41
action_59 (65) = happyShift action_42
action_59 (73) = happyShift action_43
action_59 (74) = happyShift action_44
action_59 (75) = happyShift action_45
action_59 _ = happyReduce_26

action_60 (49) = happyShift action_30
action_60 (50) = happyShift action_31
action_60 _ = happyReduce_16

action_61 (49) = happyShift action_30
action_61 (50) = happyShift action_31
action_61 _ = happyReduce_14

action_62 (47) = happyShift action_28
action_62 (48) = happyShift action_29
action_62 (49) = happyShift action_30
action_62 (50) = happyShift action_31
action_62 (54) = happyShift action_34
action_62 _ = happyReduce_15

action_63 (47) = happyShift action_28
action_63 (48) = happyShift action_29
action_63 (49) = happyShift action_30
action_63 (50) = happyShift action_31
action_63 (54) = happyShift action_34
action_63 _ = happyReduce_13

happyReduce_1 = happySpecReduce_1  4 happyReduction_1
happyReduction_1 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn4
		 (unTok happy_var_1 (\range (L.Identifier iden) -> CId range $ BS.unpack iden)
	)
happyReduction_1 _  = notHappyAtAll 

happyReduce_2 = happySpecReduce_3  5 happyReduction_2
happyReduction_2 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.AEq) -> CAssign range (Equal range) happy_var_1 happy_var_3)
	)
happyReduction_2 _ _ _  = notHappyAtAll 

happyReduce_3 = happySpecReduce_2  6 happyReduction_3
happyReduction_3 (HappyAbsSyn5  happy_var_2)
	(HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_1 (\range (L.Inc) -> CUnary range (CPreIncOp range) happy_var_2)
	)
happyReduction_3 _ _  = notHappyAtAll 

happyReduce_4 = happySpecReduce_2  6 happyReduction_4
happyReduction_4 (HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.Inc) -> CUnary range (CPostIncOp range) happy_var_1)
	)
happyReduction_4 _ _  = notHappyAtAll 

happyReduce_5 = happySpecReduce_2  6 happyReduction_5
happyReduction_5 (HappyAbsSyn5  happy_var_2)
	(HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_1 (\range (L.Dec) -> CUnary range (CPreDecOp range) happy_var_2)
	)
happyReduction_5 _ _  = notHappyAtAll 

happyReduce_6 = happySpecReduce_2  6 happyReduction_6
happyReduction_6 (HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.Dec) -> CUnary range (CPostDecOp range) happy_var_1)
	)
happyReduction_6 _ _  = notHappyAtAll 

happyReduce_7 = happySpecReduce_2  6 happyReduction_7
happyReduction_7 (HappyAbsSyn5  happy_var_2)
	(HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_1 (\range (L.Amp) -> CUnary range (CAdrOp range) happy_var_2)
	)
happyReduction_7 _ _  = notHappyAtAll 

happyReduce_8 = happySpecReduce_2  6 happyReduction_8
happyReduction_8 (HappyAbsSyn5  happy_var_2)
	(HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_1 (\range (L.Times) -> CUnary range (CIndOp range) happy_var_2)
	)
happyReduction_8 _ _  = notHappyAtAll 

happyReduce_9 = happySpecReduce_2  6 happyReduction_9
happyReduction_9 (HappyAbsSyn5  happy_var_2)
	(HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_1 (\range (L.Plus) -> CUnary range (CPlusOp range) happy_var_2)
	)
happyReduction_9 _ _  = notHappyAtAll 

happyReduce_10 = happySpecReduce_2  6 happyReduction_10
happyReduction_10 (HappyAbsSyn5  happy_var_2)
	(HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_1 (\range (L.Minus) -> CUnary range (CMinOp range) happy_var_2)
	)
happyReduction_10 _ _  = notHappyAtAll 

happyReduce_11 = happySpecReduce_2  6 happyReduction_11
happyReduction_11 (HappyAbsSyn5  happy_var_2)
	(HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_1 (\range (L.Complement) -> CUnary range (CCompOp range) happy_var_2)
	)
happyReduction_11 _ _  = notHappyAtAll 

happyReduce_12 = happySpecReduce_2  6 happyReduction_12
happyReduction_12 (HappyAbsSyn5  happy_var_2)
	(HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_1 (\range (L.Bang) -> CUnary range (CNegOp range) happy_var_2)
	)
happyReduction_12 _ _  = notHappyAtAll 

happyReduce_13 = happySpecReduce_3  7 happyReduction_13
happyReduction_13 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.Plus) -> CBinary range (CAddOp range) happy_var_1 happy_var_3)
	)
happyReduction_13 _ _ _  = notHappyAtAll 

happyReduce_14 = happySpecReduce_3  7 happyReduction_14
happyReduction_14 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.Times) -> CBinary range (CMulOp range) happy_var_1 happy_var_3)
	)
happyReduction_14 _ _ _  = notHappyAtAll 

happyReduce_15 = happySpecReduce_3  7 happyReduction_15
happyReduction_15 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.Minus) -> CBinary range (CSubOp range) happy_var_1 happy_var_3)
	)
happyReduction_15 _ _ _  = notHappyAtAll 

happyReduce_16 = happySpecReduce_3  7 happyReduction_16
happyReduction_16 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.Div) -> CBinary range (CDivOp range) happy_var_1 happy_var_3)
	)
happyReduction_16 _ _ _  = notHappyAtAll 

happyReduce_17 = happySpecReduce_3  7 happyReduction_17
happyReduction_17 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.Mod) -> CBinary range (CRmdOp range) happy_var_1 happy_var_3)
	)
happyReduction_17 _ _ _  = notHappyAtAll 

happyReduce_18 = happySpecReduce_3  7 happyReduction_18
happyReduction_18 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.LShift) -> CBinary range (CShlOp range) happy_var_1 happy_var_3)
	)
happyReduction_18 _ _ _  = notHappyAtAll 

happyReduce_19 = happySpecReduce_3  7 happyReduction_19
happyReduction_19 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.RShift) -> CBinary range (CShrOp range) happy_var_1 happy_var_3)
	)
happyReduction_19 _ _ _  = notHappyAtAll 

happyReduce_20 = happySpecReduce_3  7 happyReduction_20
happyReduction_20 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.Le) -> CBinary range (CLeOp range) happy_var_1 happy_var_3)
	)
happyReduction_20 _ _ _  = notHappyAtAll 

happyReduce_21 = happySpecReduce_3  7 happyReduction_21
happyReduction_21 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.Gr) -> CBinary range (CGrOp range) happy_var_1 happy_var_3)
	)
happyReduction_21 _ _ _  = notHappyAtAll 

happyReduce_22 = happySpecReduce_3  7 happyReduction_22
happyReduction_22 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.GEq) -> CBinary range (CGeqOp range) happy_var_1 happy_var_3)
	)
happyReduction_22 _ _ _  = notHappyAtAll 

happyReduce_23 = happySpecReduce_3  7 happyReduction_23
happyReduction_23 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.LEq) -> CBinary range (CLeqOp range) happy_var_1 happy_var_3)
	)
happyReduction_23 _ _ _  = notHappyAtAll 

happyReduce_24 = happySpecReduce_3  7 happyReduction_24
happyReduction_24 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.Eq) -> CBinary range (CEqOp range) happy_var_1 happy_var_3)
	)
happyReduction_24 _ _ _  = notHappyAtAll 

happyReduce_25 = happySpecReduce_3  7 happyReduction_25
happyReduction_25 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.NotEq) -> CBinary range (CNeqOp range) happy_var_1 happy_var_3)
	)
happyReduction_25 _ _ _  = notHappyAtAll 

happyReduce_26 = happySpecReduce_3  7 happyReduction_26
happyReduction_26 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.LAnd) -> CBinary range (CLandOp range) happy_var_1 happy_var_3)
	)
happyReduction_26 _ _ _  = notHappyAtAll 

happyReduce_27 = happySpecReduce_3  7 happyReduction_27
happyReduction_27 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.LOr) -> CBinary range (CLorOp range) happy_var_1 happy_var_3)
	)
happyReduction_27 _ _ _  = notHappyAtAll 

happyReduce_28 = happySpecReduce_3  7 happyReduction_28
happyReduction_28 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.Or) -> CBinary range (CXorOp range) happy_var_1 happy_var_3)
	)
happyReduction_28 _ _ _  = notHappyAtAll 

happyReduce_29 = happySpecReduce_3  7 happyReduction_29
happyReduction_29 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.Amp) -> CBinary range (CAndOp range) happy_var_1 happy_var_3)
	)
happyReduction_29 _ _ _  = notHappyAtAll 

happyReduce_30 = happySpecReduce_3  7 happyReduction_30
happyReduction_30 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.Or) -> CBinary range (COrOp range) happy_var_1 happy_var_3)
	)
happyReduction_30 _ _ _  = notHappyAtAll 

happyReduce_31 = happySpecReduce_1  8 happyReduction_31
happyReduction_31 (HappyAbsSyn4  happy_var_1)
	 =  HappyAbsSyn5
		 (CVar happy_var_1
	)
happyReduction_31 _  = notHappyAtAll 

happyReduce_32 = happySpecReduce_1  8 happyReduction_32
happyReduction_32 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_1 (\range (L.IntConst int) -> CConstExpr $ IntConst range $ read $ BS.unpack int)
	)
happyReduction_32 _  = notHappyAtAll 

happyReduce_33 = happySpecReduce_1  8 happyReduction_33
happyReduction_33 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_1 (\range (L.FloatConst f) -> CConstExpr $ DblConst range $ read $ BS.unpack f)
	)
happyReduction_33 _  = notHappyAtAll 

happyReduce_34 = happySpecReduce_1  8 happyReduction_34
happyReduction_34 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_1 (\range (L.CharConst c) -> CConstExpr $ CharConst range $ read $ BS.unpack c)
	)
happyReduction_34 _  = notHappyAtAll 

happyReduce_35 = happySpecReduce_1  8 happyReduction_35
happyReduction_35 (HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (happy_var_1
	)
happyReduction_35 _  = notHappyAtAll 

happyReduce_36 = happySpecReduce_1  8 happyReduction_36
happyReduction_36 (HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (happy_var_1
	)
happyReduction_36 _  = notHappyAtAll 

happyNewToken action sts stk
	= lexer(\tk -> 
	let cont i = action i i tk (HappyState action) sts stk in
	case tk of {
	L.RangedToken L.EOF _ -> action 94 94 tk (HappyState action) sts stk;
	L.RangedToken (L.Identifier _) _ -> cont 9;
	L.RangedToken (L.StringLit _) _ -> cont 10;
	L.RangedToken (L.IntConst _) _ -> cont 11;
	L.RangedToken (L.FloatConst _) _ -> cont 12;
	L.RangedToken (L.CharConst _) _ -> cont 13;
	L.RangedToken L.If _ -> cont 14;
	L.RangedToken L.Else _ -> cont 15;
	L.RangedToken L.Auto _ -> cont 16;
	L.RangedToken L.Break _ -> cont 17;
	L.RangedToken L.Case _ -> cont 18;
	L.RangedToken L.Char _ -> cont 19;
	L.RangedToken L.Const _ -> cont 20;
	L.RangedToken L.Continue _ -> cont 21;
	L.RangedToken L.Default _ -> cont 22;
	L.RangedToken L.Do _ -> cont 23;
	L.RangedToken L.Double _ -> cont 24;
	L.RangedToken L.Enum _ -> cont 25;
	L.RangedToken L.Extern _ -> cont 26;
	L.RangedToken L.Float _ -> cont 27;
	L.RangedToken L.For _ -> cont 28;
	L.RangedToken L.Int _ -> cont 29;
	L.RangedToken L.Long _ -> cont 30;
	L.RangedToken L.Register _ -> cont 31;
	L.RangedToken L.Return _ -> cont 32;
	L.RangedToken L.Short _ -> cont 33;
	L.RangedToken L.Signed _ -> cont 34;
	L.RangedToken L.Sizeof _ -> cont 35;
	L.RangedToken L.Static _ -> cont 36;
	L.RangedToken L.Struct _ -> cont 37;
	L.RangedToken L.Switch _ -> cont 38;
	L.RangedToken L.Typedef _ -> cont 39;
	L.RangedToken L.Union _ -> cont 40;
	L.RangedToken L.Unsigned _ -> cont 41;
	L.RangedToken L.Void _ -> cont 42;
	L.RangedToken L.Volatile _ -> cont 43;
	L.RangedToken L.While _ -> cont 44;
	L.RangedToken L.Plus _ -> cont 45;
	L.RangedToken L.Minus _ -> cont 46;
	L.RangedToken L.Times _ -> cont 47;
	L.RangedToken L.Div _ -> cont 48;
	L.RangedToken L.Inc _ -> cont 49;
	L.RangedToken L.Dec _ -> cont 50;
	L.RangedToken L.LAnd _ -> cont 51;
	L.RangedToken L.LOr _ -> cont 52;
	L.RangedToken L.SizeOfOp _ -> cont 53;
	L.RangedToken L.Mod _ -> cont 54;
	L.RangedToken L.AEq _ -> cont 55;
	L.RangedToken L.Eq _ -> cont 56;
	L.RangedToken L.NotEq _ -> cont 57;
	L.RangedToken L.Bang _ -> cont 58;
	L.RangedToken L.Le _ -> cont 59;
	L.RangedToken L.LEq _ -> cont 60;
	L.RangedToken L.Gr _ -> cont 61;
	L.RangedToken L.GEq _ -> cont 62;
	L.RangedToken L.Complement _ -> cont 63;
	L.RangedToken L.Amp _ -> cont 64;
	L.RangedToken L.Or _ -> cont 65;
	L.RangedToken L.LParen _ -> cont 66;
	L.RangedToken L.RParen _ -> cont 67;
	L.RangedToken L.LBracket _ -> cont 68;
	L.RangedToken L.RBracket _ -> cont 69;
	L.RangedToken L.Dot _ -> cont 70;
	L.RangedToken L.Colon _ -> cont 71;
	L.RangedToken L.Arrow _ -> cont 72;
	L.RangedToken L.LShift _ -> cont 73;
	L.RangedToken L.RShift _ -> cont 74;
	L.RangedToken L.Xor _ -> cont 75;
	L.RangedToken L.QMark _ -> cont 76;
	L.RangedToken L.TimesEq _ -> cont 77;
	L.RangedToken L.DivEq _ -> cont 78;
	L.RangedToken L.ModEq _ -> cont 79;
	L.RangedToken L.PlusEq _ -> cont 80;
	L.RangedToken L.MinusEq _ -> cont 81;
	L.RangedToken L.LShiftEq _ -> cont 82;
	L.RangedToken L.RShiftEq _ -> cont 83;
	L.RangedToken L.AndEq _ -> cont 84;
	L.RangedToken L.OrEq _ -> cont 85;
	L.RangedToken L.XorEq _ -> cont 86;
	L.RangedToken L.Comma _ -> cont 87;
	L.RangedToken L.Pnd _ -> cont 88;
	L.RangedToken L.DblPnd _ -> cont 89;
	L.RangedToken L.LBrace _ -> cont 90;
	L.RangedToken L.RBrace _ -> cont 91;
	L.RangedToken L.SemiColon _ -> cont 92;
	L.RangedToken L.Ellipsis _ -> cont 93;
	_ -> happyError' (tk, [])
	})

happyError_ explist 94 tk = happyError' (tk, explist)
happyError_ explist _ tk = happyError' (tk, explist)

happyThen :: () => L.Alex a -> (a -> L.Alex b) -> L.Alex b
happyThen = (>>=)
happyReturn :: () => a -> L.Alex a
happyReturn = (pure)
happyThen1 :: () => L.Alex a -> (a -> L.Alex b) -> L.Alex b
happyThen1 = happyThen
happyReturn1 :: () => a -> L.Alex a
happyReturn1 = happyReturn
happyError' :: () => ((L.RangedToken), [Prelude.String]) -> L.Alex a
happyError' tk = (\(tokens, _) -> parseError tokens) tk
clang = happySomeParser where
 happySomeParser = happyThen (happyParse action_0) (\x -> case x of {HappyAbsSyn5 z -> happyReturn z; _other -> notHappyAtAll })

happySeq = happyDontSeq


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
{-# LINE 1 "templates/GenericTemplate.hs" #-}
-- $Id: GenericTemplate.hs,v 1.26 2005/01/14 14:47:22 simonmar Exp $










































data Happy_IntList = HappyCons Prelude.Int Happy_IntList








































infixr 9 `HappyStk`
data HappyStk a = HappyStk a (HappyStk a)

-----------------------------------------------------------------------------
-- starting the parse

happyParse start_state = happyNewToken start_state notHappyAtAll notHappyAtAll

-----------------------------------------------------------------------------
-- Accepting the parse

-- If the current token is ERROR_TOK, it means we've just accepted a partial
-- parse (a %partial parser).  We must ignore the saved token on the top of
-- the stack in this case.
happyAccept (1) tk st sts (_ `HappyStk` ans `HappyStk` _) =
        happyReturn1 ans
happyAccept j tk st sts (HappyStk ans _) = 
         (happyReturn1 ans)

-----------------------------------------------------------------------------
-- Arrays only: do the next action









































indexShortOffAddr arr off = arr Happy_Data_Array.! off


{-# INLINE happyLt #-}
happyLt x y = (x Prelude.< y)






readArrayBit arr bit =
    Bits.testBit (indexShortOffAddr arr (bit `Prelude.div` 16)) (bit `Prelude.mod` 16)






-----------------------------------------------------------------------------
-- HappyState data type (not arrays)



newtype HappyState b c = HappyState
        (Prelude.Int ->                    -- token number
         Prelude.Int ->                    -- token number (yes, again)
         b ->                           -- token semantic value
         HappyState b c ->              -- current state
         [HappyState b c] ->            -- state stack
         c)



-----------------------------------------------------------------------------
-- Shifting a token

happyShift new_state (1) tk st sts stk@(x `HappyStk` _) =
     let i = (case x of { HappyErrorToken (i) -> i }) in
--     trace "shifting the error token" $
     new_state i i tk (HappyState (new_state)) ((st):(sts)) (stk)

happyShift new_state i tk st sts stk =
     happyNewToken new_state ((st):(sts)) ((HappyTerminal (tk))`HappyStk`stk)

-- happyReduce is specialised for the common cases.

happySpecReduce_0 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_0 nt fn j tk st@((HappyState (action))) sts stk
     = action nt j tk st ((st):(sts)) (fn `HappyStk` stk)

happySpecReduce_1 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_1 nt fn j tk _ sts@(((st@(HappyState (action))):(_))) (v1`HappyStk`stk')
     = let r = fn v1 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_2 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_2 nt fn j tk _ ((_):(sts@(((st@(HappyState (action))):(_))))) (v1`HappyStk`v2`HappyStk`stk')
     = let r = fn v1 v2 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_3 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_3 nt fn j tk _ ((_):(((_):(sts@(((st@(HappyState (action))):(_))))))) (v1`HappyStk`v2`HappyStk`v3`HappyStk`stk')
     = let r = fn v1 v2 v3 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happyReduce k i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyReduce k nt fn j tk st sts stk
     = case happyDrop (k Prelude.- ((1) :: Prelude.Int)) sts of
         sts1@(((st1@(HappyState (action))):(_))) ->
                let r = fn stk in  -- it doesn't hurt to always seq here...
                happyDoSeq r (action nt j tk st1 sts1 r)

happyMonadReduce k nt fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyMonadReduce k nt fn j tk st sts stk =
      case happyDrop k ((st):(sts)) of
        sts1@(((st1@(HappyState (action))):(_))) ->
          let drop_stk = happyDropStk k stk in
          happyThen1 (fn stk tk) (\r -> action nt j tk st1 sts1 (r `HappyStk` drop_stk))

happyMonad2Reduce k nt fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyMonad2Reduce k nt fn j tk st sts stk =
      case happyDrop k ((st):(sts)) of
        sts1@(((st1@(HappyState (action))):(_))) ->
         let drop_stk = happyDropStk k stk





             _ = nt :: Prelude.Int
             new_state = action

          in
          happyThen1 (fn stk tk) (\r -> happyNewToken new_state sts1 (r `HappyStk` drop_stk))

happyDrop (0) l = l
happyDrop n ((_):(t)) = happyDrop (n Prelude.- ((1) :: Prelude.Int)) t

happyDropStk (0) l = l
happyDropStk n (x `HappyStk` xs) = happyDropStk (n Prelude.- ((1)::Prelude.Int)) xs

-----------------------------------------------------------------------------
-- Moving to a new state after a reduction









happyGoto action j tk st = action j j tk (HappyState action)


-----------------------------------------------------------------------------
-- Error recovery (ERROR_TOK is the error token)

-- parse error if we are in recovery and we fail again
happyFail explist (1) tk old_st _ stk@(x `HappyStk` _) =
     let i = (case x of { HappyErrorToken (i) -> i }) in
--      trace "failing" $ 
        happyError_ explist i tk

{-  We don't need state discarding for our restricted implementation of
    "error".  In fact, it can cause some bogus parses, so I've disabled it
    for now --SDM

-- discard a state
happyFail  ERROR_TOK tk old_st CONS(HAPPYSTATE(action),sts) 
                                                (saved_tok `HappyStk` _ `HappyStk` stk) =
--      trace ("discarding state, depth " ++ show (length stk))  $
        DO_ACTION(action,ERROR_TOK,tk,sts,(saved_tok`HappyStk`stk))
-}

-- Enter error recovery: generate an error token,
--                       save the old token and carry on.
happyFail explist i tk (HappyState (action)) sts stk =
--      trace "entering error recovery" $
        action (1) (1) tk (HappyState (action)) sts ((HappyErrorToken (i)) `HappyStk` stk)

-- Internal happy errors:

notHappyAtAll :: a
notHappyAtAll = Prelude.error "Internal Happy error\n"

-----------------------------------------------------------------------------
-- Hack to get the typechecker to accept our action functions







-----------------------------------------------------------------------------
-- Seq-ing.  If the --strict flag is given, then Happy emits 
--      happySeq = happyDoSeq
-- otherwise it emits
--      happySeq = happyDontSeq

happyDoSeq, happyDontSeq :: a -> b -> b
happyDoSeq   a b = a `Prelude.seq` b
happyDontSeq a b = b

-----------------------------------------------------------------------------
-- Don't inline any functions from the template.  GHC has a nasty habit
-- of deciding to inline happyGoto everywhere, which increases the size of
-- the generated parser quite a bit.









{-# NOINLINE happyShift #-}
{-# NOINLINE happySpecReduce_0 #-}
{-# NOINLINE happySpecReduce_1 #-}
{-# NOINLINE happySpecReduce_2 #-}
{-# NOINLINE happySpecReduce_3 #-}
{-# NOINLINE happyReduce #-}
{-# NOINLINE happyMonadReduce #-}
{-# NOINLINE happyGoto #-}
{-# NOINLINE happyFail #-}

-- end of Happy Template.
