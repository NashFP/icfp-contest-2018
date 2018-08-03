module Trace where

-- This model generates the instructions for a trace file.

import Data.Word
import Data.Bits

data Direction = X | Y | Z
data NearDirection = NearDirection Int Int Int
data FarDirection = FarDirection Int Int Int

data Instruction =
  Halt | Wait | Flip | SMove Direction Int | LMove Direction Int Direction Int |
  Fission NearDirection Int | Fill NearDirection | Void NearDirection |
  FusionP NearDirection | FusionS NearDirection | GFill NearDirection FarDirection |
  GVoid NearDirection FarDirection

encodeNear :: NearDirection -> Word8
encodeNear (NearDirection dx dy dz) = fromIntegral $ (dx+1)*9 + (dy+1)*3 + dz + 1

encodeFar :: FarDirection -> [Word8]
encodeFar (FarDirection dx dy dz) = map fromIntegral [ dx+30, dy+30, dz+30 ]

encodeDir :: Direction -> Word8
encodeDir X = 1
encodeDir Y = 2
encodeDir Z = 3

-- generate returns a list of bytes to encode a particular instruction. Some instructions like
-- Halt and Wait are only a single byte, others require several bytes.
generate :: Instruction -> [Word8]
generate Halt = [0xff]
generate Wait = [0xfe]
generate Flip = [0xfd]
generate (SMove dir d) = [4 + shiftL (encodeDir dir) 4, fromIntegral $ d + 15]
generate (LMove dir1 d1 dir2 d2) =
  [ 12 + (shiftL (encodeDir dir1) 6) + (shiftL (encodeDir dir2) 4),
    fromIntegral $ (shiftL (d2+5) 4) + d1+5 ]
generate (FusionP nd) = [7 + shiftL (encodeNear nd) 3]
generate (FusionS nd) = [6 + shiftL (encodeNear nd) 3]
generate (Fission nd m) = [5 + shiftL (encodeNear nd) 3, fromIntegral m]
generate (Fill nd) = [3 + shiftL (encodeNear nd) 3]
generate (Void nd) = [2 + shiftL (encodeNear nd) 3]
generate (GFill nd fd) = (1 + encodeNear nd) : encodeFar fd
generate (GVoid nd fd) = (encodeNear nd) : encodeFar fd
