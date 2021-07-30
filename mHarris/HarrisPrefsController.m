//
//  HarrisPrefsController.m
//  iHarris
//
//  Created by Mark Heath on 30/11/18.
//  Copyright © 2018 Nine. All rights reserved.
//

#import "HarrisPrefsController.h"

@implementation HarrisPrefsController

- (id)init
{
	self = [super init];
	NSLog(@">>> [HarrisPrefsController init]");
	return self;
}

- (NSArray*)availableFormats { return _availableFormats; }
- (void)setAvailableFormats:(NSArray*)a { _availableFormats = a; }
- (void)viewDidLoad {
	[super viewDidLoad];
	[self setAvailableFormats:[NSMutableArray arrayWithArray:[AVAssetExportSession allExportPresets]]];
}
@end
