module Main (main) where

import Control.Monad.State (runState)
import Data.ByteString.Lazy.Char8 qualified as BS
import Lexer (runAlex)
import Lexer qualified as L
import Parser (clang)
import Scope (globalScope)
import Syntax (CTranslationUnit)
import System.Environment (getArgs)
import Text.Pretty.Simple (pPrint)
import TypeChecker (Stack, describeCTU, runTypeChecker, typecheck)

runAST :: String -> IO ()
runAST fileName = do
  s <- readFile fileName
  case runAlex (BS.pack s) clang of
    Left err -> print err
    Right p -> pPrint p

runScope :: String -> IO ()
runScope fileName = do
  src <- readFile fileName
  case runAlex (BS.pack src) clang of
    Left err -> pPrint err
    Right p -> case runTypeChecker (typecheck p) globalScope of
      (Left err, _) -> pPrint err
      (Right (), scope) -> pPrint scope

describeTypes :: CTranslationUnit L.Range -> (String, Stack)
describeTypes ctu = runState (describeCTU ctu) []

runDescribe :: String -> IO ()
runDescribe fileName = do
  s <- readFile fileName
  case runAlex (BS.pack s) clang of
    Left err -> print err
    Right p -> putStrLn . fst $ describeTypes p

main :: IO ()
main = do
  args <- getArgs
  case args of
    [fname, "-d"] -> runDescribe fname
    [fname, "-a"] -> runAST fname
    [fname, "-s"] -> runScope fname
    _ ->
      putStrLn $
        "Usage: hcc filename -d (describe types)\n"
          ++ "       hcc filename  -a (print AST)\n"
          ++ "       hcc filename  -s (print Scope)\n"