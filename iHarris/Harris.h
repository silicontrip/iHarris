//
//  Harris.h
//  iHarris
//
//  Created by Mark Heath on 30/11/18.
//  Copyright © 2018 Nine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PGSQLKit/PGSQLKit.h>
#include <curl/curl.h>
#include <stdio.h>

NS_ASSUME_NONNULL_BEGIN

@interface Harris : NSObject
{
    NSArray<NSString *> *mgxList;
    NSArray<NSString *> *dbList;

    NSUserDefaults *defaults ;
    
	NSURL *ftpServer;
	NSString *dbServer;

	PGSQLConnection *dbConnection;
	NSString *columns;
	
    struct FtpFile {
        const char *filename;
        FILE *stream;
    };
    
    
    // make an objective-c class instead
    /*
    struct NSFtp {
        NSString *filename;
        NSFileHandle *handle;
        NSView *dialog;
    };
     */
    
}

-(id)init;
-(BOOL)openDb;
-(NSArray *)listFilesMatching:(NSString *)s;
-(NSArray *)listFiles;
-(NSArray *)listColumns;
-(void)setDBServer:(NSInteger)i;

- (NSString *)durationFormatter:(NSString *)frameString;
- (NSString *)timeFormatter:(NSString *)timeString;

// -(void)setFtpServer:(NSInteger)i;
//-(BOOL)getFileName:(NSString *)name;
//-(BOOL)getFileName:(NSString *)name target:(NSString *)target;
// -(BOOL)getFileName:(NSString *)name handle:(NSFileHandle *)local;

@end

NS_ASSUME_NONNULL_END
