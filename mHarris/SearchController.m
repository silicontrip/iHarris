//
//  SearchController.m
//  iHarris
//
//  Created by Client Administrator on 10/12/2018.
//  Copyright © 2018 Client Administrator. All rights reserved.
//

#import "SearchController.h"

@implementation SearchController

@synthesize selectionSet;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    
    //NSLog(@"Search Controller view did load");
    
    AppDelegate *ad = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    // user settings

/*
    columnWidthDefaults = @{
                            @"longnameid": @250,
                            @"modifiedtimestamp": @150,
                            @"duration": @100,
                            @"codecname": @150,
                            @"username":@150,
                            @"videoformatstring":@100
                            };
*/
   // [searchTableView setDraggingDestinationFeedbackStyle:(NSTableViewDraggingDestinationFeedbackStyle)]

	[searchTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];

  //  id pb = [NSPasteboard pasteboardWithName:@"NSFilenamesPboardType"];
  //  [searchTableView registerForDraggedTypes:[NSArray arrayWithObject:(NSString*)kUTTypeFileURL]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateColumnNames:) name:@"HarrisColumnsUpdate" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSearchResults:) name:@"HarrisSearchUpdate" object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:@"HarrisProgressUpdate" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initProgress:) name:@"HarrisProgressInit" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopProgress:) name:@"HarrisProgressStop" object:nil];

	//[dc addObserver:self selector:@selector(textDidEndEditing:) name:@"NSControlTextDidEndEditingNotification" object:[w outlineAtIndex:0]];

	harris = [ad harris];
	defaults = [ad defaults];
	
}

// - (void)initViewHeaderMenu:(id)view {
	
- (void)initTableColumnNames
{
	//create our contextual menu
	NSMenu *menu = [cifsColumns menu];
	
	AppDelegate *ad = (AppDelegate *)[[NSApplication sharedApplication] delegate];
	NSDictionary<NSString*,NSNumber*>* columnVisible = [[ad defaults] dictionaryForKey:@"ColumnNames"];
	
	//loop through columns, creating a menu item for each
	for (NSTableColumn *col in [searchTableView tableColumns]) {

		NSString* columnTitle = [col.headerCell stringValue];
		bool vis = [[columnVisible objectForKey:columnTitle] boolValue];
		if ([columnTitle isEqualToString:@"longnameid"])
			vis = YES;
		
		[col setHidden:!vis];
		
		NSMenuItem *mi = [[NSMenuItem alloc] initWithTitle:columnTitle
													action:@selector(toggleColumn:)  keyEquivalent:@""];
		mi.target = self;
		mi.representedObject = col;
		mi.state = vis?NSOnState:NSOffState;
		[menu addItem:mi];
	}
	return;
}

- (void)toggleColumn:(id)sender
{
	// get user defaults
	
	NSLog(@">>> [SearchController toggleColumn:]");
	
	AppDelegate *ad = (AppDelegate *)[[NSApplication sharedApplication] delegate];

	NSMutableDictionary<NSString*,NSNumber*>* defaultColumns = [NSMutableDictionary dictionaryWithDictionary:[[ad defaults] dictionaryForKey:@"ColumnNames"]];
	if (!defaultColumns)
		defaultColumns = [NSMutableDictionary dictionaryWithCapacity:32];
	NSMenuItem* mi = (NSMenuItem*)sender;
	NSLog(@"[SearchController toggleColumnName:%@]",[mi title]);
	// defaults column name
	NSNumber* columnVisible = [defaultColumns objectForKey:[mi title]];
	NSLog(@"[SearchController toggleColumnNumber:%@",columnVisible);
	// if defaults[columnname]==true
	bool newVis = NO;
	NSTableColumn *col = [sender representedObject];

	if (![columnVisible boolValue])
	{
		NSLog(@"[SearchController toggleColumnVisible:YES]");

		[col setHidden:NO];
		mi.state = NSOnState;
		newVis = YES;
	} else {
		NSLog(@"[SearchController toggleColumnVisible:NO]");

		[col setHidden:YES];
		mi.state = NSOffState;
		newVis = NO;
	}
	// set user defaults...
	[defaultColumns setValue:@(newVis) forKey:[mi title]];
	[[ad defaults] setObject:[defaultColumns copy] forKey:@"ColumnNames"];
}

- (IBAction)selectSearch:(id)sender
{
	
	NSTableView *searchTable = (NSTableView *)sender;
	AppDelegate *ad = (AppDelegate *)[[NSApplication sharedApplication] delegate];

	NSLog(@">>> [SearchController selectSearchNSIndexSet:%@",searchTable.selectedRowIndexes);
	
	//NSLog(@"selectSearch: row %ld\n",[searchTable selectedRow]);

	ad.selectedRowIndexes = searchTable.selectedRowIndexes;
	ad.searchResults = searchResults;
	
	//NSLog(@"%@",searchContent);
}

/*
- (void)tableViewColumnDidResize:(NSNotification *)notification
{
    NSLog(@"tableview column did resize");
}
*/

- (IBAction)beginDrag:(id)sender {
	NSLog(@"Drag, drag, drag, drag is the bag!");
	;
	
}


- (void)updateColumnNames:(NSNotification*)n
{
	//NSLog(@">>> [SearchController updateColumnNames]");

	NSArray<NSString*>* names = [n object];

	//NSDictionary<NSString*,NSNumber*>columnVis = [[ad defaults] dictionaryForKey:@""];
	
	for (NSString *s in names)
	{
		NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier:s];
		[col setEditable:NO];
		
		// this is such horrible code
		// want to push this out to preferences.
		
		//[col setWidth:[[columnWidthDefaults objectForKey:s] doubleValue]];
		[col setWidth:150];
		[col setMinWidth:10]; // or something
		[[col headerCell] setStringValue:s];
		[col bind:@"value"
		 toObject:searchResults
	  withKeyPath:[NSString stringWithFormat:@"arrangedObjects.%@",s]
		  options:nil];
		
		[searchTableView addTableColumn:col];
	}
	
	[self initTableColumnNames];
	
	// call update search?
	// [harris updateFiles];
}

- (void)updateSearchResults:(NSNotification*)n
{
	NSLog(@">>> [SearchController updateSearchResults]");
	
	NSArray<NSDictionary*>* results = [n object];
	
	NSLog(@"[SearchController updateSearchResults:count %lu]",[results count]);
	NSLog(@"[SearchController column:count %lu]",[[results firstObject] count]);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HarrisProgressInit" object:results];
	
	for (NSDictionary *row in results)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HarrisProgressUpdate" object:row];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HarrisProgressStop" object:nil];
}


- (void)initProgress:(NSNotification*)n
{

	NSArray* res = [n object];
	
	//NSLog(@">>> [SearchController initProgress:%lu]",[res count]);

	
	[self->searchProgress setHidden:NO];
	[self->searchProgress setUsesThreadedAnimation:YES];
	[self->searchProgress setIndeterminate:YES];
	[self->searchProgress startAnimation:nil];
	
	[self->refreshButton setEnabled:NO];
	
	[self->searchProgress setDoubleValue:0];
	[self->searchProgress setMaxValue:[res count]];
}

- (void)updateProgress:(NSNotification*)n
{
	// NSLog(@">>> [SearchController updateProgress]");

	[self->searchProgress stopAnimation:nil];
	[self->searchProgress setIndeterminate:NO];
	
	NSDictionary* value = [n object];
	[self->searchTableView reloadData];
	[self->searchResults addObject:value];
	[self->searchProgress incrementBy:1];

}

- (void)stopProgress:(NSNotification*)n
{
	// NSLog(@">>> [SearchController stopProgress]");

	[self->searchProgress setHidden:YES];
	[self->searchProgress stopAnimation:nil];
	[self->refreshButton setEnabled:YES];
}

- (IBAction)refresh:(id)sender {

	//NSLog(@">>> [SearchController refresh]");
	// NSArray<NSString *> *colNames = [harris listColumns];

	[[NSNotificationCenter defaultCenter] postNotificationName:@"HarrisProgressInit" object:nil];
	[harris updateColumns];
	
	if ([[searchResults arrangedObjects] count]>0)
	{
		//NSLog(@"erasing old data");
		// erase old data
		NSRange range= NSMakeRange(0,[[searchResults arrangedObjects] count]);
		[searchResults removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
	}
	[harris updateFiles];

}

- (IBAction)updateFilter:(id)sender {
	// NSSearchField *search = sender;
	//  NSLog(@"update filter: %@", [search stringValue]);

	if ([[sender stringValue] length] == 0)
		[searchResults setFilterPredicate:nil];
	else
	{
		NSPredicate *filt = [NSPredicate predicateWithFormat:@"longnameid CONTAINS[cd] %@",[sender stringValue]];
		[searchResults setFilterPredicate:filt];
	}
}

- (IBAction)saveToLocal:(id)sender
{
	AppDelegate *ad = (AppDelegate *)[[NSApplication sharedApplication] delegate];

	NSLog(@"[SearchController saveToLocal:]");
	
	[ad saveToLocal:sender];
	
}

- (IBAction)importPremiere:(id)sender
{
	AppDelegate *ad = (AppDelegate *)[[NSApplication sharedApplication] delegate];
	[ad importPremiere:sender];
}
	
@end
