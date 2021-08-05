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

// application state...
@synthesize selectedRowIndexes;
@synthesize searchResults;

NSFileHandle *logFile = nil;


- (instancetype)init {
    self = [super init];
    
    //NSLog(@">>> [AppDelegate init]");
	
	NSDictionary *mgxList = [ NSDictionary dictionaryWithObjectsAndKeys:@"10.35.131.146", @"MGX1", @"10.35.131.147", @"MGX2", nil];
	NSDictionary *cifsList = [ NSDictionary dictionaryWithObjectsAndKeys:@"10.35.132.105", @"CIFS1", @"10.35.132.106", @"CIFS2", @"10.35.132.108", @"CIFS3", nil];

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES);
	NSString *downloadDir = [paths objectAtIndex:0];

	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:mgxList, @"MgxServers",
								 @"mgx", @"MgxUsername",
								 @"mgx", @"MgxPassword",
								 cifsList, @"DbServers",
								 @"postgres", @"DbUsername",
								 @"nxdb", @"DbPassword",
								// @"longnameid,modifiedtimestamp,duration,codecname,username,videoformatstring", @"DbColumns",
								 @"AVAssetExportPreset1920x1080", @"SelectedTranscodeFormat",
								 @"'/Volumes/Media/NEWS/DAILY_NEWS/'yyyy 'NEWS'/MM MMMM/yyMMdd/'captures'", @"StillPath",
								 @"/Volumes/NEXIO1", @"PreviewPath",
								 downloadDir, @"DownloadPath",
								 nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
	
	harris = [[Harris alloc] init];
    
    // [defaults setObject:@"YES" forKey:@"app did start"];
    // [defaults synchronize];
    
  //  NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
   // logFile = [NSFileHandle fileHandleForWritingAtPath:logPath];

	return self;

}

/*
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
    
}
*/

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

- (void)saveToLocal:(id)sender
{

	NSArray* paths = [self posixPathsForSelection];
	
	for (NSString* source in paths)
	{
		//NSLog(@"Copy from: %@",source);
		NSURL* srcUrl = [NSURL fileURLWithPath:source];
		NSString* filename = [source lastPathComponent];
		// NSLog(@"path comp: %@",filename);
		NSString* destinationDir = [self.defaults stringForKey:@"DownloadPath"];
		//NSLog(@"Copy to: %@",destinationDir);
		NSString* destination = [NSString pathWithComponents:@[destinationDir,filename]];
		
		NSURL *destUrl = [NSURL fileURLWithPath:destination];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSLog(@"copy from: %@ to %@",srcUrl,destUrl);
			if ( [[NSFileManager defaultManager] isReadableFileAtPath:source] ) {
				NSError *copyError = nil;
				BOOL res=NO;

				NSLog(@"begin copy");
				res=[[NSFileManager defaultManager] copyItemAtURL:srcUrl toURL:destUrl error:&copyError];
				NSLog(@"success: %d. error: %@",res,copyError);
				if ((res==NO) && (copyError != nil)) {
					dispatch_async(dispatch_get_main_queue(), ^{
						[[NSAlert alertWithError:copyError] runModal];
					});
				}
			}
			// NSLog(@"<<< saveClipToLocal %d\n",res);
		});
		
	}
	
	
}

- (NSDictionary<NSString*,NSString*>*) firstSelectedRow
{
	NSArray* results = [searchResults arrangedObjects];
	return [[results objectsAtIndexes:selectedRowIndexes] firstObject];

}

- (NSString*) firstPosixSelection
{
	return [[self posixPathsForSelection] firstObject];
}

- (NSArray<NSString *>*) posixPathsForSelection
{

	NSArray* results = [searchResults arrangedObjects];
	
	NSMutableArray<NSString *>*paths = [NSMutableArray arrayWithCapacity:[results count]];
	NSArray* sel = [results objectsAtIndexes:selectedRowIndexes];
	
	for (NSDictionary* row in sel)
	{
		NSString* path;
		if ([[row objectForKey:@"videoformatstring"] isEqualToString:@"AUDIO ONLY"])
		{
			path = [NSString stringWithFormat:@"%@/%@/%@.%@",
				[self.defaults stringForKey:@"PreviewPath"],
				@"AIFF",
				[row objectForKey:@"longnameid"],
				@"aiff"];
		} else {
			path = [NSString stringWithFormat:@"%@/%@/%@.%@",
				[self.defaults stringForKey:@"PreviewPath"],
				@"MOV",
				[row objectForKey:@"longnameid"],
				@"mov"];
		}
		
		[paths addObject:path];
		
	}
	return [paths copy];
	
}


// Premiere has to be open for this to work.
- (IBAction)importPremiere:(id)sender
{
//	NSLog(@"[AppDelegate importPremiere:%@]",sender);
	
	NSAppleEventDescriptor *ppro = [NSAppleEventDescriptor descriptorWithDescriptorType:typeApplSignature bytes:"orPP" length:4];
	
//	NSLog(@"app sig: %@",ppro);
	
	for (NSString* source in [self posixPathsForSelection])
	{
	
		NSURL *urlPath =  [NSURL fileURLWithPath:source];
	
//		NSLog(@"importing: %@",urlPath);
		
		NSAppleEventDescriptor *file = [NSAppleEventDescriptor descriptorWithFileURL:urlPath];
//		NSLog(@"file: %@",file);

		NSAppleEventDescriptor *open = [NSAppleEventDescriptor appleEventWithEventClass:'aevt'
																			eventID:'odoc'
																   targetDescriptor:ppro
																		   returnID:kAutoGenerateReturnID
																	  transactionID:kAnyTransactionID];
//		NSLog(@"open: %@",open);

		NSAppleEventDescriptor *activate = [NSAppleEventDescriptor appleEventWithEventClass:'misc'
																				eventID:'actv'
																	   targetDescriptor:ppro
																			   returnID:kAutoGenerateReturnID
																		  transactionID:kAnyTransactionID];
//		NSLog(@"activate: %@",activate);

		[open setParamDescriptor:file forKeyword:'----'];
	
//	NSLog(@"open: %@",open);
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
			AEDesc res;
			OSErr err;
		
			if (  ( err = AESendMessage([activate aeDesc], &res, kAEWaitReply|kAENeverInteract, kAEDefaultTimeout))!= noErr)
			{
				NSLog(@"sending activate message to premiere error: %d",err);
			}
		
		
			if ( (err = AESendMessage([open aeDesc], &res, kAEWaitReply|kAENeverInteract, kAEDefaultTimeout)) != noErr)
			{
				NSLog(@"sending activate message to premiere error: %d",err);
			}
		});
	}
	
}


@end
