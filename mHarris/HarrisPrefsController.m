//
//  HarrisPrefsController.m
//  iHarris
//
//  Created by Mark Heath on 30/11/18.
//  Copyright © 2018 Nine. All rights reserved.
//

#import "HarrisPrefsController.h"


@interface HarrisPrefsController ()

@end

@implementation HarrisPrefsController

//@synthesize availableFormats;
//@synthesize formatController;
//@synthesize test;

- (id)init
{
	self = [super init];
	NSLog(@">>> [HarrisPrefsController init]");


	return self;
}

- (NSArray*)availableFormats { return _availableFormats; }
- (void)setAvailableFormats:(NSArray*)a { _availableFormats = a; }

// - (NSArrayController*)formatController { return _formatController; }
// - (void)setFormatController:(NSArrayController*)ac { _formatController = ac; }


/*
- (id)valueForKey:(NSString*)key
{
	if ([key isEqualToString:@"availableFormats"])
		return availableFormats;
	return nil;
}
*/

- (void)viewDidLoad {
	[super viewDidLoad];

	// NSLog(@">>> [HarrisPrefsController viewDidLoad]");
	
	//test = @[@"one",@"two",@"three",@"four"];
	
	[self setAvailableFormats:[NSMutableArray arrayWithArray:[AVAssetExportSession allExportPresets]]];
	// formatController = [[NSArrayController alloc] initWithContent:availableFormats];
	
	//availableFormats =[NSArray arrayWithArray:[AVAssetExportSession allExportPresets]];

	// NSLog(@"available: %@",[self availableFormats]);
	
}
@end
