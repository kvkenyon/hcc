{-# OPTIONS_GHC -Wno-incomplete-patterns #-}

module Main (main) where

import Control.Monad.State (evalState, runState)
import Control.Monad.State.Lazy (State)
import Data.ByteString.Lazy.Char8 qualified as BS
import Lexer (runAlex)
import Lexer qualified as L
import Parser (clang)
import Scope (globalScope)
import Syntax (CTranslationUnit)
import System.Environment (getArgs)
import Text.Pretty.Simple (pPrint)
import TypeChecker (Stack, describeCTU, runTypeChecker, typecheck)

-- run :: String -> IO ()
-- run fileName = do
--   s <- readFile fileName
--   case runAlex (BS.pack s) clang of
--     Left err -> print err
--     Right p -> pPrint p

-- Right p -> case runTypeChecker (typecheck p) globalScope of
--   (Left err, _) -> pPrint err
--   (Right (), scope) -> do
--     pPrint p
--     pPrint scope

describe :: CTranslationUnit L.Range -> (String, Stack)
describe ctu = runState (describeCTU ctu) []

runDescribe :: String -> IO ()
runDescribe fileName = do
  s <- readFile fileName
  case runAlex (BS.pack s) clang of
    Left err -> print err
    Right p -> putStrLn . fst $ describe p

main :: IO ()
main = do
  args <- getArgs
  case args of
    [] -> putStrLn "Please provide a file name."
    (fname : _) -> runDescribe fname