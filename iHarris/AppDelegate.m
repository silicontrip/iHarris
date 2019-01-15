//
//  AppDelegate.m
//  iHarris
//
//  Created by Mark Heath on 29/11/18.
//  Copyright © 2018 Nine. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

NSFileHandle *logFile = nil;


- (id)init {
    self = [super init];
    
    //NSLog(@"app delegate init");
    
    defaults = [NSUserDefaults standardUserDefaults];
    harris = [[Harris alloc] init];
    
    [defaults setObject:@"YES" forKey:@"app did start"];
    [defaults synchronize];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
    
    logFile = [NSFileHandle fileHandleForWritingAtPath:logPath];

    return self;
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (Harris *)getHarris { return harris; }
- (NSUserDefaults *)getDefaults { return defaults; }

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
   // NSLog(@"application handle reopen: %d",flag);
    if(!flag)
    {
        for(id const window in theApplication.windows)
        {
            [window makeKeyAndOrderFront:self];
        }
    }
    return YES;
    // return !flag;
}
@end
