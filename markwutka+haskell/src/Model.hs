module Model where

-- This module allows you to read a model file and test whether a particular pixel
-- in the model is set. Since the models are always cubes, you only need the model
-- size in one dimension - if modelSize returns 10, then the model is 10x10x10.

import Data.Word
import Data.Bits
import qualified Data.ByteString as B

data Model = Model Int B.ByteString

-- readModel reads the model file as a ByteString (which is implemented efficiently as an array)
-- The size of the model is the first byte in the file, after that it is just rows of bits.
readModel :: FilePath -> IO Model
readModel filename = do
  modelBytes <- B.readFile filename
  return $ Model (fromIntegral $ B.index modelBytes 0) modelBytes

-- modelIndex generates the bit number for a particular x,y,z coordinate in the model
modelIndex :: Int -> Int -> Int -> Int -> Int
modelIndex x y z r = x * r * r + y * r + z

-- modelSize returns the size of any dimension in the model (x,y,z all have the same dimension)
modelSize (Model r _) = r

-- isSet returns true if a voxel in the model is set. It returns False if the x,y,z is out of
-- range. Each voxel is represented by a bit in the array, modelIndex returns the index of
-- the bit. To find the byte containing that bit, you divide modelIndex by 8, and then to
-- find the bit in the byte, you take index modulo 8 and check that bit number. That is, if
-- index modulo 8 == 0, look at bit 0 (1 << 0), if it is 7, look at the leftmost bit (1 << 7)
-- Since the first byte of the model is the size of the model, you have to add 1 to the
-- index when fetching the correct byte
isSet (x,y,z) (Model r modelBytes)
  | x < 0 || x >= r || y < 0 || y >= r || z < 0 || z >= r = False
  | otherwise =
    let idx = modelIndex x y z r in
    let b = B.index modelBytes $ 1 + (idx `div` 8) in
      b .&. (shiftL 1 (idx `mod` 8)) /= 0

