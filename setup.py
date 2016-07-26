from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import numpy

ext_modules = [
    Extension(
        'pyrealsense.core',
        sources=['pyrealsense/core.pyx'],
        include_dirs=[numpy.get_include()],
        libraries=['realsense'],
        language='c++',
        extra_compile_args=['-mmacosx-version-min=10.9', '-Ofast', '-std=c++11'],
        extra_link_args=['-std=c++11']),
]

setup(
    name='pyrealsense',
    packages=['pyrealsense'],
    cmdclass={'build_ext': build_ext},
    ext_modules=ext_modules,
)
