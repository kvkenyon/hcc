module Main (main) where

import Data.ByteString.Lazy.Char8 qualified as BS
import Lexer (runAlex)
import Parser (clang)
import System.Environment (getArgs)
import Text.Pretty.Simple (pPrint)

run :: String -> IO ()
run fileName = do
  s <- readFile fileName
  case runAlex (BS.pack s) clang of
    Left err -> print err
    Right p -> pPrint p

main :: IO ()
main = do
  args <- getArgs
  case args of
    [] -> putStrLn "Please provide a file name."
    (fname : _) -> run fname