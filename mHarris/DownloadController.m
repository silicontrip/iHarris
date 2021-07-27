//
//  DownloadController.m
//  iHarris
//
//  Created by Client Administrator on 10/12/2018.
//  Copyright © 2018 Client Administrator. All rights reserved.
//

#import "DownloadController.h"

@interface DownloadController ()

@end

@implementation DownloadController

- (void)viewDidLoad {
    [super viewDidLoad];
    //NSLog(@"download controller did load");

    // Do view setup here.
    downloadBrowseListener = [[BrowseActionListener alloc] initWithField:downloadDirText
                                                                   title:@"Select Download Directory"
                                                                    mode:2];
    
    AppDelegate *ad  = (AppDelegate *) [[NSApplication sharedApplication] delegate];
    harris = [ad harris];
    defaults = [ad defaults];
    
}

- (void)viewDidAppear
{
   // NSLog(@"view did appear\n");
    [super viewDidAppear];
    if ([defaults stringForKey:@"selected clip"])
        [downloadClipText setTitle:[defaults stringForKey:@"selected clip"]]; // these should be in a define somewhere
    if ([defaults stringForKey:@"default download path"])
        [downloadDirText setTitle:[defaults stringForKey:@"default download path"]];
   // NSLog(@"%@", [defaults stringForKey:@"selected clip"]);
    

}

// all this code should come out of Harris and into this controller

- (IBAction)download:(id)sender {
    // perform download
    //  set this after a sucessful download is performed
    [defaults setObject:[downloadDirText title] forKey:@"default download path"];
    
    NSString *download = [[downloadClipText title] stringByAppendingString:@"."];
    download = [download stringByAppendingString:[formatText title]];
    
    NSString *path = [[downloadDirText title] stringByAppendingString:@"/"];
    path = [path stringByAppendingString:download];
    
    NSLog(@"download path: %@\n",path);
    NSLog(@"clip name: %@\n",download);
    //NSLog(@"clip format: %@\n",[formatText title]);
    
    // fork this...
    // [harris getFileName:download target:path];
    
}
- (IBAction)downloadBrowse:(id)sender {
    [downloadBrowseListener actionPerformed:sender];
}
@end
