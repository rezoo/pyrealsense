import numpy as np
cimport numpy as np
from libc.string cimport memcpy
from libcpp.map cimport map
from libcpp cimport bool

from pyrealsense.enum import Format, Stream, Option


cdef extern from "librealsense/rs.hpp" namespace "rs":

    ctypedef int StreamType 'rs::stream'
    ctypedef int FormatType 'rs::format'
    ctypedef int OptionType 'rs::option'

    cdef cppclass context:
        context()
        int get_device_count()
        device* get_device(int index)

    cdef cppclass device:
        const char* get_name()
        const char* get_serial()
        const char* get_firmware_version()
        const char* get_usb_port_id()
        const float get_depth_scale()

        void enable_stream(StreamType stream, int width, int height, FormatType format, int framerate)
        void disable_stream(StreamType stream)
        void start()
        void stop()
        void wait_for_frames()
        void* get_frame_data(StreamType stream)
        void set_option(OptionType option, double value)
        double get_option(OptionType option)
        bool supports_option(OptionType option)
        bool poll_for_frames()
        int get_frame_timestamp(StreamType stream)

cdef dict FORMAT_CONFIG = {
    Format.z16: (1, np.dtype('u2')),
    Format.disparity16: (1, np.dtype('u2')),
    Format.xyz32f: (3, np.dtype('f4')),
    Format.rgb8: (3, np.dtype('u1')),
    Format.bgr8: (3, np.dtype('u1')),
    Format.rgba8: (4, np.dtype('u1')),
    Format.bgra8: (4, np.dtype('u1')),
    Format.y8: (1, np.dtype('u1')),
    Format.y16: (1, np.dtype('u2')),
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

    cpdef unicode get_firmware_version(self):
        cdef const char* s = self._device.get_firmware_version()
        return s.decode('UTF-8', 'strict')

    cpdef unicode get_usb_port_id(self):
        cdef const char* s = self._device.get_usb_port_id()
        return s.decode('UTF-8', 'strict')

    cpdef float get_depth_scale(self):
        cdef float depth_scale = self._device.get_depth_scale()
        return depth_scale

    cpdef void enable_stream(
            self, int stream, int width, int height, int fmt, int framerate):
        self._device.enable_stream(
            <StreamType>stream, width, height, <FormatType>fmt, framerate)
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
        channel, dtype = FORMAT_CONFIG[fmt]
        shape = (height, width) if channel == 1 else (height, width, channel)
        dst_arr = np.zeros(shape, dtype=dtype)
        cdef size_t dst_ptr = dst_arr.ctypes.data
        memcpy(
            <void*>dst_ptr, <void*>src_ptr,
            <size_t>(width * height * channel * dtype.itemsize))
        return dst_arr

    cpdef void set_option(self, int option, double value):
        self._device.set_option(<OptionType>option, value)

    cpdef double get_option(self, int option):
        cdef double val = self._device.get_option(<OptionType>option)
        return val

    cpdef bool supports_option(self, int option):
        cdef bool val = self._device.supports_option(<OptionType>option)
        return val

    cpdef bool poll_for_frames(self):
        cdef bool ret = self._device.poll_for_frames()
        return ret

    cpdef int get_frame_timestamp(self, int stream):
        cdef int timestamps = self._device.get_frame_timestamp(<StreamType>stream)
        return timestamps
