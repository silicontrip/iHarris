//
//  HarrisPrefsController.h
//  iHarris
//
//  Created by Mark Heath on 30/11/18.
//  Copyright © 2018 Nine. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface HarrisPrefsController : NSViewController
{
	NSArray<NSString*>* _availableFormats;
}

- (id)init;
- (void)viewDidLoad;

- (NSArray*)availableFormats;
- (void)setAvailableFormats:(NSArray*)a;

@end

NS_ASSUME_NONNULL_END
