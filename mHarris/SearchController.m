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
   
     
    harris = [ad getHarris];
    defaults = [ad getDefaults];
    
    /*
    if ([[searchResults arrangedObjects] count]==0)
        [self refresh:nil];
     */
}

- (IBAction)selectSearch:(id)sender {
    NSTableView *searchTable = (NSTableView *)sender;
  //  NSLog(@"selectSearch: row %ld\n",[searchTable selectedRow]);
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

- (IBAction)beginDrag:(id)sender {
}

- (IBAction)refresh:(id)sender {
    [searchProgress setHidden:NO];
    [searchProgress setUsesThreadedAnimation:YES];
    [searchProgress setIndeterminate:YES];
    [searchProgress startAnimation:nil];
    [refreshButton setEnabled:NO];
    
        NSArray<NSString *> *colNames = [harris listColumns];

        
        if ([[searchResults arrangedObjects] count]>0)
        {
            NSLog(@"erasing old data");
        // erase old data
            NSRange range= NSMakeRange(0,[[searchResults arrangedObjects] count]);
            [searchResults removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
        } else {
       // NSLog(@"creating columns");

            for (NSString *s in colNames)
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
        
        }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       //NSLog(@"background thread");

        NSArray *res = [self->harris listFiles];
            unsigned long colNum=0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->searchProgress stopAnimation:nil];
            [self->searchProgress setIndeterminate:NO];
            [self->searchProgress setDoubleValue:0];
            [self->searchProgress setMaxValue:[res count]];
        });
        // NSLog(@"for rows");
        
            for (NSArray *row in res)
            {
                NSMutableDictionary *value = [[NSMutableDictionary alloc] init];
                colNum = 0;
                for (NSString *colData in row)
                {
           // NSLog(@"Populating column: %lu: %@",colNum,colData);
					[value setObject:colData forKey:[NSString stringWithFormat:@"%@",[colNames objectAtIndex:colNum]]];
                    colNum++;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                   // NSLog(@"main thread");
                    [self->searchTableView reloadData];
                    [self->searchResults addObject:value];
                    [self->searchProgress incrementBy:1];
                });
                //[searchProgress incrementBy:1];
            }
      //  NSLog(@"search table view reloadData");
       // [searchProgress setDoubleValue:100.0];
        

        dispatch_async(dispatch_get_main_queue(), ^{
           // NSLog(@"main thread");
          //  NSLog(@"stop animation");
            [self->searchProgress setHidden:YES];
            [self->searchProgress stopAnimation:nil];
            [self->refreshButton setEnabled:YES];

       });
      //  [searchProgress stopAnimation:nil];

        
    });

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
