//
//  ViewController.h
//  a1
//
//  Created by uosim on 2017/11/19.
//  Copyright © 2017年 ss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

@interface ViewController : UIViewController <
AVCaptureVideoDataOutputSampleBufferDelegate> {
    AVCaptureSession *_captureSession;
    UIImageView *_imageView;
    CALayer *_customLayer;
    AVCaptureVideoPreviewLayer *_prevLayer;
}

@property (weak, nonatomic) IBOutlet UITextField *txt_info;


@end

