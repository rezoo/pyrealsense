class Format:
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


class Stream:
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
