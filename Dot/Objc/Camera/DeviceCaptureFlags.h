//
//  DeviceCaptureFlags.h
//  VenusPearl_b
//
//  Created by Warren Stringer on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

typedef enum {
    kDeviceCaptureNone        = 0, 
    kDeviceCaptureCameraBack  = 1<<0, // =AVCaptureDevicePositionBack both audio and video
    kDeviceCaptureCameraFront = 1<<1, // =AVCaptureDevicePositionFront both audio and video
    kDeviceCaptureAudio       = 1<<2, // =4 capture audio only
    kDeviceCaptureTouch       = 1<<3, // =8 capture touch
}   DeviceCaptureFlags;
