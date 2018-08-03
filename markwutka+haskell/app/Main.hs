module Main where

import System.Environment
import qualified Data.ByteString as B

import Model
import SimpleBuilder

main :: IO ()
main = do
  (modelFile:traceFile:_) <- getArgs
  model <- readModel modelFile
  let traceData = buildTrace model
  B.writeFile traceFile $ B.pack traceData
