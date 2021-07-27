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

	// NSUserDefaults *defaults;
//	NSArrayController* _formatController;
	NSArray<NSString*>* _availableFormats;
}

//@property (strong,nonatomic,readwrite) NSArrayController* formatController;
//@property (strong,nonatomic,readwrite) NSMutableArray<NSString*>* availableFormats;
//@property (strong,nonatomic,readwrite) NSArray<NSString*>* test;

- (void)viewDidLoad;


@end

NS_ASSUME_NONNULL_END
