# Watersnake

## Usage

```
>>> import watersnake
>>> aligner = watersnake.Aligner()
>>> aligner.align("ACTG", "ACTG")
'4M'
```

## Building the package from source

Watersnake uses [pixi](https://prefix.dev/docs/pixi/overview) for managing the build environment and tasks.

```
$ cd watersnake/
# Run the patch-conda-forge command only *once* after building a new Pixi environment since it modifies the WFA2-lib Conda package!
$ pixi run patch-conda-forge
$ pixi run twine-check
```
