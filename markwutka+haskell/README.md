# Simple Haskell solution for ICFPC 2018 model assembler

This program can do the model assembly part of the ICFPC 2018 task. It does so in a simple
but inefficient way. The task specifies that you can put the grid into a high-energy mode
where you are allowed to create voxels that are not grounded (a voxel is grounded if it its
y coordinate is 0, or if it is adjacent to a grounded voxel).

It simply reads in the model, generates a list of all the voxels that need to be set, starting
from the bottom, and moves to the spot right above each voxel and sets it.

To build it:
```
stack build
```

To run it:
```
stack exec -- icfp2018-exe -- themodelfile.mdl  thetracefile.nbt
```

Once it generates the trace, you can watch it execute the trace file using:
https://icfpcontest2018.github.io/full/exec-trace.html

Just click Empty for the source model, select the right model file and your generated trace
file and then click Execute Trace. You can change the Steps per Frame as it is running, if you
want to see it run faster or slower.

### Project Structure
src/Model.hs shows how to read in the file as a Haskell ByteString, which can be
accessed efficiently as if it were an array. It also shows how to figure out whether a voxel
is set in the model.

src/Trace.hs defines all the instructions that can be generated and shows how to turn each
instruction into a list of 1 or more bytes.

src/SimpleBuilder.hs builds a model by putting the grid in high-energy mode and then looping
through a list of voxels that need to be filled.

app/Main.hs gets the input model filename and output trace filename from the command line
arguments, loads the model, runs the builder, and writes the byte trace to the trace file.
