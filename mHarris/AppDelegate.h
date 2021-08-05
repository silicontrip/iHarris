//
//  AppDelegate.h
//  iHarris
//
//  Created by Mark Heath on 29/11/18.
//  Copyright © 2018 Nine. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Harris.h"
#include <copyfile.h>


@class Harris;

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
	// NSUserDefaults *defaults;
	Harris *harris;
	IBOutlet NSMenuItem *saveMenu;
	IBOutlet NSWindowController *mainWindow;

	// log file
	
	NSArray<NSString*>* allColumns;
	// IBOutlet NSIndexSet *selectedRowIndexes;
	
	NSArray<NSDictionary<NSString*,NSString*>*>* data;
}

@property (readonly,getter=defaults) NSUserDefaults* defaults;
@property (readonly,getter=harris) Harris* harris;
@property (strong) NSIndexSet *selectedRowIndexes;
@property (strong) NSArrayController *searchResults;

// - (Harris *)harris;
// - (NSUserDefaults *)getDefaults;
// - (NSUserDefaults *)defaults;
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag;
- (void)saveToLocal:(id)sender;
- (IBAction)importPremiere:(id)sender;

@end

