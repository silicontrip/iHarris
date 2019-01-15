//
//  PublishController.h
//  iHarris
//
//  Created by Client Administrator on 11/12/2018.
//  Copyright © 2018 Client Administrator. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import "BrowseActionListener.h"
#include <curl/curl.h>
#include <stdio.h>


@interface PublishController : NSViewController
{
    IBOutlet NSTextFieldCell *publishText;
    IBOutlet NSProgressIndicator *progress;
    BrowseActionListener *publishBrowseListener;
    NSInputStream *readFile;
    NSUserDefaults *defaults;
}

- (IBAction)publish:(id)sender;
- (IBAction)publishBrowse:(id)sender;

@end
