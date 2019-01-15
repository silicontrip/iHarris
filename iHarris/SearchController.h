//
//  SearchController.h
//  iHarris
//
//  Created by Client Administrator on 10/12/2018.
//  Copyright © 2018 Client Administrator. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

@interface SearchController : NSViewController
{
    IBOutlet NSSearchFieldCell *searchText; // Search
    IBOutlet NSTableView *searchTableView; // Search
    IBOutlet NSArrayController *searchResults;
    IBOutlet NSProgressIndicator *searchProgress;
    
    Harris *harris;
    NSUserDefaults *defaults;
    NSDictionary *columnWidthDefaults;
}

- (IBAction)selectSearch:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)updateFilter:(id)sender;
- (void)tableViewColumnDidResize:(NSNotification *)notification;
- (IBAction)beginDrag:(id)sender;

@end
