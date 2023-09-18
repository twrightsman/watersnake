import os

from Cython.Build import cythonize
from setuptools import Extension, setup


aligner_include_dirs = []
if 'WATERSNAKE_LIBWFA2_INCLUDE_DIR' in os.environ:
    aligner_include_dirs.append(os.environ['WATERSNAKE_LIBWFA2_INCLUDE_DIR'])

setup(
    ext_modules = cythonize(
        module_list = [
            Extension(
                name = "watersnake._aligner",
                sources = [
                    "src/watersnake/_aligner.pyx"
                ],
                include_dirs = aligner_include_dirs,
                libraries = [
                    "wfa2"
                ]
            )
        ],
        compiler_directives = {"language_level": "3str"}
    ),
)
