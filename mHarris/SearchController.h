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
   // IBOutlet NSSearchFieldCell *searchText; // Search
	
	IBOutlet NSTableView *searchTableView; // Search
	IBOutlet NSTableHeaderView* cifsColumns;
	IBOutlet NSArrayController *searchResults;
	// IBOutlet NSArray<NSDictionary<NSString*,NSString*>*>* searchContent;
	
	IBOutlet NSProgressIndicator *searchProgress; // for search progress... what else?
	IBOutlet NSButton *refreshButton; // for enabling/disabling
    
    Harris *harris;
    NSUserDefaults *defaults;
	// NSDictionary *columnWidthDefaults;
	
	NSArray<NSString *> *colNames;
	//IBOutlet
}

@property (weak) NSIndexSet* selectionSet;

- (void)viewDidLoad;

- (void)initTableColumnNames;

- (void)toggleColumn:(id)sender;
- (IBAction)selectSearch:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)updateFilter:(id)sender;

- (void)updateSearchResults:(NSNotification*)n;

- (void)initProgress:(NSNotification*)n;
- (void)updateProgress:(NSNotification*)n;
- (void)stopProgress:(NSNotification*)n;


//- (void)tableViewColumnDidResize:(NSNotification *)notification;
- (IBAction)beginDrag:(id)sender;

@end
