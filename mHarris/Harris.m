//
//  Harris.m
//  iHarris
//
//  Created by Mark Heath on 30/11/18.
//  Copyright © 2018 Nine. All rights reserved.
//

#import "Harris.h"

@implementation Harris

-(id)init
{
	self = [super init];
	// defaults = [NSUserDefaults standardUserDefaults];
	dbConnection = nil;

	// would like this to be user configurable somehow
	//columns = @"longnameid,modifiedtimestamp,duration,codecname,username,videoformatstring";

	return self;
}

+ (PGSQLConnection*)dbConnectionServer:(NSString*)svr user:(NSString*)user password:(NSString*)pass
{
	PGSQLConnection* dbc = [[PGSQLConnection alloc] init];
	
	[dbc setServer:svr];
	[dbc setPort:@"5432"];
	[dbc setDatabaseName:@"nxdb"];
	[dbc setUserName:user];
	[dbc setPassword:pass];
	
	if (![dbc connect])
	{
		[dbc close];
		dbc = nil;
	}
	return dbc;
}

-(BOOL)openDb
{
	// dbList = [defaults arrayForKey:@"DbIps"];
	// [self setDBServer:0]; // needs to be configurable
	// dbConnection = [[PGSQLConnection alloc] init];
	
	NSUserDefaults* dd = [(AppDelegate*) [[NSApplication sharedApplication] delegate] defaults];
	
	NSDictionary* dblist = [dd dictionaryForKey:@"DbServers"];
	
	NSString* dbServerName = [[dblist allKeys] firstObject]; // for testing...
	NSString* dbServer = [dblist objectForKey:dbServerName];
	
	NSLog(@"Connection: %@",dbServer);

	if ((dbConnection = [Harris dbConnectionServer:dbServer user:[dd stringForKey:@"dbUsername"] password:[dd stringForKey:@"dbPassword"]]))
		return YES;
	return NO;
}

+ (void)closeDbServer:(PGSQLConnection*)svr
{
	[svr close];
	svr = nil;
}

- (void)closeDb
{
    [dbConnection close];
  //  [dbConnection release];  // ARC handles this?
    dbConnection = nil;
}

-(NSArray *)listColumns
{
	// as colums is just a comma seperated string
	// couldn't this be optimised to just return an NSArray<NSString>
	// NSArray* empty =
	
	NSUserDefaults* dd = [(AppDelegate*) [[NSApplication sharedApplication] delegate] defaults];
	
	if (dbConnection == nil)
		if (![self openDb])
			return @[];

	// PGSQLRecordset *rs = nil;
	NSString *query = [NSString stringWithFormat:@"select %@ FROM clips limit 1",[dd stringForKey:@"dbColumns"]];

	// NSLog(@"query: %@",query);

	id<GenDBRecordset> rs = nil;

	rs = [dbConnection open:query];

	if (rs != nil)
	{
		NSMutableArray<NSString *> * columnNames = [[NSMutableArray alloc] init];

		for (PGSQLColumn *pg in [rs columns])
			[columnNames addObject:[pg name]];
		
		return [columnNames copy];
	}
	NSLog(@"column search returned no results");
	return @[];
}


- (NSArray *)executeQuery:(NSString *) query
{
	// PGSQLConnection*
	if (dbConnection == nil)
		if (![self openDb])
			return nil;
	
	NSArray* results = [Harris filesQuery:query connection:dbConnection];
	
	[self closeDb];

	return results;
}

+ (NSArray *)filesQuery:(NSString*)query connection:(PGSQLConnection*)dbConnection
{
	PGSQLRecordset *rs = nil;
	NSMutableArray<NSArray*> *results = [[NSMutableArray alloc] initWithCapacity:32];

	rs = (PGSQLRecordset*)[dbConnection open:query];

	if (rs != nil)
	{
		// NSInteger rowCount = [rs recordCount];
		NSArray *col = [rs columns];

		while (![rs isEOF])
		{
			NSMutableArray<NSString*> *rowResults = [[NSMutableArray alloc] initWithCapacity:8];

			for (long i =0; i< [col count]; i++)
			{
				NSString *field =[[rs fieldByIndex:i] asString];
				// conditional field formatting.
				/*
                if ([[[col objectAtIndex:i] name] isEqualToString:@"duration"])
                {
                    //NSLog(@"Duration Formatter");
                    //field = [Harris durationFormatter:field];
                } else if ([[[col objectAtIndex:i] name] isEqualToString:@"modifiedtimestamp"])
                {
                    //NSLog(@"timestamp Formatter");
                    //field = [Harris timeFormatter:field];
                }
				 */
				[rowResults addObject:field] ;
			}
			[results addObject:[rowResults copy]];
			[rs moveNext];
		}

	}
	[rs close];
	return [results copy];
}

-(NSArray *)listFiles
{
	NSUserDefaults* dd = [(AppDelegate*) [[NSApplication sharedApplication] delegate] defaults];

	// copy of listFilesMatching but with different query.
	NSString *query = [NSString stringWithFormat:@"select %@ FROM clips where umid!='' and not longnameid like 'MLT%%'",[dd stringForKey:@"DbColumes"]];
	return [self executeQuery:query];

}

+ (NSArray*)columnQuery:(NSString*)qry connection:(PGSQLConnection*)con
{

	id<GenDBRecordset> rs = nil;
	
	rs = [con open:qry];
	if (rs != nil)
	{
		NSMutableArray<NSString *> * columnNames = [[NSMutableArray alloc] init];
		
		for (PGSQLColumn *pg in [rs columns])
			[columnNames addObject:[pg name]];
		
		return [columnNames copy];
	}
	return nil;
}

- (void)updateColumns
{
	NSUserDefaults* dd = [(AppDelegate*) [[NSApplication sharedApplication] delegate] defaults];

	NSString *query = [NSString stringWithFormat:@"select %@ FROM clips limit 1",[dd stringForKey:@"DbColumns"]];
	NSDictionary* dbList = [dd dictionaryForKey:@"DbServers"];
	
	dbConnectionList = [NSMutableArray arrayWithCapacity:[dbList count]];
	dbBlockTasks = [NSMutableArray arrayWithCapacity:[dbList count]];

	dbQueryGroup = dispatch_group_create();
	dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

	for (NSString* svr in [dbList allValues])
	{
		PGSQLConnection *dbConnection = [Harris dbConnectionServer:svr user:[dd stringForKey:@"DbUsername"] password:[dd stringForKey:@"DbPassword"]];
		if (dbConnection)
		{
			if ([dbConnection connect])
			{
				[dbConnectionList addObject:dbConnection];
				// could this be created outside the loop, or is the dbConnection assigned at creation time.
				dispatch_block_t bb = dispatch_block_create(DISPATCH_BLOCK_ASSIGN_CURRENT, ^{
					NSArray<NSString*>* results = [Harris columnQuery:query connection:dbConnection];
					if (results)
						[self columnAsyncResults:results];
				});
				[dbBlockTasks addObject:bb];
				dispatch_group_async(dbQueryGroup, aQueue, bb );
			}
		}
		
	}

}

- (void) columnAsyncResults:(NSArray<NSString*>*)results
{
	for (dispatch_block_t bb in dbBlockTasks)
		if (dispatch_block_testcancel(bb) == 0)
			dispatch_block_cancel(bb);
	
	for (PGSQLConnection* pp in dbConnectionList)
		[pp close];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HarrisColumnsUpdate" object:results];
}

- (void) updateFiles
{
	NSUserDefaults* dd = [(AppDelegate*) [[NSApplication sharedApplication] delegate] defaults];
	
	// NSString *query = [NSString stringWithFormat:@"select %@ FROM clips limit 1",[dd stringForKey:@"DbColumns"]];
	NSString *query = [NSString stringWithFormat:@"select %@ FROM clips where umid!='' and not longnameid like 'MLT%%'",[dd stringForKey:@"DbColumns"]];

	NSDictionary* dbList = [dd dictionaryForKey:@"DbServers"];
	
	dbConnectionList = [NSMutableArray arrayWithCapacity:[dbList count]];
	dbBlockTasks = [NSMutableArray arrayWithCapacity:[dbList count]];
	
	dbQueryGroup = dispatch_group_create();
	dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	for (NSString* svr in [dbList allValues])
	{
		PGSQLConnection *dbConnection = [Harris dbConnectionServer:svr user:[dd stringForKey:@"DbUsername"] password:[dd stringForKey:@"DbPassword"]];
		if (dbConnection)
		{
			if ([dbConnection connect])
			{
				[dbConnectionList addObject:dbConnection];
				// could this be created outside the loop, or is the dbConnection assigned at creation time.
				dispatch_block_t bb = dispatch_block_create(DISPATCH_BLOCK_ASSIGN_CURRENT, ^{
					NSArray<NSString*>* results = [Harris filesQuery:query connection:dbConnection];
					if (results)
						[self filesAsyncResults:results];
				});
				[dbBlockTasks addObject:bb];
				dispatch_group_async(dbQueryGroup, aQueue, bb );
			}
		}
		
	}
}

- (void)filesAsyncResults:(NSArray<NSString*>*)results
{
	for (dispatch_block_t bb in dbBlockTasks)
		if (dispatch_block_testcancel(bb) == 0)
			dispatch_block_cancel(bb);

	for (PGSQLConnection* pp in dbConnectionList)
		[pp close];

	[[NSNotificationCenter defaultCenter] postNotificationName:@"HarrisSearchUpdate" object:results];

}

// Probably class method ... maybe even in the search controller
+ (NSString *)durationFormatter:(NSString *)frameString
{
    NSInteger frameLong = [frameString intValue];
    
    int frame = frameLong % 25;
    int second = (frameLong / 25 ) % 60;
    int minute = (frameLong / 1500) % 60;
    long hour = (frameLong / 90000);
    
    return [NSString stringWithFormat:@"%02ld:%02d:%02d:%02d",hour,minute,second,frame];
    
}

// Probably class method
+ (NSString *)timeFormatter:(NSString *)timeString
{

    NSInteger harrisOffset = 126227808000000000L; // Cocoa epoch in NTFS epoch (GMT)

    NSInteger timeLong = ([timeString integerValue] - harrisOffset) / 10000000;
    NSDate *modifiedTime = [NSDate dateWithTimeIntervalSinceReferenceDate:timeLong];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [df setTimeZone:[NSTimeZone systemTimeZone]];
    
    return [df stringFromDate:modifiedTime];
}

//-(void)setDBServer:(NSInteger)i
//{
//    if ([dbList count] >= i)
//        dbServer = [dbList objectAtIndex:i];
//}

// all ftp moved to Download/Publish Controller

@end
