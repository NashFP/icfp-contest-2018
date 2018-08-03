# 2018 ICFP Programming Contest

Generating instructions for a 3-D printing robot

## Background

The task for the [2018 ICFP Programming Contest](https://icfpcontest2018.github.io/) was to generate instructions
for one or more flying nanobots to generate a replica of a given 3-D model.
The full task description is here: "[2018 ICFP Contest Task](https://icfpcontest2018.github.io/full/task-description.html)"

Mark Wutka decided to do the task in Go for the contest this year, and then
presented his solution to us as well as some of his reasons for choosing
Go over a functional language. This is our chance to show how much simpler
a functional solution can be.

## Our Tasks

### Read the model into memory
We can start with a simple task, which is to read in a model. According
to the task description, the model files are just a sequence of bytes. The
first byte in the model gives the dimension of the model - the model files are
always cubes, so if the first byte contains 10, the model is 10x10x10.

The rest of the bytes represent a string of bits, with 1 indicating that
the coordinate corresponding to that bit should be filled (rather than
"pixels", these 3-D boxes are called "voxels"). Given particular
x, y, and z coordinates, and a model dimension of r (again, that's the first
byte in the model file) this is how to find the bit corresponding to that
coordinate.

Compute the overall bit number as: bitNumber = x * r * r + y * r + z
The byte that bit occurs in is: 1 + (bitNumber div 8)
The 1+ is accounting for the first byte in the file being the dimension.
Then, within that byte, the bit is:  1 << (bitNumber mod 8)
So, if fileBytes[1 + (bitNumber div 8)] & (1 << (bitNumber mod 8)) != 0
then the voxel at x,y,z should be filled.

### Generate a trace file
The task requires you to generate a trace file, which is a series of
bytes encoding instructions for the nanobots. You can first try generating
a series of instructions to draw a voxel at 1,0,1 and then move back to 0,0,0.

One way to do this would
be to do an SMove in the X direction by 1 voxel, so you'll be at 1,0,0. Then
do a Fill in the direction (0,0,1), which would fill the voxel at 1,0,1. Then
SMove in the X direction by -1 voxel, so you're back to 0,0,0, and then
execute a Halt instruction. If you do this, the generated trace file should
contain the bytes: 14 10 73 14 0e ff

Here's how that breaks down:
```
14 10 = SMove 1 in the X direction
73    = Fill 0,0,1
14 0e = SMove -1 in the X direction
ff    = Halt
```

You can try viewing your generated trace in the [Exec Trace Tool](https://icfpcontest2018.github.io/full/exec-trace.html). You can use any model file
with it, you just want to see that it draws a voxel and returns to home.
The viewer should complain that it halted with missing filled coordinates,
and possibly excess filled coordinates. That's okay, it just means you
didn't finish filling out the model.

### Generate a 3-D model
Try executing a Flip instruction at the beginning to put the grid into high-energy mode, then just move the
nanobot around and fill in voxels until you have filled in all the voxels
for a particular model. Don't forget to flip back to low-energy mode
before you move the nanobot back home to 0,0,0.

When you run the [Exec Trace Tool](https://icfpcontest2018.github.io/full/exec-trace.html) it will tell
you if you successfully rendered the model, and if not, why not.

### Make it better
The task allows you to clone the nanobot and have multiple bots work together.
That's one way to make your rendering more efficient. Running in high-energy
mode is wasteful, can you do all your generation in low-energy mode, only
drawing voxels when they can be connected to a grounded voxel?

## Where to get the models
The models are available as [problemsF.zip](https://icfpcontest2018.github.io/assets/problemsF.zip)
on the contest web site.
