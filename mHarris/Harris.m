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
	defaults = [NSUserDefaults standardUserDefaults];
	dbConnection = nil;
    
	// would like this to be user configurable somehow
	columns = @"longnameid,modifiedtimestamp,duration,codecname,username,videoformatstring";
    
	return self;
}

-(BOOL)openDb
{

    dbList = [defaults arrayForKey:@"DbIps"];
    [self setDBServer:0]; // needs to be configurable
    
	dbConnection = [[PGSQLConnection alloc] init];
    
    NSLog(@"Connection: %@",dbServer);
    
    [dbConnection setServer:dbServer];
    [dbConnection setPort:@"5432"];
    [dbConnection setDatabaseName:@"nxdb"];
    [dbConnection setUserName:[defaults stringForKey:@"DbUsername"]];
    [dbConnection setPassword:[defaults stringForKey:@"DbPassword"]];

    //[dbConnection setConnectionString:connection];
	
	if (![dbConnection connect])
    {
        [dbConnection close];
       // NSLog(@"Connection to DB fail");
        return NO;
    }
   // NSLog(@"connection success");
    return YES;
	// how to report error?
}

- (void)closeDb
{
    [dbConnection close];
  //  [dbConnection release];
    dbConnection = nil;
}

-(NSArray *)listColumns
{
    // as colums is just a comma seperated string
    // couldn't this be optimised to just return an NSArray<NSString>
    NSArray* empty = @[];
	if (dbConnection == nil)
		if (![self openDb])
            return empty;

	// PGSQLRecordset *rs = nil;
	NSString *query = [NSString stringWithFormat:@"select %@ FROM clips limit 1",columns];
    
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
	return empty;
}


- (NSArray *)executeQuery:(NSString *) query
{
    // PGSQLConnection*
    if (dbConnection == nil)
        if (![self openDb])
            return nil;
    
    PGSQLRecordset *rs = nil;

    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:0];
    
    rs = (PGSQLRecordset*)[dbConnection open:query];
    
    if (rs != nil)
    {
        // NSInteger rowCount = [rs recordCount];
        NSArray *col = [rs columns];
        
        while (![rs isEOF])
        {
            NSMutableArray *rowResults = [[NSMutableArray alloc] initWithCapacity:0];
            
            for (long i =0; i< [col count]; i++)
            {
                NSString *field =[[rs fieldByIndex:i] asString];
                // conditional field formatting.
                if ([[[col objectAtIndex:i] name] isEqualToString:@"duration"])
                {
                    //NSLog(@"Duration Formatter");
                    field = [self durationFormatter:field];
                } else if ([[[col objectAtIndex:i] name] isEqualToString:@"modifiedtimestamp"])
                {
                    //NSLog(@"timestamp Formatter");
                    field = [self timeFormatter:field];
                }
                
                [rowResults addObject:field] ;
            }
            [results addObject:[rowResults copy]];
            [rs moveNext];
        }
        
    }
    [rs close];
    [self closeDb];
    return [results copy];
}

-(NSArray *)listFiles
{
    // copy of listFilesMatching but with different query.
    NSString *query = [NSString stringWithFormat:@"select %@ FROM clips where umid!='' and not longnameid like 'MLT%%'",columns];
    return [self executeQuery:query];

}
/*
-(NSArray *)listFilesMatching:(NSString *)s
{
    
    NSString *qs = [dbConnection sqlEncodeString:s];  // hoping this protects from sql exploits
    NSString *query = [NSString stringWithFormat:@"select %@ FROM clips where umid!='' and longnameid like '%@' and not longnameid like 'MLT%%'",columns,qs];
    
    return [self executeQuery:query];
}
*/
// Probably class method
- (NSString *)durationFormatter:(NSString *)frameString
{
    NSInteger frameLong = [frameString intValue];
    
    int frame = frameLong % 25;
    int second = (frameLong / 25 ) % 60;
    int minute = (frameLong / 1500) % 60;
    long hour = (frameLong / 90000);
    
    return [NSString stringWithFormat:@"%02ld:%02d:%02d:%02d",hour,minute,second,frame];
    
}

// Probably class method
- (NSString *)timeFormatter:(NSString *)timeString
{

    NSInteger harrisOffset = 126227808000000000L; // Cocoa epoch in NTFS epoch (GMT)

    NSInteger timeLong = ([timeString integerValue] - harrisOffset) / 10000000;
    NSDate *modifiedTime = [NSDate dateWithTimeIntervalSinceReferenceDate:timeLong];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [df setTimeZone:[NSTimeZone systemTimeZone]];
    
    return [df stringFromDate:modifiedTime];
}

-(void)setDBServer:(NSInteger)i
{
    if ([dbList count] >= i)
        dbServer = [dbList objectAtIndex:i];
}

// all ftp moved to Download/Publish Controller

@end
