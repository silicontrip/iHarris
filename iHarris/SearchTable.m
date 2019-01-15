//
//  SearchTable.m
//  iHarris
//
//  Created by Client Administrator on 19/12/2018.
//  Copyright © 2018 Client Administrator. All rights reserved.
//

#import "SearchTable.h"

@implementation SearchTable

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSLog(@"SearchTable drawRect");
    
    // Drawing code here.
}

- (void)mouseDown:(NSEvent*)event
{
    NSLog(@"mouseDown");
   
    NSPasteboardItem *pbItem = [NSPasteboardItem new];
    [pbItem setDataProvider:self forTypes:[NSArray arrayWithObjects:NSPasteboardTypeString, nil]];
    NSDraggingItem *dragItem = [[NSDraggingItem alloc] initWithPasteboardWriter:pbItem];
    NSRect draggingRect = self.bounds;
  // [dragItem setDraggingFrame:draggingRect contents:[self image]];
    NSDraggingSession *draggingSession = [self beginDraggingSessionWithItems:[NSArray arrayWithObject:dragItem] event:event source:self];
    draggingSession.animatesToStartingPositionsOnCancelOrFail = YES;
    draggingSession.draggingFormation = NSDraggingFormationNone;
    
    [super mouseDown:event];

    
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    NSLog(@"draggingSession");

    switch (context) {
        case NSDraggingContextOutsideApplication:
            return NSDragOperationCopy;
        case NSDraggingContextWithinApplication:
        default:
            return NSDragOperationNone;
            break;
    }
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
    NSLog(@"acceptsFirstMouse");

    return YES;
}

- (void)pasteboard:(NSPasteboard *)sender item:(NSPasteboardItem *)item provideDataForType:(NSString *)type
{
    NSLog(@"pasteboard");

    /*
    if ( [type compare: NSPasteboardTypeTIFF] == NSOrderedSame ) {
        [sender setData:[[self image] TIFFRepresentation] forType:NSPasteboardTypeTIFF];
    } else if ( [type compare: NSPasteboardTypePDF] == NSOrderedSame ) {
        [sender setData:[self dataWithPDFInsideRect:[self bounds]] forType:NSPasteboardTypePDF];
    }
     */
    
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal {
    NSLog(@"draggingSourceOperationMaskForLocal");

    if (isLocal) return NSDragOperationNone;
        else return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView *)tv writeRows:(NSArray *)rows toPasteboard:(NSPasteboard *)pboard
{
    NSLog(@"writeRows");

    [pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
    NSMutableArray* dragfiles = [[NSMutableArray alloc] init];
    NSString* filepath = @"/Volumes/NEXIO1/MOV/";

    [dragfiles addObject:filepath];
    [pboard setPropertyList:dragfiles forType: NSFilenamesPboardType];
    return YES;
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    NSLog(@"writeRowsWithIndexes");
    [pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
    NSMutableArray* dragfiles = [[NSMutableArray alloc] init];
   // NSString* file = [self.files objectAtIndex:row];
   // NSString* filepath = [[[self.pathControl URL] path] stringByAppendingPathComponent:file];
    NSString* filepath = @"/Volumes/NEXIO1/MOV/";
    [dragfiles addObject:filepath];
    [pboard setPropertyList:dragfiles forType: NSFilenamesPboardType];
  //  [dragfiles release];
    return YES;
}

@end
