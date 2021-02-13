//
//  BrowseActionListener.m
//  iHarris
//
//  Created by Mark Heath on 29/11/18.
//  Copyright © 2018 Nine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BrowseActionListener.h"

@implementation BrowseActionListener

-(id)initWithField:(NSTextFieldCell *)t title:(NSString *)tt mode:(int)m
{
	self = [super init];
	tf = t;
	title = [[NSString alloc] initWithString:tt];
	mode = m;
	return self;
}

-(id)initWithField:(NSTextFieldCell *)t title:(NSString *)tt
{
	return [self initWithField:t title:tt mode:1];
}


- (void)actionPerformed:(NSEvent *)theEvent
{
	
	bool chooseFiles = mode & 1;  // for upload
	bool chooseDir = mode & 2; // for save
	
	NSOpenPanel *open;
	open = [NSOpenPanel openPanel];
	
	[open setCanChooseFiles:chooseFiles];
	
	[open setCanChooseDirectories:chooseDir];
	[open setCanCreateDirectories:chooseDir];
	[open setAllowsMultipleSelection:false]; // enforce highlander challenge
	
	[open setTitle:title];
	
  //  if ([open runModal] == NSFileHandlingPanelOKButton)
	if ([open runModal] == 1)
	{
		// highlander pattern, there really is only 1
		for (NSURL *URL in [open URLs])
			[tf setTitle:[URL path]];
		
	}
	
}


@end
