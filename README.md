# Watersnake

## Installation

Currently, the only platform supported by the PyPI package is Linux
with a CPU that supports AVX-512.

```
pip install watersnake
```

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
$ pixi run twine-check
```
