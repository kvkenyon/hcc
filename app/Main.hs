module Main (main) where

import Data.ByteString.Lazy.Char8 qualified as BS
import Lexer (runAlex)
import Parser (clang)
import Scope (globalScope)
import System.Environment (getArgs)
import Text.Pretty.Simple (pPrint)
import TypeChecker (runTypeChecker, typecheck)

run :: String -> IO ()
run fileName = do
  s <- readFile fileName
  case runAlex (BS.pack s) clang of
    Left err -> print err
    Right p -> pPrint p

-- Right p -> case runTypeChecker (typecheck p) globalScope of
--   (Left err, _) -> pPrint err
--   (Right (), scope) -> do
--     pPrint p
--     pPrint scope

main :: IO ()
main = do
  args <- getArgs
  case args of
    [] -> putStrLn "Please provide a file name."
    (fname : _) -> run fname