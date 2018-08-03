module SimpleBuilder where

-- This is just about the simplest way to generate the 3-D model
--
-- When it starts, if flips the grid state into high-energy mode, which means
-- that you can create voxels in mid air. Then it just goes left-to-right,
-- front-to-back, bottom to top setting voxels according to whether they are in
-- the model or not.

import Data.List
import Data.Word
import Model
import Trace

data BuilderState = BuilderState (Int,Int,Int) [Word8]

-- getVoxelsToSet returns a list in left-to-right, front-to-back, bottom-to-top order
-- of all voxels in the model that need to be set that aren't set
-- The ordering of the variables in the list comprehension is important - it goes through
-- all the xs before incrementing z and then all the zs before incrementing y
getVoxelsToSet :: Model -> [(Int,Int,Int)]
getVoxelsToSet model =
  [(x,y,z) | y <- [0..r], z <- [0..r], x <- [0..r], isSet (x,y,z) model]
  where
    r = modelSize model

-- goto generates the moves going from an x,y,z coordinate to another, moving along x first, then
-- y, and then z. It is only safe to use if you are building from the bottom up and the nanobot
-- is above the voxels. Since SMove has a limit of 15 units in a direction, it may generate
-- multiple SMoves if it has to move a long distance in a particular direction
goto :: (Int,Int,Int) -> (Int,Int,Int) -> [Word8]
goto (fromX,fromY,fromZ) (toX,toY,toZ)
  | toX - fromX > 15 = generate (SMove X 15) ++ goto (fromX+15,fromY,fromZ) (toX,toY,toZ)
  | toX - fromX < -15 = generate (SMove X (-15)) ++ goto (fromX-15,fromY,fromZ) (toX,toY,toZ)
  | abs (toX-fromX) > 0 = generate (SMove X (toX-fromX)) ++ goto (toX, fromY, fromZ) (toX,toY,toZ)
  | toY - fromY > 15 = generate (SMove Y 15) ++ goto (fromX,fromY+15,fromZ) (toX,toY,toZ)
  | toY - fromY < -15 = generate (SMove Y (-15)) ++ goto (fromX,fromY-15,fromZ) (toX,toY,toZ)
  | abs (toY-fromY) > 0 = generate (SMove Y (toY-fromY)) ++ goto (fromX, toY, fromZ) (toX,toY,toZ)
  | toZ - fromZ > 15 = generate (SMove Z 15) ++ goto (fromX,fromY,fromZ+15) (toX,toY,toZ)
  | toZ - fromZ < -15 = generate (SMove Z (-15)) ++ goto (fromX,fromY,fromZ-15) (toX,toY,toZ)
  | abs (toZ-fromZ) > 0 = generate (SMove Z (toZ-fromZ)) ++ goto (fromX, fromY, toZ) (toX,toY,toZ)
  | otherwise = []

-- buildStep is folded over the list of voxels to set. It moves to the new x,y,z coord and
-- sets the voxel at that coordinate. It builds the instruction list in reverse because it's
-- much faster to prepend a short list to what can be a very long list of instructions.
buildStep :: BuilderState -> (Int,Int,Int) -> BuilderState
buildStep (BuilderState (lastX,lastY,lastZ) instrs) (newX,newY,newZ) =
  BuilderState (newX,newY+1,newZ) $
  (reverse $ (goto (lastX,lastY,lastZ) (newX,newY+1,newZ)) ++
   (generate (Fill (NearDirection 0 (-1) 0))))++instrs

-- buildVoxelTrace builds the trace by folding buildStep over the list of voxels to set, starting
-- from coordinate 0,0,0 and setting the grid to the high-energy state (via Flip)
buildVoxelTrace :: Model -> BuilderState
buildVoxelTrace model =
  foldl' buildStep (BuilderState (0,0,0) (generate Flip)) (getVoxelsToSet model)

-- buildTrace builds the full trace for a model, by generating the instructions to set all
-- the voxels, then by adding commands to move the nanobot back to the home position
-- at 0,0,0 then flipping the grid back to low energy mode and halting.
buildTrace :: Model -> [Word8]
buildTrace model =
  reverse $ (generate Halt) ++ (generate Flip) ++ gotoHome ++ instrs
  where
    (BuilderState (lastX,lastY,lastZ) instrs) = buildVoxelTrace model
    gotoHome = reverse $ (goto (lastX,lastY,lastZ) (0,lastY,0)) ++ goto (0,lastY,0) (0,0,0)
