//
//  PreviewController.m
//  iHarris
//
//  Created by Client Administrator on 11/12/2018.
//  Copyright © 2018 Client Administrator. All rights reserved.
//

#import "PreviewController.h"

@interface PreviewController ()

@end

@implementation PreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
   // NSLog(@"[PreviewController viewDidLoad]");
    
    AppDelegate *ad = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    defaults = [ad getDefaults];
    harris = [ad getHarris];
    acceptsFirstResponder = YES;
}
- (void)viewDidAppear {
   // NSLog(@"[PreviewController viewDidAppear]");
    
    // what I really need to do is subclass both QTMovieView and AVPlayerView
    // adding a generic trim and save frame method
    // rather than using the isQTMovie bool.
    // and putting conditions in here
    
    [super viewDidAppear];
    
    // AUDIO ONLY
    // AVC Intra 100
    // DNxHD 185
    // DNxHD 185X
    // IMX
    // MPEG2 4:2:0
    // MPEG2 4:2:2
    // XDCAM EX
    // XDCAM HD
    // XDCAM HD422
    
    NSString *format = [defaults stringForKey:@"selected format"];
    NSURL *url = [NSURL fileURLWithPath:[self getPosixStringforSelection]];
    
    
    // all the conditions
    
    if ([format isEqualToString:@"AUDIO ONLY"] ||
        [format isEqualToString:@"XDCAM EX"] ||
        [format isEqualToString:@"XDCAM HD"] ||
        [format isEqualToString:@"XDCAM HD422"])
    {
        mpView =[self avPlayerViewFor:url];
        [mpView setFrame:[abstractPlayerView bounds]];
        [(AVPlayerView *)mpView setShowsFrameSteppingButtons:YES];
        [abstractPlayerView addSubview:mpView];
        isQTMovie = NO;  // remove reliance on this setting
       [[[self view] window] makeFirstResponder:mpView];
        //[vp setNextResponder:abstractPlayerView];

    } else {
        
        mpView  = [self qtPlayerViewFor:url];
        [mpView setFrame:[abstractPlayerView bounds]];
        // [(QTMovieView *)mpView setPreservesAspectRatio:YES];
        [(QTMovieView *)mpView setEditable:YES];
      //  [mpView setRefusesFirstResponder:YES];
        [abstractPlayerView addSubview:mpView];
        isQTMovie = YES;
       [[[self view] window] makeFirstResponder:self];
       // [vp setNextResponder:abstractPlayerView];
        //[[[self view] window] makeFirstResponder:abstractPlayerView];

    }
    
    
    [abstractPlayerView setNeedsDisplay:YES];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    // Only handle observations for the PlayerItemContext
    if (context != &PlayerItemContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = AVPlayerItemStatusUnknown;
        // Get the status change from the change dictionary
        NSNumber *statusNumber = change[NSKeyValueChangeNewKey];
        if ([statusNumber isKindOfClass:[NSNumber class]]) {
            status = statusNumber.integerValue;
        }
        // Switch over the status
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
                // Ready to Play
                NSLog(@"Ready to play...");
                [playerItem addOutput:playerOutput];
                
                break;
            case AVPlayerItemStatusFailed:
                // Failed. Examine AVPlayerItem.error
                break;
            case AVPlayerItemStatusUnknown:
                // Not ready
                break;
        }
    }
}

- (void)viewWillDisappear{
    if (!isQTMovie)
    {
        [playerItem removeObserver:self forKeyPath:@"status"];
        [player pause];
        player=nil;
        [asset cancelLoading];
        asset=nil;
    } else {
        [qtMovie invalidate];
        qtMovie=nil;
    }
    for (NSView *ns in [abstractPlayerView subviews])
        [ns removeFromSuperview];
    
}


- (NSString *)stringFromValue:(long long)value timescale:(long long)ts
{
    int m=0;
    int s=0;
    int f=0;
    int h=0;
    if (ts > 0)
    {
        double tc = 1.0 * value / ts;
        int fc = tc * 25;
        
        f = fc % 25;
        s = (fc / 25) % 60;
        m = (fc / 1500) % 60;
        h = (fc / 90000);
    }
    return [NSString stringWithFormat:@"%02d:%02d:%02d:%02d",h,m,s,f];
}

// seriously apple? you had to change the time members between CoreMedia and Quicktime
// you couldn't've left the members the same name so they could be used interchangably
- (NSString *)stringFromCMTime:(CMTime)time
{
    return [self stringFromValue:time.value timescale:time.timescale];
}

- (NSString *)stringFromQTTime:(QTTime)time
{
    return [self stringFromValue:time.timeValue timescale:time.timeScale];
}

- (NSString *) getPosixStringforSelection
{
   // NSLog(@"[PreviewController getPosixStringforSelection]");

        NSString *ext = @"mov";
        NSString *folder = @"MOV";
        if ([[defaults stringForKey:@"selected format"] isEqualToString:@"AUDIO ONLY"])
        {
            folder = @"AIFF";
            ext = @"aiff";
        }
        return [NSString stringWithFormat:@"%@/%@/%@.%@",[defaults stringForKey:@"default preview path"],folder,[defaults stringForKey:@"selected clip"],ext];
}

- (void)updateQTMovieTime:(NSNotification *)notification
{
    QTTime time = [qtMovie currentTime];
    [self->timeCodeText setTitle:[self stringFromValue:time.timeValue timescale:time.timeScale]];
    
}

- (QTMovieView *)qtPlayerViewFor:(NSURL *)url
{
   // NSLog(@"[PreviewController qtPlayerViewFor:%@]\n",url);

    NSError *qterror;
    qtMovie = [QTMovie movieWithURL:url error:&qterror];
    [qtMovie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieEditableAttribute];
   // [movie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieFrameImageDeinterlaceFields];
    QTMovieView *qtMovieView = [[QTMovieView alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateQTMovieTime:)
                                                 name:QTMovieTimeDidChangeNotification
                                               object:qtMovie];
    
    [qtMovieView setMovie:qtMovie];
    [qtMovieView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];

    [qtMovie gotoEnd];
    qtTotal = [qtMovie currentTime];
    [durationText setTitle:[self stringFromQTTime:qtTotal]];
    [qtMovie gotoBeginning];
    return qtMovieView;
    
}

- (AVPlayerView *)avPlayerViewFor:(NSURL *)url
{
   // NSLog(@"[PreviewController avPlayerViewFor:%@]\n",url);

    
    AVPlayerView *playerView;
    
    playerView = [[AVPlayerView alloc] init];
    
    NSDictionary* settings = @{ (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
    playerOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:settings];
    
    asset = [AVAsset assetWithURL:url];
    playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    NSLog(@"sometimes the playerItem doesnt -> %@\n",playerItem);
    
    // I seriously don't know what this is for apart from telling
    // if the observer call back is from us.
    PlayerItemContext = [NSObject alloc];
    
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
    
    [playerItem addObserver:self
                 forKeyPath:@"status"
                    options:options
                    context:&PlayerItemContext];
    
    // I'm supposed to re-use the AVPlayer if it already exists.
    
    player = [AVPlayer playerWithPlayerItem:playerItem];
    
   // AVPlayerLayer *avLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    
    [playerView setPlayer:player];
    
    //NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    
    //NSLog(@"video tracks: %ld",[tracks count]);
    
    // want to log video content flags.
    
    /*
     for (AVAssetTrack *videoTrack in tracks)
     {
     // NSLog(@"video: %@",videoTrack);
     for (id cmv in [videoTrack formatDescriptions])
     NSLog(@"video: %@",cmv);
     
     }
     */
    
    [durationText setTitle:[self stringFromCMTime:[asset duration]]];
    
    CMTime refreshRate = CMTimeMake(1,12);
    
    __weak typeof(self) weakSelf = self;
    
    [player addPeriodicTimeObserverForInterval:refreshRate queue:dispatch_get_main_queue() usingBlock:
     ^(CMTime time){
         __strong typeof(self) strongSelf = weakSelf;
         
         [strongSelf->timeCodeText setTitle:[weakSelf stringFromCMTime:time]];
         [strongSelf->inTimeCodeText setTitle:[weakSelf stringFromCMTime:[[weakSelf getPlayerItem] reversePlaybackEndTime]]];
         [strongSelf->outTimeCodeText setTitle:[weakSelf stringFromCMTime:[[weakSelf getPlayerItem] forwardPlaybackEndTime]]];
     }];
    [playerView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];

    // read timecode
    // an exercise in futility, AVFoundation doesn't support SMPTE timecodes
    
    NSError *error;
	long timeStampFrame = 0;
    AVAssetReader *aReader = [[AVAssetReader alloc] initWithAsset:asset error:&error ];
    if (aReader != nil)
    {
        NSArray *tcTracks = [asset tracksWithMediaType:AVMediaTypeTimecode];
        NSLog(@"number of timecodes: %lu\n",[tcTracks count]);
        if ([tcTracks count]>0)
        {
            AVAssetTrack *tcTrack = [tcTracks objectAtIndex:0];
            AVAssetReaderTrackOutput *tcOut = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:tcTrack outputSettings:nil];
            [aReader addOutput:tcOut];
            if ([aReader startReading])
            {
                CMSampleBufferRef sBuf = NULL;
                while (sBuf = [tcOut copyNextSampleBuffer])
                {
                    CMBlockBufferRef bBuf = CMSampleBufferGetDataBuffer(sBuf);
                    size_t length = CMBlockBufferGetDataLength(bBuf);
                    if (length>0) {
                        unsigned char *buffer = malloc(length);
                        memset(buffer, 0, length);
                        CMBlockBufferCopyDataBytes(bBuf, 0, length, buffer);

                        for (int i=0; i<length; i++) {
                            timeStampFrame = (timeStampFrame << 8) + buffer[i];
                        }

                        free(buffer);
                    }
                    NSLog(@"sbuf: %@", sBuf);
                }
                if (sBuf)
                    CFRelease(sBuf);
            }
            
        }
    }

	NSLog(@"Timestame frame: %ld\n",timeStampFrame);
    
    return playerView;
    
}

// /Volumes/Media/NEWS/DAILY_NEWS/2018 NEWS/12 DECEMBER/181220/captures/
//https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html#//apple_ref/doc/uid/TP40002369-SW1
- (NSString *)datePath:(NSString *)format
{
    NSLog(@"[PreviewController datePath:%@]",format);

    NSDate *now = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:format];
    [df setTimeZone:[NSTimeZone systemTimeZone]];
    
    return [df stringFromDate:now];
}

- (IBAction)saveFrameMenuItemSelected:(id)sender
{

  //  NSLog(@"[PreviewController saveFrameMenuItemSelected:%@]",sender);
    BOOL res= NO;
    NSError *writeError = nil;
    CVPixelBufferRef buffer;
    NSString *filename;
    if (isQTMovie)
    {
        
        NSDictionary *ma = [qtMovie movieAttributes];
        NSSize *frameSize = (__bridge NSSize *)([qtMovie attributeForKey:QTMovieNaturalSizeAttribute]);
       // NSLog(@"qt movie size: %@\n",frameSize);
        
        NSMutableDictionary *dict = [NSMutableDictionary
                              dictionaryWithObject:QTMovieFrameImageTypeCVPixelBufferRef
                              forKey:QTMovieFrameImageType];
        [dict setValue:(__bridge id _Nullable)(frameSize) forKey:QTMovieFrameImageSize];
        QTTime time = [qtMovie currentTime];
        
        buffer = (CVPixelBufferRef)[qtMovie frameImageAtTime:time
                                              withAttributes:dict error:NULL];

        filename = [NSString stringWithFormat:@"%@/%@_%04lld.tif",[self datePath:[defaults stringForKey:@"default still path"]],[defaults stringForKey:@"selected clip"],time.timeValue];
        
 
    } else {
        buffer = [playerOutput copyPixelBufferForItemTime:[playerItem currentTime] itemTimeForDisplay:nil];
        CMTime currentTime = [playerItem currentTime];
        filename = [NSString stringWithFormat:@"%@/%@_%04lld.tif",[self datePath:[defaults stringForKey:@"default still path"]],[defaults stringForKey:@"selected clip"],currentTime.value];
    }
        CIImage     *inputImage = nil;

        
        if (buffer != nil)
        {
    
            inputImage = [CIImage imageWithCVImageBuffer:buffer];
            NSCIImageRep* rep = [NSCIImageRep imageRepWithCIImage:inputImage];
            NSImage* image = [[NSImage alloc] initWithSize:NSMakeSize (CVPixelBufferGetWidth(buffer), CVPixelBufferGetHeight(buffer))];
    
            [image addRepresentation:rep];

            NSLog(@"TIFFRepresentation writeToFile:%@\n",filename);


        // this operation is quick enough not to need backgrounding.
            res = [[image TIFFRepresentation] writeToFile:filename options:NSDataWritingWithoutOverwriting error:&writeError];

    } else {
        
        
      //  NSErrorDomain *ed = @"iHarris";
        NSDictionary *userError = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
                                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Failed to get Image from Video.", nil),
                                    NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Search for the video again", nil)
                                    };
        writeError = [NSError errorWithDomain:@"iHarris" code:1 userInfo:userError];
        CVBufferRelease(buffer);
    }
    
    if (!res)
        [[NSAlert alertWithError:writeError] runModal];
    
  // [playerItem removeOutput:playerOutput];

    
  //  NSLog(@"<<< save Frame %d\n",res);

}

- (IBAction)beginTrimming:(id)sender {
    NSLog(@"[PreviewController beginTrimming:%@]",sender);

    // maybe abstract the movieview another day
    
    if (isQTMovie)
    {
        NSError *error;
        QTTime qtDur = QTMakeTime(qtOut.timeValue * qtIn.timeScale - qtIn.timeValue * qtOut.timeScale, qtIn.timeScale * qtOut.timeScale);
        
        QTTimeRange qtRange = QTMakeTimeRange(qtIn, qtDur);
        
        NSString *path = [NSString stringWithFormat:@"%@/%@_%lld_%lld.mov",[defaults stringForKey:@"default download path"],[defaults stringForKey:@"selected clip"],qtIn.timeValue,qtOut.timeValue]; // needs some configurability
        
        QTMovie *newMovie = [[QTMovie alloc] initWithMovie:qtMovie
                                                 timeRange:qtRange error:&error];
        
        NSMutableDictionary *savedMovieAttributes = [NSDictionary
                                                     dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                     forKey:QTMovieFlatten];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [newMovie writeToFile:path
                   withAttributes:savedMovieAttributes];
     
            NSLog(@"qt movie save: %@\n", error);

            if (error == nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert setMessageText:@"Movie Exported"];
                    [alert setAlertStyle:NSInformationalAlertStyle];
                    [alert runModal];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSAlert alertWithError:error] runModal];
                });
            }
        });
        
    }
    else
    {
    [[[abstractPlayerView subviews] objectAtIndex:0] beginTrimmingWithCompletionHandler:^(AVPlayerViewTrimResult result) {
        if (result == AVPlayerViewTrimOKButton) {
            // user selected Trim button (AVPlayerViewTrimOKButton)
            
            CMTime startTime = [playerItem reversePlaybackEndTime];
            CMTime endTime = [playerItem forwardPlaybackEndTime];
            
            NSString *ext = @"mov";
            if ([[defaults stringForKey:@"selected format"] isEqualToString:@"AUDIO ONLY"])
                ext = @"aiff";
            
            
            NSString *path = [NSString stringWithFormat:@"%@/%@_%lld_%lld.%@",[defaults stringForKey:@"default download path"],[defaults stringForKey:@"selected clip"],startTime.value,endTime.value,ext]; // needs some configurability
            NSURL *url = [NSURL fileURLWithPath:path];
            NSLog(@"export url: %@ with %@",url,[defaults stringForKey:@"transcode format"]);
            
            AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:playerItem.asset presetName:[defaults stringForKey:@"transcode format"]];
            
            [exportSession setOutputFileType:AVFileTypeQuickTimeMovie];
            [exportSession setOutputURL:url];
            
            CMTimeRange timeRange = CMTimeRangeFromTimeToTime(startTime, endTime);
            [exportSession setTimeRange:timeRange];
            
            [exportSession exportAsynchronouslyWithCompletionHandler:^(void){
                // might like to alert that the job is finished
                dispatch_async(dispatch_get_main_queue(), ^{

                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert setMessageText:@"Movie Exported"];
                    [alert setAlertStyle:NSInformationalAlertStyle];
                    [alert runModal];
                });
                NSLog(@"COMPLETE EXPORT");
            } ];
            
        } else {
            // user selected Cancel button (AVPlayerViewTrimCancelButton)
        }
    }];
    }
}

- (IBAction)saveClipToLocal:(id)sender {
  //  NSLog(@"[PreviewController saveClipToLocal:%@]",sender);
    
    NSString *source = [self getPosixStringforSelection];
    //[NSString stringWithFormat:@"%@/%@.mov",[defaults stringForKey:@"default preview path"],[defaults stringForKey:@"selected clip"]];
    
    NSString *ext = @"mov";
    if ([[defaults stringForKey:@"selected format"] isEqualToString:@"AUDIO ONLY"])
         ext = @"aiff";
         
    NSString *destination = [NSString stringWithFormat:@"%@/%@.%@",[defaults stringForKey:@"default download path"],[defaults stringForKey:@"selected clip"],ext];
    
    NSURL *srcUrl = [NSURL fileURLWithPath:source];  // this constructor can take a posix path
    NSURL *destUrl = [NSURL fileURLWithPath:destination];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

    BOOL res;
    NSError *copyError;
   // NSLog(@"copy from: %@ to %@",source,destUrl);
    if ( [[NSFileManager defaultManager] isReadableFileAtPath:source] )
        res=[[NSFileManager defaultManager] copyItemAtURL:srcUrl toURL:destUrl error:&copyError];
    
    if (!res)
        [[NSAlert alertWithError:copyError] runModal];
    
    // NSLog(@"<<< saveClipToLocal %d\n",res);
    });
    
}

- (double)compareQTTime:(QTTime)q1 with:(QTTime)q2
{
    // check that both timescales != 0
    NSLog(@"q1: %ld q2: %ld\n",q1.timeScale,q2.timeScale);

    double res = q1.timeValue / q1.timeScale - q2.timeValue / q2.timeScale;
    
    NSLog(@"res: %f\n",res);

    return res;
}


- (void)keyDown:(NSEvent *)event
{
    if (event != nil)
    {
  // NSLog(@"[PreviewController keyDown:%@]",event);
    NSString *key = [event characters];
    if ([key isEqualToString:@"i"])
    {
        if (isQTMovie)
        {
            qtIn = [qtMovie currentTime];
            [self->inTimeCodeText setTitle:[self stringFromQTTime:qtIn]];
            if (qtOut.timeScale == 0  || [self compareQTTime:qtIn with:qtOut] > 0)
            {
                qtOut = qtTotal;
            }
            
            QTTime qtDur = QTMakeTime(qtOut.timeValue * qtIn.timeScale - qtIn.timeValue * qtOut.timeScale, qtIn.timeScale * qtOut.timeScale);
            
            [qtMovie setSelection:QTMakeTimeRange(qtIn, qtDur)];
            [self->outTimeCodeText setTitle:[self stringFromQTTime:qtOut]];
            
        } else {
            [playerItem setReversePlaybackEndTime:[playerItem currentTime]];
            [self->inTimeCodeText setTitle:[self stringFromCMTime:[playerItem reversePlaybackEndTime]]];
        }
    }
     else if ([key isEqualToString:@"o"])
    {
        if (isQTMovie)
        {
            qtOut = [qtMovie currentTime];
            // QT kit claims there is a subtract but I can't find it.
            
            if (qtIn.timeScale == 0 || [self compareQTTime:qtIn with:qtOut] > 0)
            {
                qtIn = QTMakeTime(0,qtOut.timeScale);
            }

            [self->inTimeCodeText setTitle:[self stringFromQTTime:qtIn]];

            QTTime qtDur = QTMakeTime(qtOut.timeValue * qtIn.timeScale - qtIn.timeValue * qtOut.timeScale, qtIn.timeScale * qtOut.timeScale);
            
            [qtMovie setSelection:QTMakeTimeRange(qtIn, qtDur)];
            [self->outTimeCodeText setTitle:[self stringFromQTTime:qtOut]];

        } else {
            [playerItem setForwardPlaybackEndTime:[playerItem currentTime]];
            [self->outTimeCodeText setTitle:[self stringFromCMTime:[playerItem forwardPlaybackEndTime]]];
        }
    } else {
         if (isQTMovie)
             [mpView keyDown:event];  // sending this to AVMovieView causes an event loop

    }
    }
// else should I call super now?
}

- (IBAction)updateTimecode:(id)sender {
   // NSLog(@"[PreviewController updateTimecode:%@]",sender);

    // NSLog(@"%@",[self->timeCodeText title]);
    //[[timeCodeTextField currentEditor] setSelectedRange:NSMakeRange(0,0)];

    NSString *enteredTimecode = [self->timeCodeText title];
    NSArray *timeCodeElements = [enteredTimecode componentsSeparatedByString:@":"];
    int framecount=0;
    int mult = 1;
    for (NSInteger i=[timeCodeElements count]; i>0; i--)
    {
        framecount += mult * [[timeCodeElements objectAtIndex:i-1] intValue];
        if (mult == 25)
            mult=1500;
       else if(mult==1)
            mult=25;
        else
            mult *= 60;
    }
    if (isQTMovie)
    {
        QTTime timeCode = QTMakeTime(framecount, 25);
        [qtMovie setCurrentTime:timeCode];
    } else {
   // NSLog(@"framecounter = %d\n",framecount);
    CMTime timeCode = CMTimeMake(framecount,25);
        CMTime frameAccurate = CMTimeMake(0,25);
    [playerItem seekToTime:timeCode toleranceBefore:frameAccurate toleranceAfter:frameAccurate];
    }
    [[[self view] window] makeFirstResponder:abstractPlayerView];
}

- (IBAction)importPremiere:(id)sender {
    NSLog(@"[PreviewController importPremiere:%@]",sender);

    NSAppleEventDescriptor *ppro = [NSAppleEventDescriptor descriptorWithDescriptorType:typeApplSignature bytes:"orPP" length:4];
    NSURL *urlPath =  [NSURL fileURLWithPath:[self getPosixStringforSelection]];
    
    NSAppleEventDescriptor *file = [NSAppleEventDescriptor descriptorWithFileURL:urlPath];
    NSAppleEventDescriptor *open = [NSAppleEventDescriptor appleEventWithEventClass:'aevt'
                                                                            eventID:'odoc'
                                                                   targetDescriptor:ppro
                                                                           returnID:kAutoGenerateReturnID
                                                                      transactionID:kAnyTransactionID];
    
    NSAppleEventDescriptor *activate = [NSAppleEventDescriptor appleEventWithEventClass:'misc'
                                                                                eventID:'actv'
                                                                       targetDescriptor:ppro
                                                                               returnID:kAutoGenerateReturnID
                                                                          transactionID:kAnyTransactionID];
    
    [open setParamDescriptor:file forKeyword:'----'];

   // NSLog(@"aevent: %@",open);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        AEDesc res;
        OSErr err;
        
        err = AESendMessage([activate aeDesc], &res, kAEWaitReply|kAENeverInteract, kAEDefaultTimeout);
        err = AESendMessage([open aeDesc], &res, kAEWaitReply|kAENeverInteract, kAEDefaultTimeout);
    
        if (err != noErr)
        {
            NSLog(@"error: %d",err);
        }
    });
    
}

- (AVPlayerItem *)getPlayerItem {
   // NSLog(@"[PreviewController getPlayerItem]");
    return playerItem;
}
@end
