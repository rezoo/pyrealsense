import numpy as np
cimport numpy as np
from libc.string cimport memcpy

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

cdef enum:
    depth                            = 0
    color                            = 1
    infrared                         = 2
    infrared2                        = 3
    points                           = 4
    rectified_color                  = 5
    color_aligned_to_depth           = 6
    infrared2_aligned_to_depth       = 7
    depth_aligned_to_color           = 8
    depth_aligned_to_rectified_color = 9
    depth_aligned_to_infrared2       = 10

cdef enum:
    any         = 0  
    z16         = 1
    disparity16 = 2
    xyz32f      = 3
    yuyv        = 4  
    rgb8        = 5  
    bgr8        = 6  
    rgba8       = 7  
    bgra8       = 8  
    y8          = 9  
    y16         = 10 
    raw10       = 11

cdef dict FORMAT_TO_DTYPES = {
    z16: np.dtype('u2'),
    disparity16: np.dtype('u2'),
    xyz32f: np.dtype('f4'),
}

cdef class Device:

    cdef context* _context
    cdef device* _device
    cdef dict stream_config

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

    cpdef void enable_stream(self, int s, int width, int height, int f, int framerate):
        self._device.enable_stream(<StreamType>s, width, height, <FormatType>f, framerate)
        #self.stream_config[s] = (width, height, f, framerate)

    cpdef void disable_stream(self, int stream):
        self._device.disable_stream(<StreamType>stream)
        #if stream in self.stream_config:
        #    del self.stream_config[stream]

    cpdef void start(self):
        self._device.start()

    cpdef void stop(self):
        self._device.stop()

    cpdef void wait_for_frames(self):
        self._device.wait_for_frames()

    cpdef np.ndarray get_frame_data(self, int stream):
        cdef void* src_ptr = <void*>self._device.get_frame_data(<StreamType>stream)

        #width, height, format, framerate = self.stream_config[stream]
        cdef int width = 640
        cdef int height = 480
        cdef int format = 1
        cdef int framerate = 30
        dtype = FORMAT_TO_DTYPES[format]
        dst_arr = np.zeros((height, width), dtype=dtype)
        dst_ptr = dst_arr.ctypes.data
        memcpy(<void*>src_ptr, <void*>src_ptr, <size_t>(width))
        return dst_arr
