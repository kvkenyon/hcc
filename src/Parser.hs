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
 action_25 :: () => Prelude.Int -> ({-HappyReduction (L.Alex) = -}
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
 happyReduce_16 :: () => ({-HappyReduction (L.Alex) = -}
	   Prelude.Int 
	-> (L.RangedToken)
	-> HappyState (L.RangedToken) (HappyStk HappyAbsSyn -> (L.Alex) HappyAbsSyn)
	-> [HappyState (L.RangedToken) (HappyStk HappyAbsSyn -> (L.Alex) HappyAbsSyn)] 
	-> HappyStk HappyAbsSyn 
	-> (L.Alex) HappyAbsSyn)

happyExpList :: Happy_Data_Array.Array Prelude.Int Prelude.Int
happyExpList = Happy_Data_Array.listArray (0,133) ([3712,0,43008,16385,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,424,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32768,14,0,424,64,0,59392,0,32768,26,4,0,3712,0,43008,16385,0,0,232,0,6784,1024,0,32768,14,0,424,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,384,0,0,0,0,0,26,0,0,3712,0,43008,16385,0,0,232,0,6784,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32768,1,0,0,0,0,6656,0,0,0,0
	])

{-# NOINLINE happyExpListPerState #-}
happyExpListPerState st =
    token_strs_expected
  where token_strs = ["error","%dummy","%start_clang","variable","unary","binary","expr","identifier","string","integer_const","float_const","char_const","if","else","auto","break","case","char","const","continue","default","do","double","enum","extern","float","for","int","long","register","return","short","signed","sizeof","static","struct","switch","typedef","union","unsigned","void","volatile","while","'+'","'-'","'*'","'/'","'++'","'--'","'&&'","'||'","'sizeof'","'%'","'='","'=='","'!='","'!'","'<'","'<='","'>'","'>='","'~'","'&'","'|'","'('","')'","'['","']'","'.'","':'","'->'","'<<'","'>>'","'^'","'?'","'*='","'%='","'+='","'-='","'<<='","'>>='","'&='","'|='","'^='","','","'#'","'##'","'{'","'}'","';'","'...'","%eof"]
        bit_start = st Prelude.* 92
        bit_end = (st Prelude.+ 1) Prelude.* 92
        read_bit = readArrayBit happyExpList
        bits = Prelude.map read_bit [bit_start..bit_end Prelude.- 1]
        bits_indexed = Prelude.zip bits [0..91]
        token_strs_expected = Prelude.concatMap f bits_indexed
        f (Prelude.False, _) = []
        f (Prelude.True, nr) = [token_strs Prelude.!! nr]

action_0 (8) = happyShift action_2
action_0 (10) = happyShift action_7
action_0 (11) = happyShift action_8
action_0 (12) = happyShift action_9
action_0 (44) = happyShift action_10
action_0 (46) = happyShift action_11
action_0 (48) = happyShift action_12
action_0 (49) = happyShift action_13
action_0 (63) = happyShift action_14
action_0 (4) = happyGoto action_3
action_0 (5) = happyGoto action_4
action_0 (6) = happyGoto action_5
action_0 (7) = happyGoto action_6
action_0 _ = happyFail (happyExpListPerState 0)

action_1 (8) = happyShift action_2
action_1 _ = happyFail (happyExpListPerState 1)

action_2 _ = happyReduce_1

action_3 _ = happyReduce_11

action_4 _ = happyReduce_16

action_5 _ = happyReduce_15

action_6 (44) = happyShift action_20
action_6 (46) = happyShift action_21
action_6 (48) = happyShift action_22
action_6 (49) = happyShift action_23
action_6 (92) = happyAccept
action_6 _ = happyFail (happyExpListPerState 6)

action_7 _ = happyReduce_12

action_8 _ = happyReduce_13

action_9 _ = happyReduce_14

action_10 (8) = happyShift action_2
action_10 (10) = happyShift action_7
action_10 (11) = happyShift action_8
action_10 (12) = happyShift action_9
action_10 (44) = happyShift action_10
action_10 (46) = happyShift action_11
action_10 (48) = happyShift action_12
action_10 (49) = happyShift action_13
action_10 (63) = happyShift action_14
action_10 (4) = happyGoto action_3
action_10 (5) = happyGoto action_4
action_10 (6) = happyGoto action_5
action_10 (7) = happyGoto action_19
action_10 _ = happyFail (happyExpListPerState 10)

action_11 (8) = happyShift action_2
action_11 (10) = happyShift action_7
action_11 (11) = happyShift action_8
action_11 (12) = happyShift action_9
action_11 (44) = happyShift action_10
action_11 (46) = happyShift action_11
action_11 (48) = happyShift action_12
action_11 (49) = happyShift action_13
action_11 (63) = happyShift action_14
action_11 (4) = happyGoto action_3
action_11 (5) = happyGoto action_4
action_11 (6) = happyGoto action_5
action_11 (7) = happyGoto action_18
action_11 _ = happyFail (happyExpListPerState 11)

action_12 (8) = happyShift action_2
action_12 (10) = happyShift action_7
action_12 (11) = happyShift action_8
action_12 (12) = happyShift action_9
action_12 (44) = happyShift action_10
action_12 (46) = happyShift action_11
action_12 (48) = happyShift action_12
action_12 (49) = happyShift action_13
action_12 (63) = happyShift action_14
action_12 (4) = happyGoto action_3
action_12 (5) = happyGoto action_4
action_12 (6) = happyGoto action_5
action_12 (7) = happyGoto action_17
action_12 _ = happyFail (happyExpListPerState 12)

action_13 (8) = happyShift action_2
action_13 (10) = happyShift action_7
action_13 (11) = happyShift action_8
action_13 (12) = happyShift action_9
action_13 (44) = happyShift action_10
action_13 (46) = happyShift action_11
action_13 (48) = happyShift action_12
action_13 (49) = happyShift action_13
action_13 (63) = happyShift action_14
action_13 (4) = happyGoto action_3
action_13 (5) = happyGoto action_4
action_13 (6) = happyGoto action_5
action_13 (7) = happyGoto action_16
action_13 _ = happyFail (happyExpListPerState 13)

action_14 (8) = happyShift action_2
action_14 (10) = happyShift action_7
action_14 (11) = happyShift action_8
action_14 (12) = happyShift action_9
action_14 (44) = happyShift action_10
action_14 (46) = happyShift action_11
action_14 (48) = happyShift action_12
action_14 (49) = happyShift action_13
action_14 (63) = happyShift action_14
action_14 (4) = happyGoto action_3
action_14 (5) = happyGoto action_4
action_14 (6) = happyGoto action_5
action_14 (7) = happyGoto action_15
action_14 _ = happyFail (happyExpListPerState 14)

action_15 _ = happyReduce_6

action_16 _ = happyReduce_4

action_17 _ = happyReduce_2

action_18 (48) = happyShift action_22
action_18 (49) = happyShift action_23
action_18 _ = happyReduce_7

action_19 (46) = happyShift action_21
action_19 (48) = happyShift action_22
action_19 (49) = happyShift action_23
action_19 _ = happyReduce_8

action_20 (8) = happyShift action_2
action_20 (10) = happyShift action_7
action_20 (11) = happyShift action_8
action_20 (12) = happyShift action_9
action_20 (44) = happyShift action_10
action_20 (46) = happyShift action_11
action_20 (48) = happyShift action_12
action_20 (49) = happyShift action_13
action_20 (63) = happyShift action_14
action_20 (4) = happyGoto action_3
action_20 (5) = happyGoto action_4
action_20 (6) = happyGoto action_5
action_20 (7) = happyGoto action_25
action_20 _ = happyFail (happyExpListPerState 20)

action_21 (8) = happyShift action_2
action_21 (10) = happyShift action_7
action_21 (11) = happyShift action_8
action_21 (12) = happyShift action_9
action_21 (44) = happyShift action_10
action_21 (46) = happyShift action_11
action_21 (48) = happyShift action_12
action_21 (49) = happyShift action_13
action_21 (63) = happyShift action_14
action_21 (4) = happyGoto action_3
action_21 (5) = happyGoto action_4
action_21 (6) = happyGoto action_5
action_21 (7) = happyGoto action_24
action_21 _ = happyFail (happyExpListPerState 21)

action_22 _ = happyReduce_3

action_23 _ = happyReduce_5

action_24 (48) = happyShift action_22
action_24 (49) = happyShift action_23
action_24 _ = happyReduce_10

action_25 (46) = happyShift action_21
action_25 (48) = happyShift action_22
action_25 (49) = happyShift action_23
action_25 _ = happyReduce_9

happyReduce_1 = happySpecReduce_1  4 happyReduction_1
happyReduction_1 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn4
		 (unTok happy_var_1 (\range (L.Identifier iden) -> CId range $ BS.unpack iden)
	)
happyReduction_1 _  = notHappyAtAll 

happyReduce_2 = happySpecReduce_2  5 happyReduction_2
happyReduction_2 (HappyAbsSyn5  happy_var_2)
	(HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_1 (\range (L.Inc) -> CUnary range (CPreIncOp range) happy_var_2)
	)
happyReduction_2 _ _  = notHappyAtAll 

happyReduce_3 = happySpecReduce_2  5 happyReduction_3
happyReduction_3 (HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.Inc) -> CUnary range (CPostIncOp range) happy_var_1)
	)
happyReduction_3 _ _  = notHappyAtAll 

happyReduce_4 = happySpecReduce_2  5 happyReduction_4
happyReduction_4 (HappyAbsSyn5  happy_var_2)
	(HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_1 (\range (L.Dec) -> CUnary range (CPreDecOp range) happy_var_2)
	)
happyReduction_4 _ _  = notHappyAtAll 

happyReduce_5 = happySpecReduce_2  5 happyReduction_5
happyReduction_5 (HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.Dec) -> CUnary range (CPostDecOp range) happy_var_1)
	)
happyReduction_5 _ _  = notHappyAtAll 

happyReduce_6 = happySpecReduce_2  5 happyReduction_6
happyReduction_6 (HappyAbsSyn5  happy_var_2)
	(HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_1 (\range (L.Amp) -> CUnary range (CAdrOp range) happy_var_2)
	)
happyReduction_6 _ _  = notHappyAtAll 

happyReduce_7 = happySpecReduce_2  5 happyReduction_7
happyReduction_7 (HappyAbsSyn5  happy_var_2)
	(HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_1 (\range (L.Times) -> CUnary range (CIndOp range) happy_var_2)
	)
happyReduction_7 _ _  = notHappyAtAll 

happyReduce_8 = happySpecReduce_2  5 happyReduction_8
happyReduction_8 (HappyAbsSyn5  happy_var_2)
	(HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_1 (\range (L.Plus) -> CUnary range (CPlusOp range) happy_var_2)
	)
happyReduction_8 _ _  = notHappyAtAll 

happyReduce_9 = happySpecReduce_3  6 happyReduction_9
happyReduction_9 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.Plus) -> CBinary range (CAddOp range) happy_var_1 happy_var_3)
	)
happyReduction_9 _ _ _  = notHappyAtAll 

happyReduce_10 = happySpecReduce_3  6 happyReduction_10
happyReduction_10 (HappyAbsSyn5  happy_var_3)
	(HappyTerminal happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_2 (\range (L.Times) -> CBinary range (CMulOp range) happy_var_1 happy_var_3)
	)
happyReduction_10 _ _ _  = notHappyAtAll 

happyReduce_11 = happySpecReduce_1  7 happyReduction_11
happyReduction_11 (HappyAbsSyn4  happy_var_1)
	 =  HappyAbsSyn5
		 (CVar happy_var_1
	)
happyReduction_11 _  = notHappyAtAll 

happyReduce_12 = happySpecReduce_1  7 happyReduction_12
happyReduction_12 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_1 (\range (L.IntConst int) -> CConstExpr $ IntConst range $ read $ BS.unpack int)
	)
happyReduction_12 _  = notHappyAtAll 

happyReduce_13 = happySpecReduce_1  7 happyReduction_13
happyReduction_13 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_1 (\range (L.FloatConst f) -> CConstExpr $ DblConst range $ read $ BS.unpack f)
	)
happyReduction_13 _  = notHappyAtAll 

happyReduce_14 = happySpecReduce_1  7 happyReduction_14
happyReduction_14 (HappyTerminal happy_var_1)
	 =  HappyAbsSyn5
		 (unTok happy_var_1 (\range (L.CharConst c) -> CConstExpr $ CharConst range $ read $ BS.unpack c)
	)
happyReduction_14 _  = notHappyAtAll 

happyReduce_15 = happySpecReduce_1  7 happyReduction_15
happyReduction_15 (HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (happy_var_1
	)
happyReduction_15 _  = notHappyAtAll 

happyReduce_16 = happySpecReduce_1  7 happyReduction_16
happyReduction_16 (HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (happy_var_1
	)
happyReduction_16 _  = notHappyAtAll 

happyNewToken action sts stk
	= lexer(\tk -> 
	let cont i = action i i tk (HappyState action) sts stk in
	case tk of {
	L.RangedToken L.EOF _ -> action 92 92 tk (HappyState action) sts stk;
	L.RangedToken (L.Identifier _) _ -> cont 8;
	L.RangedToken (L.StringLit _) _ -> cont 9;
	L.RangedToken (L.IntConst _) _ -> cont 10;
	L.RangedToken (L.FloatConst _) _ -> cont 11;
	L.RangedToken (L.CharConst _) _ -> cont 12;
	L.RangedToken L.If _ -> cont 13;
	L.RangedToken L.Else _ -> cont 14;
	L.RangedToken L.Auto _ -> cont 15;
	L.RangedToken L.Break _ -> cont 16;
	L.RangedToken L.Case _ -> cont 17;
	L.RangedToken L.Char _ -> cont 18;
	L.RangedToken L.Const _ -> cont 19;
	L.RangedToken L.Continue _ -> cont 20;
	L.RangedToken L.Default _ -> cont 21;
	L.RangedToken L.Do _ -> cont 22;
	L.RangedToken L.Double _ -> cont 23;
	L.RangedToken L.Enum _ -> cont 24;
	L.RangedToken L.Extern _ -> cont 25;
	L.RangedToken L.Float _ -> cont 26;
	L.RangedToken L.For _ -> cont 27;
	L.RangedToken L.Int _ -> cont 28;
	L.RangedToken L.Long _ -> cont 29;
	L.RangedToken L.Register _ -> cont 30;
	L.RangedToken L.Return _ -> cont 31;
	L.RangedToken L.Short _ -> cont 32;
	L.RangedToken L.Signed _ -> cont 33;
	L.RangedToken L.Sizeof _ -> cont 34;
	L.RangedToken L.Static _ -> cont 35;
	L.RangedToken L.Struct _ -> cont 36;
	L.RangedToken L.Switch _ -> cont 37;
	L.RangedToken L.Typedef _ -> cont 38;
	L.RangedToken L.Union _ -> cont 39;
	L.RangedToken L.Unsigned _ -> cont 40;
	L.RangedToken L.Void _ -> cont 41;
	L.RangedToken L.Volatile _ -> cont 42;
	L.RangedToken L.While _ -> cont 43;
	L.RangedToken L.Plus _ -> cont 44;
	L.RangedToken L.Minus _ -> cont 45;
	L.RangedToken L.Times _ -> cont 46;
	L.RangedToken L.Div _ -> cont 47;
	L.RangedToken L.Inc _ -> cont 48;
	L.RangedToken L.Dec _ -> cont 49;
	L.RangedToken L.LAnd _ -> cont 50;
	L.RangedToken L.LOr _ -> cont 51;
	L.RangedToken L.SizeOfOp _ -> cont 52;
	L.RangedToken L.Mod _ -> cont 53;
	L.RangedToken L.AEq _ -> cont 54;
	L.RangedToken L.Eq _ -> cont 55;
	L.RangedToken L.NotEq _ -> cont 56;
	L.RangedToken L.Bang _ -> cont 57;
	L.RangedToken L.Le _ -> cont 58;
	L.RangedToken L.LEq _ -> cont 59;
	L.RangedToken L.Gr _ -> cont 60;
	L.RangedToken L.GEq _ -> cont 61;
	L.RangedToken L.Complement _ -> cont 62;
	L.RangedToken L.Amp _ -> cont 63;
	L.RangedToken L.Or _ -> cont 64;
	L.RangedToken L.LParen _ -> cont 65;
	L.RangedToken L.RParen _ -> cont 66;
	L.RangedToken L.LBracket _ -> cont 67;
	L.RangedToken L.RBracket _ -> cont 68;
	L.RangedToken L.Dot _ -> cont 69;
	L.RangedToken L.Colon _ -> cont 70;
	L.RangedToken L.Arrow _ -> cont 71;
	L.RangedToken L.LShift _ -> cont 72;
	L.RangedToken L.RShift _ -> cont 73;
	L.RangedToken L.Xor _ -> cont 74;
	L.RangedToken L.QMark _ -> cont 75;
	L.RangedToken L.TimesEq _ -> cont 76;
	L.RangedToken L.DivEq _ -> cont 77;
	L.RangedToken L.PlusEq _ -> cont 78;
	L.RangedToken L.MinusEq _ -> cont 79;
	L.RangedToken L.LShiftEq _ -> cont 80;
	L.RangedToken L.RShiftEq _ -> cont 81;
	L.RangedToken L.AndEq _ -> cont 82;
	L.RangedToken L.OrEq _ -> cont 83;
	L.RangedToken L.XorEq _ -> cont 84;
	L.RangedToken L.Comma _ -> cont 85;
	L.RangedToken L.Pnd _ -> cont 86;
	L.RangedToken L.DblPnd _ -> cont 87;
	L.RangedToken L.LBrace _ -> cont 88;
	L.RangedToken L.RBrace _ -> cont 89;
	L.RangedToken L.SemiColon _ -> cont 90;
	L.RangedToken L.Ellipsis _ -> cont 91;
	_ -> happyError' (tk, [])
	})

happyError_ explist 92 tk = happyError' (tk, explist)
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
