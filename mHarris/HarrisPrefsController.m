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


- (id)init
{
    self = [super init];
//    NSLog(@"Harris Prefs Controller init");
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
	
//    NSLog(@"harris prefs controller did load");
    
	defaults = [NSUserDefaults standardUserDefaults];
	
	[mgxServerList setDelegate:self];
	[mgxServerList setDataSource:self];
	
	[dbServerList setDelegate:self];
	[dbServerList setDataSource:self];

    
    for (NSString *formatName in [AVAssetExportSession allExportPresets])
    {
        NSMenuItem *tfmi = [[NSMenuItem alloc] init];
        [tfmi setTitle:formatName];
        [transcodeFormat addItem:tfmi];
    }
    
    
	[self setUIFromDefaults];

}

- (IBAction)save:(id)sender {

	// copy from UI to defaults
    
    /*
    NSLog(@"selected mgx: %ld\n",[mgxServerList selectedRow]);
    NSLog(@"selected db: %ld\n",[dbServerList selectedRow]);

    
    NSLog(@"MgxUsername: %@\n", [mgxUsername title]);
    NSLog(@"MgxPassword: %@\n",[mgxPassword title]);
    NSLog(@"DbUsername: %@\n",[dbUsername title]);
    NSLog(@"DbPassword: %@\n",[dbPassword title]);
*/
        if ([[transcodeFormat highlightedItem] title] != nil)
            [defaults setObject:[[transcodeFormat highlightedItem] title] forKey:@"transcode format"];
 //   NSLog(@"defaults=transcodeFormat: %@\n",[defaults stringForKey:@"transcode format"]);
	[defaults setObject:[mgxUsername title] forKey:@"MgxUsername"];
	[defaults setObject:[mgxPassword title] forKey:@"MgxPassword"];
	[defaults setObject:[dbUsername title] forKey:@"DbUsername"];
	[defaults setObject:[dbPassword title] forKey:@"DbPassword"];
    
    [defaults setObject:[downloadPath title] forKey:@"default download path"];
    [defaults setObject:[previewPath title] forKey:@"default preview path"];
    [defaults setObject:[stillPath title] forKey:@"default still path"];

	NSMutableArray<NSString *> *dbNames = [[NSMutableArray alloc] init];
	NSMutableArray<NSString *> *dbIps = [[NSMutableArray alloc] init];

	for (NSDictionary *svr in [dbArrayController arrangedObjects])
	{
  //      NSLog(@"storing db %@:%@",[svr objectForKey:@"server"],[svr objectForKey:@"ip"]);
		[dbNames addObject:[svr objectForKey:@"server"]];
		[dbIps addObject:[svr objectForKey:@"ip"]];
	}
	[defaults setObject:dbNames forKey:@"DbNames"];
	[defaults setObject:dbIps forKey:@"DbIps"];

	NSMutableArray<NSString *> *mgxNames = [[NSMutableArray alloc] init];
	NSMutableArray<NSString *> *mgxIps = [[NSMutableArray alloc] init];
	
	for (NSDictionary *svr in [mgxArrayController arrangedObjects])
	{
     //   NSLog(@"storing mgx %@:%@",[svr objectForKey:@"server"],[svr objectForKey:@"ip"]);

		[mgxNames addObject:[svr objectForKey:@"server"]];
		[mgxIps addObject:[svr objectForKey:@"ip"]];
	}
	[defaults setObject:mgxNames forKey:@"MgxNames"];
	[defaults setObject:mgxIps forKey:@"MgxIps"];
	
	[defaults synchronize];
    [[[self view] window] close];
}

- (IBAction)cancel:(id)sender {
 //   NSLog(@"prefs controller cancel");
	// [self setUIFromDefaults];
    [[[self view] window] close];

}

- (void)setTitle:(NSCell *)cell forKey:(NSString *)key
{
    if ([defaults stringForKey:key])
        [cell setTitle:[defaults stringForKey:key]];
}

- (void)setUIFromDefaults
{
   // NSLog(@"prefs controller setUIfromDefaults");
    
    [self setTitle:mgxUsername forKey:@"MgxUsername"];
    [self setTitle:mgxPassword forKey:@"MgxPassword"];
    [self setTitle:dbUsername forKey:@"DbUsername"];
    [self setTitle:dbPassword forKey:@"DbPassword"];
    
    [self setTitle:downloadPath forKey:@"default download path"];
    [self setTitle:previewPath forKey:@"default preview path"];
    [self setTitle:stillPath forKey:@"default still path"];

 //   NSLog(@"UI=transcodeFormat: %@\n",[defaults stringForKey:@"transcode format"]);
    [transcodeButton selectItemWithTitle:[defaults stringForKey:@"transcode format"]];
    
    //[mgxUsername setTitle:[self getMgxUsername]];
	//[mgxPassword setTitle:[self getMgxPassword]];
	//[dbUsername setTitle:[self getDbUsername]];
	//[dbPassword setTitle:[self getDbPassword]];
    
    //[downloadPath setTitle:[defaults stringForKey:@"default download path"]];
    //[previewPath setTitle:[defaults stringForKey:@"default preview path"]];

	NSArray<NSString *> *mgxNames = [self getMgxNameList];
	NSArray<NSString *> *mgxIps = [self getMgxIpList];

	// NSLog(@"%lu MGX names.",(unsigned long)[mgxNames count]);
	
	for (int i=0; i < [mgxNames count]; i++) {
	//	NSLog(@"Adding %@",[mgxNames objectAtIndex:i]);
	//	NSLog(@"Adding %@",[mgxIps objectAtIndex:i]);
		NSMutableDictionary *value = [[NSMutableDictionary alloc] init];
		[value setObject:[mgxNames objectAtIndex:i] forKey:@"server"];
		[value setObject:[mgxIps objectAtIndex:i] forKey:@"ip"];
		[mgxArrayController addObject:value];
	}
	
	NSArray<NSString *> *dbNames = [self getDbNameList];
	NSArray<NSString *> *dbIps = [self getDbIpList];

	// NSLog(@"%lu DB names.",(unsigned long)[dbNames count]);

	
	for (int i=0; i < [dbNames count]; i++) {
	//	NSLog(@"Adding %@",[dbNames objectAtIndex:i]);
	//	NSLog(@"Adding %@",[dbIps objectAtIndex:i]);
		NSMutableDictionary *value = [[NSMutableDictionary alloc] init];

		[value setObject:[dbNames objectAtIndex:i] forKey:@"server"];
		[value setObject:[dbIps objectAtIndex:i] forKey:@"ip"];
		[dbArrayController addObject:value];
	}

	//NSLog([value );
	
	//[value release];
	[mgxServerList reloadData];
	
}

- (NSArray<NSString *> *)getMgxNameList { return [defaults stringArrayForKey:@"MgxNames"];}
- (NSArray<NSString *> *)getMgxIpList { return [defaults stringArrayForKey:@"MgxIps"];}
- (NSArray<NSString *> *)getDbNameList{ return [defaults stringArrayForKey:@"DbNames"];}
- (NSArray<NSString *> *)getDbIpList{ return [defaults stringArrayForKey:@"DbIps"];}

- (IBAction)addMgx:(id)sender {
	NSMutableDictionary *value = [[NSMutableDictionary alloc] init];
	
	[value setObject:[NSString stringWithFormat:@""] forKey:@"server"];
	[value setObject:[NSString stringWithFormat:@""] forKey:@"ip"];
	[mgxArrayController addObject:value];

}

- (IBAction)addDb:(id)sender {
	NSMutableDictionary *value = [[NSMutableDictionary alloc] init];

	[value setObject:[NSString stringWithFormat:@""] forKey:@"server"];
	[value setObject:[NSString stringWithFormat:@""] forKey:@"ip"];
	[dbArrayController addObject:value];
}

@end
