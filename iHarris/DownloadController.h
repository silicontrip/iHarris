//
//  DownloadController.h
//  iHarris
//
//  Created by Client Administrator on 10/12/2018.
//  Copyright © 2018 Client Administrator. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BrowseActionListener.h"
#import "Harris.h"
#import "AppDelegate.h"

@interface DownloadController : NSViewController
{
    IBOutlet NSTextFieldCell *downloadDirText; // Download
    IBOutlet NSTextFieldCell *downloadClipText; // Download
    IBOutlet NSPopUpButtonCell *formatText; // Download
    BrowseActionListener *downloadBrowseListener;
    NSUserDefaults *defaults;
    Harris *harris;
}

- (IBAction)download:(id)sender;
- (IBAction)downloadBrowse:(id)sender;

@end
