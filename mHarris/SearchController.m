//
//  SearchController.m
//  iHarris
//
//  Created by Client Administrator on 10/12/2018.
//  Copyright © 2018 Client Administrator. All rights reserved.
//

#import "SearchController.h"

@interface SearchController ()

@end

@implementation SearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    //NSLog(@"Search Controller view did load");
    
    AppDelegate *ad = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    // user settings
    columnWidthDefaults = @{
                            @"longnameid": @250,
                            @"modifiedtimestamp": @150,
                            @"duration": @100,
                            @"codecname": @150,
                            @"username":@150,
                            @"videoformatstring":@100
                            };
    
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
    
    /*
    if ([[searchResults arrangedObjects] count]==0)
        [self refresh:nil];
     */
}

- (IBAction)selectSearch:(id)sender {
	NSTableView *searchTable = (NSTableView *)sender;
	// NSLog(@"selectSearch: row %ld\n",[searchTable selectedRow]);
	
    if ([searchTable selectedRow] >= 0)
    {
        // show me the row,

        NSArray* searchArranged = [searchResults arrangedObjects];

        NSDictionary *row = [searchArranged objectAtIndex:[searchTable selectedRow]];
        [defaults setObject:[row objectForKey:@"longnameid"] forKey:@"selected clip"];
        [defaults setObject:[row objectForKey:@"videoformatstring"] forKey:@"selected format"];

	}
}

/*
- (void)tableViewColumnDidResize:(NSNotification *)notification
{
    NSLog(@"tableview column did resize");
}
*/

- (IBAction)beginDrag:(id)sender { ; }


- (void)updateColumnNames:(NSNotification*)n
{
	NSArray<NSString*>* names = [n object];
	
	for (NSString *s in names)
	{
		NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"%@",s]];
		[col setEditable:NO];
		
		// this is such horrible code
		// want to push this out to preferences.
		
		[col setWidth:[[columnWidthDefaults objectForKey:s] doubleValue]];
		[col setMinWidth:10]; // or something
		[[col headerCell] setStringValue:s];
		[col bind:@"value"
		 toObject:searchResults
	  withKeyPath:[NSString stringWithFormat:@"arrangedObjects.%@",s]
		  options:nil];
		
		[searchTableView addTableColumn:col];
	}
	
	// call update search?
	
}

- (void)updateSearchResults:(NSNotification*)n
{
	NSArray<NSArray*>* results = [n object];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HarrisProgressInit" object:results];
	
	for (NSArray *row in results)
	{
		// NSMutableDictionary *value = [[NSMutableDictionary alloc] init];
		NSDictionary *value;
		for (NSUInteger colNum=0; colNum < [row count]; ++colNum)
		{
			NSString* colData = [row objectAtIndex:colNum];
			// NSLog(@"Populating column: %lu: %@",colNum,colData);
			value = [NSDictionary dictionaryWithObjectsAndKeys:colData,[NSString stringWithFormat:@"%@",[colNames objectAtIndex:colNum]],nil];
			
			//[value setObject:colData forKey:[NSString stringWithFormat:@"%@",[colNames objectAtIndex:colNum]]];
			//colNum++;
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HarrisProgressUpdate" object:value];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HarrisProgressStop" object:nil];
}


- (void)initProgress:(NSNotification*)n
{
	NSArray* res = [n object];
	
	// move to properties
	[self->searchProgress setHidden:NO];
	[self->searchProgress setUsesThreadedAnimation:YES];
	[self->searchProgress setIndeterminate:YES];
	[self->searchProgress startAnimation:nil];
	[self->refreshButton setEnabled:NO];
	
	[self->searchProgress stopAnimation:nil];
	[self->searchProgress setIndeterminate:NO];
	[self->searchProgress setDoubleValue:0];
	[self->searchProgress setMaxValue:[res count]];
}

- (void)updateProgress:(NSNotification*)n
{
	NSDictionary* value = [n object];
	[self->searchTableView reloadData];
	[self->searchResults addObject:value];
	[self->searchProgress incrementBy:1];

}

- (void)stopProgress:(NSNotification*)n
{
	[self->searchProgress setHidden:YES];
	[self->searchProgress stopAnimation:nil];
	[self->refreshButton setEnabled:YES];
}

- (IBAction)refresh:(id)sender {

	// NSArray<NSString *> *colNames = [harris listColumns];

		if ([[searchResults arrangedObjects] count]>0)
        {
            //NSLog(@"erasing old data");
        	// erase old data
            NSRange range= NSMakeRange(0,[[searchResults arrangedObjects] count]);
            [searchResults removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
			
			[harris updateFiles];
		} else {
			// NSLog(@"creating columns");
			[harris updateColumns];
		}
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

@end
