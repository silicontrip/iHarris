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
	// NSLog(@">>> [Harris init]");
	
	self = [super init];
	if (self) {
		dbConnection = nil;
		atomic_flag_clear(&columnSet);
	}
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


+ (void)closeDbServer:(PGSQLConnection*)svr
{
	NSLog(@">>> [Harris closeDbServer]");

	[svr close];
	svr = nil;
}

+ (NSArray<NSDictionary*> *)dbQuery:(NSString*)query connection:(PGSQLConnection*)con
{
	// NSLog(@">>> [Harris filesQuery]");

	PGSQLRecordset *rs = nil;
	NSMutableArray<NSDictionary*> *results = [[NSMutableArray alloc] initWithCapacity:32];

	rs = (PGSQLRecordset*)[con open:query];

	if (rs != nil)
	{
		// NSInteger rowCount = [rs recordCount];
		NSArray *col = [rs columns];

		while (![rs isEOF])
		{
			//NSMutableArray<NSString*> *rowResults = [[NSMutableArray alloc] initWithCapacity:8];
			NSMutableDictionary<NSString*,NSString*>* rowResults = [NSMutableDictionary dictionaryWithCapacity:6];
			for (NSUInteger i =0; i< [col count]; i++)
			{
				NSString *field =[[rs fieldByIndex:i] asString];
				[rowResults setObject:field forKey:[[col objectAtIndex:i] name]];
			}
			[results addObject:[rowResults copy]];
			[rs moveNext];
			//NSLog(@"result %@",[rowResults firstObject]);
		}

	}
	[rs close];
	return [results copy];
}


- (void)updateColumns
{
	//NSLog(@">>> [Harris updateColumns]");

	NSUserDefaults* dd = [(AppDelegate*) [[NSApplication sharedApplication] delegate] defaults];

	NSString *query = [NSString stringWithFormat:@"select * FROM clips limit 1"];
	NSDictionary* dbList = [dd dictionaryForKey:@"DbServers"];
	
	dbConnectionList = [NSMutableArray arrayWithCapacity:[dbList count]];
	dbBlockTasks = [NSMutableArray arrayWithCapacity:[dbList count]];

	//dbQueryGroup = dispatch_group_create();
	dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

	for (NSString* svr in [dbList allValues])
	{
		// NSLog(@"[Harris UpdateColumns svr:%@",svr);
		dispatch_block_t bb = dispatch_block_create(DISPATCH_BLOCK_ASSIGN_CURRENT, ^{

			PGSQLConnection *dbConnection = [Harris dbConnectionServer:svr user:[dd stringForKey:@"DbUsername"] password:[dd stringForKey:@"DbPassword"]];
			//NSLog(@"[Harris UpdateColumns dbConnection");

			if (dbConnection)
			{
				//NSLog(@"[Harris UpdateColumns dispatch_block");

				if ([dbConnection connect])
				{
					//[dbConnectionList addObject:dbConnection];
				// could this be created outside the loop, or is the dbConnection assigned at creation time.
					
					NSArray<NSDictionary*>* dictResults = [Harris dbQuery:query connection:dbConnection];
					NSArray<NSString*>* results = [[dictResults firstObject] allKeys];
					
					if (results) {
						[dbConnection close];
						[self columnAsyncResults:results];
					}
					[dbConnection close];
				}
				//[self columnAsyncResults:nil];
			}
		});
		[dbBlockTasks addObject:bb];
				//dispatch_group_async(dbQueryGroup, aQueue, bb );
		dispatch_async( aQueue, bb );
		
	}

}

- (void) columnAsyncResults:(NSArray<NSString*>*)results
{
	//NSLog(@">>> [Harris columnAsyncResults]");
	

	if (!atomic_flag_test_and_set(&columnSet))
	{
		//NSLog(@"%@",results);

		for (dispatch_block_t bb in dbBlockTasks) {
			//NSLog(@"[Harris columnAsyncResults:dispatch_block_testcancel]");
			if (dispatch_block_testcancel(bb) == 0)
			{
				//NSLog(@"[Harris columnAsyncResults:dispatch_block_cancel]");
				dispatch_block_cancel(bb);
			}
		}
	
		dispatch_async(dispatch_get_main_queue(),^{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"HarrisColumnsUpdate" object:results];
		});
	//[columnResultLock unlock];
	}
}

- (void) updateFiles
{
	//NSLog(@">>> [Harris updateFiles]");

	atomic_flag_clear(&resultSet);
	
	NSUserDefaults* dd = [(AppDelegate*) [[NSApplication sharedApplication] delegate] defaults];
	
	// NSString *query = [NSString stringWithFormat:@"select %@ FROM clips limit 1",[dd stringForKey:@"DbColumns"]];
//	NSString *query = [NSString stringWithFormat:@"select %@ FROM clips where umid!='' and not longnameid like 'MLT%%'",[dd stringForKey:@"DbColumns"]];

	NSString *query = @"select * FROM clips where umid!='' and not longnameid like 'MLT%%'";
	
	NSDictionary* dbList = [dd dictionaryForKey:@"DbServers"];
	
	// dbConnectionList = [NSMutableArray arrayWithCapacity:[dbList count]];
	dbBlockTasks = [NSMutableArray arrayWithCapacity:[dbList count]];
	
	//dbQueryGroup = dispatch_group_create();
	dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	for (NSString* svr in [dbList allValues])
	{
		dispatch_block_t bb = dispatch_block_create(DISPATCH_BLOCK_ASSIGN_CURRENT, ^{
			PGSQLConnection *dbConnection = [Harris dbConnectionServer:svr user:[dd stringForKey:@"DbUsername"] password:[dd stringForKey:@"DbPassword"]];
			if (dbConnection)
			{
				if ([dbConnection connect])
				{
					//[dbConnectionList addObject:dbConnection];
					// could this be created outside the loop, or is the dbConnection assigned at creation time.
						NSArray<NSDictionary*>* results = [Harris dbQuery:query connection:dbConnection];
						if (results)
						{
							NSLog(@"[Harris updateFiles:%lu withServer:%@]",[results count],[dbConnection server]);
							[dbConnection close];
							[self filesAsyncResults:results];
						}
					[dbConnection close];
				}
			}
		});
		[dbBlockTasks addObject:bb];
		//dispatch_group_async(dbQueryGroup, aQueue, bb );
		// NSLog(@"dispatch %@",svr);
		dispatch_async( aQueue, bb );
		
	}
}

- (void)filesAsyncResults:(NSArray<NSDictionary*>*)results
{
	// NSLog(@">>> [Harris filesAsyncResults]");

	if (!atomic_flag_test_and_set(&resultSet))
	{
		for (dispatch_block_t bb in dbBlockTasks)
			if (dispatch_block_testcancel(bb) == 0)
				dispatch_block_cancel(bb);
		
		dispatch_async(dispatch_get_main_queue(),^{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"HarrisProgressInit" object:results];
		});
		for (NSDictionary *row in results)
		{
			dispatch_async(dispatch_get_main_queue(),^{
				[[NSNotificationCenter defaultCenter] postNotificationName:@"HarrisProgressUpdate" object:row];
			});
			// NSLog(@"[Harris filesAsyncResultsRow:%@]",row);
		}
		dispatch_async(dispatch_get_main_queue(),^{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"HarrisProgressStop" object:nil];
		});
		
		//[resultLock unlock];
	}
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
