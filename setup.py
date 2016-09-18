from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import numpy
import sys

extra_compile_args=['-Ofast', '-std=c++11'],
if sys.platform == "darwin":
    extra_compile_args.insert(0, "-mmacosx-version-min=10.9")

ext_modules = [
    Extension(
        'pyrealsense.core',
        sources=['pyrealsense/core.pyx'],
        include_dirs=[numpy.get_include()],
        libraries=['realsense'],
        language='c++',
        extra_compile_args=['-Ofast', '-std=c++11'],
        extra_link_args=['-std=c++11']),
]

setup(
    name='pyrealsense',
    packages=['pyrealsense'],
    cmdclass={'build_ext': build_ext},
    ext_modules=ext_modules,
)
