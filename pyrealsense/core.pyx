import numpy as np
cimport numpy as np
from libc.string cimport memcpy
from libcpp.map cimport map

from pyrealsense.enum import Format
from pyrealsense.enum import Stream


cdef extern from "librealsense/rs.hpp" namespace "rs":

    ctypedef int StreamType 'rs::stream'
    ctypedef int FormatType 'rs::format'

    cdef cppclass context:
        context()
        int get_device_count()
        device* get_device(int index)

    cdef cppclass device:
        const char* get_name()
        const char* get_serial()
        const char* get_usb_port_id()
        void enable_stream(StreamType stream, int width, int height, FormatType format, int framerate)
        void disable_stream(StreamType stream)
        void start()
        void stop()
        void wait_for_frames()
        void* get_frame_data(StreamType stream)


cdef dict FORMAT_TO_DTYPES = {
    Format.z16: np.dtype('u2'),
    Format.disparity16: np.dtype('u2'),
    Format.xyz32f: np.dtype('f4'),
}

cdef class Device:

    cdef context* _context
    cdef device* _device
    cdef map[int, int] stream_width
    cdef map[int, int] stream_height
    cdef map[int, int] stream_format

    def __cinit__(self):
        self._context = new context()
        if self._context == NULL:
            raise MemoryError()

    cpdef int get_device_count(self):
        return self._context.get_device_count()

    cpdef void use_device(self, int index):
        self._device = self._context.get_device(index)

    cpdef unicode get_name(self):
        cdef const char* s = self._device.get_name()
        return s.decode('UTF-8', 'strict')

    cpdef unicode get_serial(self):
        cdef const char* s = self._device.get_serial()
        return s.decode('UTF-8', 'strict')

    cpdef unicode get_usb_port_id(self):
        cdef const char* s = self._device.get_usb_port_id()
        return s.decode('UTF-8', 'strict')

    cpdef void enable_stream(self, int stream, int width, int height, int fmt, int framerate):
        self._device.enable_stream(<StreamType>stream, width, height, <FormatType>fmt, framerate)
        self.stream_width[stream] = width
        self.stream_height[stream] = height
        self.stream_format[stream] = fmt

    cpdef void disable_stream(self, int stream):
        self._device.disable_stream(<StreamType>stream)

    cpdef void start(self):
        self._device.start()

    cpdef void stop(self):
        self._device.stop()

    cpdef void wait_for_frames(self):
        self._device.wait_for_frames()

    cpdef np.ndarray get_frame_data(self, int stream):
        cdef void* src_ptr = <void*>self._device.get_frame_data(<StreamType>stream)
        cdef int width = self.stream_width[stream]
        cdef int height = self.stream_height[stream]
        cdef int fmt = self.stream_format[stream]
        dtype = FORMAT_TO_DTYPES[fmt]
        dst_arr = np.zeros((height, width), dtype=dtype)
        cdef size_t dst_ptr = dst_arr.ctypes.data
        memcpy(<void*>dst_ptr, <void*>src_ptr, <size_t>(width * height * dtype.itemsize))
        return dst_arr
