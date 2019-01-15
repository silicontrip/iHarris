//
//  MHPlayerView.h
//  iHarris
//
//  Created by Client Administrator on 11/01/2019.
//  Copyright © 2019 Client Administrator. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreMedia/CoreMedia.h>

@interface MHPlayerView : NSView

+(id)withUrl:(NSURL *)url;
-(long long)timeValue;
-(CVPixelBufferRef *)cvPixelBuffer;
-(void)seekToTime:(CMTime)time;

@end
