//
//  AppDelegate.h
//  iHarris
//
//  Created by Mark Heath on 29/11/18.
//  Copyright © 2018 Nine. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Harris.h"

@class Harris;

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
   // NSUserDefaults *defaults;
    Harris *harris;
    IBOutlet NSMenuItem *saveMenu;
    IBOutlet NSWindowController *mainWindow;
    
    // log file
    
}

- (Harris *)harris;
//- (NSUserDefaults *)getDefaults;
- (NSUserDefaults *)defaults;
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag;

@end

