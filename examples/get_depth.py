from pyrealsense import Device, Stream, Format
import numpy as np
import cv2

def main():
    dev = Device()
    if dev.get_device_count() == 0:
        print('Does not detect any devices. Abort.')
        return 1

    dev.use_device(0)
    print('Name:', dev.get_name())
    print('Serial:', dev.get_serial())
    print('Port ID:', dev.get_usb_port_id())
    print('Press esc key to stop')

    # XXX: librealsense requires the three streams to activate it. WHY?
    dev.enable_stream(Stream.depth, 640, 480, Format.z16, 30)
    dev.enable_stream(Stream.color, 640, 480, Format.rgb8, 30)
    dev.enable_stream(Stream.infrared, 640, 480, Format.y8, 30)
    dev.start()

    while True:
        dev.wait_for_frames()
        depth = dev.get_frame_data(Stream.depth)
        depth = (depth // 256).astype(np.uint8)
        cv2.imshow('depth', depth)
        k = cv2.waitKey(1)  # wait 1ms
        if k == 27: # press esc key
            break

    dev.stop()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
