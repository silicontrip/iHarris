//
//  Harris.h
//  iHarris
//
//  Created by Mark Heath on 30/11/18.
//  Copyright © 2018 Nine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PGSQLKit/PGSQLKit.h>
#import "AppDelegate.h"
#include <curl/curl.h>
#include <stdio.h>
#include <stdatomic.h>

NS_ASSUME_NONNULL_BEGIN

@interface Harris : NSObject
{
    //NSArray<NSString *> *mgxList;
    //NSArray<NSString *> *dbList;

	atomic_flag columnSet;
	atomic_flag resultSet;
	
    NSUserDefaults *defaults ;
    
	//NSURL *ftpServer;
	//NSString *dbServer;

	PGSQLConnection *dbConnection;
	// NSString *columns;
	
	//NSLock* columnResultLock;
	//NSLock* resultLock;
	
	NSMutableArray<PGSQLConnection*>* dbConnectionList;
	NSMutableArray<dispatch_block_t>* dbBlockTasks;
	
	// dispatch_group_t dbQueryGroup;
	
    struct FtpFile {
        const char *filename;
        FILE *stream;
    };
}

-(id)init;
-(BOOL)openDb;
//-(NSArray *)listFilesMatching:(NSString *)s;
-(NSArray *)listFiles;
-(NSArray *)listColumns;
// -(void)setDBServer:(NSInteger)i;

- (void)updateColumns;
- (void)updateFiles;

+ (NSString *)durationFormatter:(NSString *)frameString;
+ (NSString *)timeFormatter:(NSString *)timeString;

// -(void)setFtpServer:(NSInteger)i;
// -(BOOL)getFileName:(NSString *)name;
// -(BOOL)getFileName:(NSString *)name target:(NSString *)target;
// -(BOOL)getFileName:(NSString *)name handle:(NSFileHandle *)local;

@end

NS_ASSUME_NONNULL_END
