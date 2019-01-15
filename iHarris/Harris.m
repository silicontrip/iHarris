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
    [self setDBServer:0];
    
	dbConnection = [[PGSQLConnection alloc] init];
    
    //NSLog(@"Connection: %@:%@:%@",dbServer,dbUser,dbPass);
    
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
    dbConnection = nil;
}

-(NSArray *)listColumns
{
    // as colums is just a comma seperated string
    // couldn't this be optimised to just return an NSArray<NSString>
    
	if (dbConnection == nil)
		if (![self openDb])
            return nil;

	PGSQLRecordset *rs = nil;
	NSString *query = [NSString stringWithFormat:@"select %@ FROM clips limit 1",columns];
    
   // NSLog(@"query: %@",query);
    
	rs = [dbConnection open:query];
	if (rs != nil)
	{
        NSMutableArray<NSString *> * columnNames = [[NSMutableArray alloc] init];
        
        for (PGSQLColumn *pg in [rs columns])
            [columnNames addObject:[pg name]];
		return [columnNames copy];
    }
    NSLog(@"column search returned no results");
	return nil;
}

-(NSArray *)listFiles
{
	return [self listFilesMatching:@"%"];
}

-(NSArray *)listFilesMatching:(NSString *)s
{
    
    // this needs to be in a second thread
	if (dbConnection == nil)
        if (![self openDb])
            return nil;
    
	PGSQLRecordset *rs = nil;
	
	NSString *qs = [dbConnection sqlEncodeString:s];  // hoping this protects from sql exploits
	NSString *query = [NSString stringWithFormat:@"select %@ FROM clips where umid!='' and longnameid like '%@' and not longnameid like 'MLT%%'",columns,qs];
	
	NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:0];
	
	rs = [dbConnection open:query];
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
    [self closeDb];
	return [results copy];
}

- (NSString *)durationFormatter:(NSString *)frameString
{
    NSInteger frameLong = [frameString intValue];
    
    int frame = frameLong % 25;
    int second = (frameLong / 25 ) % 60;
    int minute = (frameLong / 1500) % 60;
    long hour = (frameLong / 90000);
    
    return [NSString stringWithFormat:@"%02ld:%02d:%02d:%02d",hour,minute,second,frame];
    
}

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

/*
-(NSArray *)listFilesMatchingAsDictionary:(NSString *)s
{
    
    // this needs to be in a second thread
    if (dbConnection == nil)
        if (![self openDb])
            return nil;
    
    PGSQLRecordset *rs = nil;
    
    NSString *qs = [dbConnection sqlEncodeString:s];  // hoping this protects from sql exploits
    NSString *query = [NSString stringWithFormat:@"select %@ FROM clips where umid!='' and longnameid like '%@'",columns,qs];
    
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:0];
    
    rs = [dbConnection open:query];
    if (rs != nil)
    {
        // NSInteger rowCount = [rs recordCount];
        
        while (![rs isEOF])
        {
            // copy with formatter...
            
            
            [results addObject:[rs dictionaryFromRecord]];
            [rs moveNext];
        }
        
    }
    return [results copy];
}
*/

-(void)setDBServer:(NSInteger)i
{
    if ([dbList count] > 0)
        dbServer = [dbList objectAtIndex:i];
}

// considering moving all the ftp code into the controller classes
/*
-(void)setFtpServer:(NSInteger)i
{
    mgxList = [defaults objectForKey:@"MgxIps"];
    
    if ([mgxList count] > 0)
    {
        NSString *url = [NSString stringWithFormat:@"ftp://%@:%@@%@:2098/",[defaults stringForKey:@"MgxUsername"],[defaults stringForKey:@"MgxPassword"],[mgxList objectAtIndex:i]];
        ftpServer = [NSURL URLWithString:url];
    }
}

-(BOOL)getFileName:(NSString *)name
{
	//NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:name];
	return [self getFileName:name target:name];
}
*/

// move to Download Controller
// hmmm mixing C and obj-c
static size_t my_fwrite(void *buffer, size_t size, size_t nmemb, void *stream)
{
    struct FtpFile *out = (struct FtpFile *)stream;
    if(out && !out->stream) {
        /* open file for writing */
        NSLog(@"my_fwrite callback opening file: %s\n",out->filename);
        out->stream = fopen(out->filename, "wb");
        if(!out->stream)
            return -1; /* failure, can't open file to write */
    }
  //  NSLog(@"my_fwrite callback writing data: %zu x %zu\n",size,nmemb);
    size_t bw = fwrite(buffer, size, nmemb, out->stream);
  //  NSLog(@"bytes written: %zu\n",bw);
    return bw;
}

-(BOOL)getFileName:(NSString *)name target:(NSString *)target
{
	CURL *curl;
    CURLcode res;
    struct FtpFile ftpfile = {
        [target UTF8String], /* name to store the file as if successful */
        NULL
    };
    curl = curl_easy_init();
    if(curl) {
        NSLog(@"FTP Server %@",[[ftpServer absoluteString] stringByAppendingString:name]);
        curl_easy_setopt(curl, CURLOPT_URL, [[[ftpServer absoluteString] stringByAppendingString:name] UTF8String]);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, my_fwrite);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &ftpfile);
        curl_easy_setopt(curl, CURLOPT_FTP_USE_EPSV,0L); // because harris doesn't support EPSV only PASV
       // curl_easy_setopt(curl, CURLOPT_NOBODY,1L); // do not perform dir list (yeah but dont download file either)
        curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L); // for debugging only.
        NSLog(@"curl_easy_perform\n");
        res = curl_easy_perform(curl);
        curl_easy_cleanup(curl);
        NSLog(@"curl response: %d\n", res);

        // 18 is expected because MGX isn't a real ftp server
        if(CURLE_OK != res) {
            /* we failed */
            fprintf(stderr, "curl told us %d\n", res);
            if(ftpfile.stream)
                fclose(ftpfile.stream);
            return NO;
        }
    }
    if(ftpfile.stream)
        fclose(ftpfile.stream); /* close the local file */
    
    curl_global_cleanup();
    
    return YES;
}
@end
