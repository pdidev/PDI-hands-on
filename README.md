\page Hands_on Hands-on

# Setup

After %PDI \ref Installation installation, you can proceed with getting the sources for the
hands-on tutorial from [gitlab](https://github.com/pdidev/PDI-hands-on).

```bash
git clone https://github.com/pdidev/PDI-hands-on.git
```

To setup your environment run 
```bash
source pdi_path/share/pdi/env.bash
```
where `pdi_path` is your path to installed PDI directory.

Next, setup the compilation by detecting all dependencies:
```bash
cd PDI_hands-on
cmake .
```

Now you're ready to work, **good luck**!

# Tutorial

Compile exercise by:
```bash
make ex?
```
Run execise by:
```bash
pdirun mpirun -n 1 ./ex?
```
Where `?` is the number of the exercise.

## Ex1. Getting started

Ex1 is an implementation \ref heat_algorithm mentioned in \ref PDI_example.
If you didn't read it yet, it is recommended to do it before continuing. 
There is no input/output operations in the code yet, so we can not see its result.

Play with and understand the code parameters in `ex1.yml`.

Set values in `ex1.yaml` to be able to run the code with 3 MPI processes.

## Ex2. Now with some PDI

Ex2 is the same code as ex1 with %PDI calls added in main function. The 
\ref trace_plugin is used to trace %PDI calls.

Add the required `PDI_share` and `PDI_reclaim` calls to match the output of
`ex2.log` file.

Notice that some share/reclaim pairs come one after the other while others are interlaced.
Is one better than the other? If you do not know the answer to this question, please endure
to exercise 5 :)


## Ex3. HDF5 through PDI

Let's take the code from ex2 and make it output some HDF5 data.
No need to touch the C code here, the %PDI yaml file should be enough.
We have replaced the \ref trace_plugin by \ref Decl_HDF5_plugin.

Fill 2 sections in the yaml file:
* the `data` section to indicate to %PDI the type of the fields that are
  exposed,
* the `decl_hdf5` for the configuration of \ref Decl_HDF5_plugin

Only dsize is written as of now, let's add `psize` and `pcoord` to match the
content expected described in `ex3_result.h5` (use `h5dump` command to see content of HDF5 file).

## Ex4. Writing some real data

In this exercise each MPI process will write its local matrix
to separete HDF5 file. Touch only the yaml file again.

This time:
* write the real 2D data contained in `main_field`,
* use 2 MPI processes.

Notice that we use a list to write multiple files in the decl_hdf5 section
instead of a single mapping as before.

Unlike the other fields we manipulated until now, the type of `main_field` is
not fully known, its size is dynamic.
By moving other fields in the `metadata` section, we can reference them from
"$ expressions" in the configuration file.
This can be used to specify a dynamic size for `main_field`.

Unlike the other fields we manipulated until now, `main_field` is exposed
multiple times.
In order not to overwrite it every time it is exposed, we can add a `when`
condition to restrict its output.
Only write `main_field` at the second iteration (when `ii==0`).

Change the parallelism degree to 2 in height and try to match the expected content described in `ex4_result.h5`.

## Ex5. Introducing events

In ex4, we wrote 2 pieces of data to `ex4-data*.h5`, but the file is opened and
closed for each and every write.
Since Decl'HDF5 only sees the data appear one after the other, it does not keep
the file open.
Since `ii` and `main_field` are shared in an interlaced way, they are both
available at the same time and could be written without opening the file twice.
We have to use events for that.

Call %PDI event named `loop` when both `ii` and `main_field` are shared.
With the \ref trace_plugin, check that the event is indeed triggered at the expected
time as described in `ex5.log`.

Use the `on_event` mechanism to trigger the write of `ii` and `main_field`.
This mechanism can be combined with a `when` directive, in that case the write
is only executed when both mechanisms agree.

Also notice the extended syntax that make it possible to write data to a dataset
with a name different from the data in %PDI.
Use this mechanism to write main_field at iterations 1 and 2, in two distinct
groups `iter1` and `iter2`.
Match the content as expected in `ex5_result.h5`.

## Ex6. Simplifying the code

As you can notice, the %PDI code is quite redundant.
In this exercise, we will use `PDI_expose` and `PDI_multi_expose` to simplify
the code while keeping the exact same behaviour.

There are lots of matched `PDI_share`/`PDI_reclaim` in the code.
Replace these by `PDI_expose` that is the exact equivalent of a `PDI_share`
followed by a matching `PDI_reclaim`.

This replacement is not possible for interlaced `PDI_share`/`PDI_reclaim` with
events in the middle.
This case is however handled by `PDI_multi_expose` call that exposes all data,
then triggers an event and finally does all the reclaim in reverse order.
Replace the remaining `PDI_share`/`PDI_reclaim` by `PDI_expose`s and
`PDI_multi_expose`s.

Ensure that your code keeps the exact same behaviour by comparing its trace to
`ex6.log`.

## Ex7. Writing a selection

In this exercise, we will only write a selection (part) of the data to the HDF5 file.

As you can notice, we now independantly describe the dataset in the file.
We also use two directives to specify a selection from the data to write and a
selection in the dataset where to write.

- `memory_selection` tells what part to take from the data.
- `dataset_selection` tells where to write this part of data in file.

Here is an example:
```yaml
memory_selection:
  size: [8, 8]
  subsize: [4, 4]
  start: [4, 4]
dataset_selection:
  size: [8, 8]
  subsize: [4, 4]
  start: [4, 0]
```
The graphical representation:

\image html PDI_hdf5_selection.jpg



Restrict the selection to the second line from the data and write it to a
one-dimensional dataset in file.
Match the expected output described in `ex7.out`.

## Ex8. Writing an advanced selection

You can also add dimensions, write the 2D array excluding ghosts as a slab of a
3D dataset including a dimension for the time-iteration.

Here is an example:
```yaml
memory_selection:
  size: [8, 8]
  subsize: [4, 4]
  start: [4, 4]
dataset_selection:
  size: [3, 8, 8]
  subsize: [1, 4, 4]
  start: [$ii, 4, 0]
```

And the graphical representation:

\image html PDI_hdf5_selection_advanced.jpg

Write iterations 1 to 3 inclusive into dimensions 0 to 2.
Match the expected output described in `ex8_result.h5`.

## Ex9. Going parallel

Running the current code in parallel should already work and yield one file per
process containing the local data block.
In this exercise we will write one single file with parallel HDF5 whose content
should be independent from the number of processes used.

We loaded the `mpi` plugin to make sharing MPI communicators possible.

By uncommenting the `communicator` directive of \ref Decl_HDF5_plugin, we can now
switch to parallel I/O.
* Change the file name so all processes open the same file.
* Change the dataset dimension to take the full parallel size into account.
* Ensure the dataset selection of each process does not overlap with the others.
* Try to match the output from `ex9.out` that should be independant from the number of processes used.

Here is graphical representation:

\image html PDI_hdf5_parallel.jpg


# What next ?

You can experiment with other \ref Plugins "plugins".
Why not try \ref FlowVR_plugin "FlowVR" for example?
