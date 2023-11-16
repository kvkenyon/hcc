module Main (main) where

import Data.ByteString.Lazy.Char8 qualified as BS
import Lexer (runAlex)
import Parser (clang)
import System.Environment (getArgs)
import Text.Pretty.Simple (pPrint)
import TypeChecker (typecheck, globalScope)
import Control.Monad.State (runState)

run :: String -> IO ()
run fileName = do
  s <- readFile fileName
  case runAlex (BS.pack s) clang of
    Left err -> print err
    Right p -> case runState (typecheck p) globalScope of
      (Left _, scope) -> pPrint scope 
      (Right (), scope) -> pPrint scope

main :: IO ()
main = do
  args <- getArgs
  case args of
    [] -> putStrLn "Please provide a file name."
    (fname : _) -> run fname