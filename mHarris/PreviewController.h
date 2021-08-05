//
//  PreviewController.h
//  iHarris
//
//  Created by Client Administrator on 11/12/2018.
//  Copyright © 2018 Client Administrator. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <CoreMedia/CoreMedia.h>
#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Harris.h"
#import <QTKit/QTKit.h>

@interface PreviewController : NSViewController 
{
    BOOL acceptsFirstResponder;
    BOOL isQTMovie;
    AVPlayer *player;
    AVAsset *asset;
    AVPlayerItemVideoOutput *playerOutput;
    AVPlayerItem *playerItem;
    
    QTMovie *qtMovie;
    QTTime qtIn;
    QTTime qtOut;
    QTTime qtTotal;
    
    NSObject *PlayerItemContext;
    
    IBOutlet NSTextFieldCell *durationText;
    IBOutlet NSTextFieldCell *timeCodeText;
    IBOutlet NSTextFieldCell *inTimeCodeText;
    IBOutlet NSTextFieldCell *outTimeCodeText;
   // IBOutlet AVPlayerView *playerView;
    
    IBOutlet NSButton *trimButton;
    IBOutlet NSView *abstractPlayerView;
    NSView *mpView;
	
	NSString * selectedFormat;
	NSString * selectedClip;
    // NSUserDefaults *defaults;
    Harris *harris;
}

- (void)viewDidLoad;
- (void)viewWillDisappear;
- (void)viewDidAppear;

- (NSString *)stringFromValue:(long long)value timescale:(long long)ts;
- (NSString *)stringFromCMTime:(CMTime)time;
- (NSString *)stringFromQTTime:(QTTime)time;

- (void)updateQTMovieTime:(NSNotification *)notification;
- (QTMovieView *)qtPlayerViewFor:(NSURL *)url;
- (AVPlayerView *)avPlayerViewFor:(NSURL *)url;

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context;

- (NSString *)datePath:(NSString *)format;

- (void)keyDown:(NSEvent *)event;

- (IBAction)saveFrameMenuItemSelected:(id)sender;
- (IBAction)beginTrimming:(id)sender;
- (IBAction)saveClipToLocal:(id)sender;
- (IBAction)updateTimecode:(id)sender;
- (IBAction)importPremiere:(id)sender;
- (AVPlayerItem *)getPlayerItem;

@end
