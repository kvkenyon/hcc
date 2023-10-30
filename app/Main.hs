module Main (main) where

import Parser (clang)
import Parsing (parse)
import System.Environment (getArgs)
import Text.Pretty.Simple (pPrint)

run :: String -> IO ()
run fileName = do
  s <- readFile fileName
  case parse clang s of
    Left err -> print err
    Right p -> pPrint p

main :: IO ()
main = do
  args <- getArgs
  case args of
    [] -> putStrLn "Please provide a file name."
    (fn : _) -> run fn