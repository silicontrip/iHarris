//
//  PublishController.m
//  iHarris
//
//  Created by Client Administrator on 11/12/2018.
//  Copyright © 2018 Client Administrator. All rights reserved.
//

#import "PublishController.h"

@interface PublishController ()

@end

@implementation PublishController

- (void)viewDidLoad {
    [super viewDidLoad];
    //NSLog(@"publish controller did load");

    AppDelegate *ad = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    defaults = [ad defaults];
    
    // Do view setup here.
    publishBrowseListener = [[BrowseActionListener alloc] initWithField:publishText
                                                                  title:@"Select Clip to Publish"
                                                                   mode:1];

}

static size_t read_callback(void *ptr, size_t size, size_t nmemb, void *stream)
{
    PublishController *parseSelf = (__bridge PublishController *)stream;
    NSUInteger maxBytes = size * nmemb;

    NSInteger bytesRead = [parseSelf->readFile read:ptr maxLength:maxBytes];

    dispatch_async(dispatch_get_main_queue(), ^{
        [parseSelf->progress incrementBy:bytesRead];
    });
    return bytesRead;
}

- (IBAction)publish:(id)sender {
    
    NSString *filePath  = [publishText title];
    readFile =[NSInputStream inputStreamWithFileAtPath:filePath];
    
    //NSLog(@"readfile: %@",readFile);
    
    NSArray *ftpServers = [defaults objectForKey:@"MgxIps"];
    
    if ([ftpServers count] > 0) {
        NSString *ftpServerIP = [ftpServers objectAtIndex:0];  // one day I'll have a concept of selected server
        if (readFile != nil)
        {
            NSInteger fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
            NSString *fileName = [filePath lastPathComponent];
            
            // fileName could be an arbitrary string, "upload as ..."
            NSString *ftpUrl = [NSString stringWithFormat:@"ftp://%@:2098/%@",ftpServerIP,fileName];
            
            [progress setHidden:NO];
            [progress setMinValue:0];
            [progress setMaxValue:fileSize];
            [progress setDoubleValue:0];
        
            CURL *curl;
            curl_global_init(CURL_GLOBAL_ALL);
        
            curl = curl_easy_init();
            
            curl_easy_setopt(curl, CURLOPT_READFUNCTION, read_callback);
            curl_easy_setopt(curl, CURLOPT_UPLOAD, 1L);
            curl_easy_setopt(curl, CURLOPT_URL, [ftpUrl UTF8String]);
            curl_easy_setopt(curl, CURLOPT_READDATA, self);
            curl_easy_setopt(curl, CURLOPT_INFILESIZE, fileSize);
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self->readFile open];
                CURLcode res = curl_easy_perform(curl);  // Blocks at this point while ftp transfers
                if(res != CURLE_OK)
                    NSLog(@"curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
                // should also alert

                
                /* always cleanup */ 
                curl_easy_cleanup(curl);
                [self->readFile close];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->progress setHidden:YES];
                });
            });
        
        } else {
            // alert error reading file...?
        }
    } else {
     // some alert that FTP servers aren't configured
    }
}

- (IBAction)publishBrowse:(id)sender {
    [publishBrowseListener actionPerformed:sender];
}


@end
