module Main (main) where

import System.Environment (getArgs)

-- -- import Text.Parsec (parseTest, parserTrace)
-- import Text.Pretty.Simple (pPrint)

-- run :: String -> IO ()
-- run fileName = do
--   s <- readFile fileName
--   -- parseTest (clang >> parserTrace "clang") s
--   case parse clang s of
--     Left err -> print err
--     Right p -> pPrint p

main :: IO ()
main = do
  args <- getArgs
  case args of
    [] -> putStrLn "Please provide a file name."
    (_ : _) -> putStrLn "Temp"