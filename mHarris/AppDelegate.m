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


- (instancetype)init {
    self = [super init];
    
    //NSLog(@">>> [AppDelegate init]");
	
	NSDictionary *mgxList = [ NSDictionary dictionaryWithObjectsAndKeys:@"10.35.131.146", @"MGX1", @"10.35.131.147", @"MGX2", nil];
	NSDictionary *cifsList = [ NSDictionary dictionaryWithObjectsAndKeys:@"10.35.132.105", @"CIFS1", @"10.35.132.106", @"CIFS2", @"10.35.132.108", @"CIFS3", nil];

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];

	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:mgxList, @"MgxServers",
								 @"iharris", @"MgxUsername",
								 @"mgx", @"MgxPassword",
								 cifsList, @"DbServers",
								 @"postgress", @"DbUsername",
								 @"nxdb", @"DbPassword",
								 @"longnameid,modifiedtimestamp,duration,codecname,username,videoformatstring", @"DbColumns",
								 @"AVAssetExportPreset1920x1080", @"SelectedTranscodeFormat",
								 documentsDirectory, @"StillPath",
								 @"/Volumes/NEXIO1", @"PreviewPath",
								 documentsDirectory, @"DownloadPath",
								 nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
	
	harris = [[Harris alloc] init];
    
    // [defaults setObject:@"YES" forKey:@"app did start"];
    // [defaults synchronize];
    
  //  NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
   // logFile = [NSFileHandle fileHandleForWritingAtPath:logPath];

	return self;

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (Harris *)harris { return harris; }

- (NSUserDefaults *)defaults { return [NSUserDefaults standardUserDefaults]; }

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
