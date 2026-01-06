# 3d-projection of N-dimensional hypercube

![4d-hypercube](screenshot.png)

## Disclaimer
This is a software preservation kind of project. The goal is not to have something which is free of bugs but rather to enjoy getting old code up and running again.

## Introduction

This is a little Pascal based project that I must have started in the mid 90th of the last century, maybe around 1996. I stumbled over it on an old backup CD of mine recently, while looking for something entirely unrelated.

The original code was created using Turbo Pascal (on DOS), and was run on a PC with a i387 coprocessor. Bits were written in assembler to gain speed.

The code in this project has been cleaned up a bit, and ported to fpc. Assembler parts have not been migrated (so far).
While there are some bugs which would need some attention, it actually works.

Make sure that you have your red-green 3d classes at hand !

# Building
Make sure that you have fpc installed. To build, run
```
make
```

# Running
After successful compilation, there is an executable named *cube*
```
./cube
```

# Limitations
* Rotation is only possible into one direction, and the rotation angle is hard coded
* The window size is fixed and hard coded

# Known bugs
* Memory management is not great
* Trying to change the eye distance crashes the program
* In particular for higher dimensional cubes, there is some level of flickering



