//
//  HarrisPrefsController.h
//  iHarris
//
//  Created by Mark Heath on 30/11/18.
//  Copyright © 2018 Nine. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HarrisPrefsController : NSViewController<NSTableViewDelegate, NSTableViewDataSource>
{
	IBOutlet NSTextFieldCell *mgxUsername;
	IBOutlet NSSecureTextFieldCell *mgxPassword;
	IBOutlet NSTableView *mgxServerList;
	
	IBOutlet NSTextFieldCell *dbUsername;
	IBOutlet NSSecureTextFieldCell *dbPassword;
	IBOutlet NSTableView *dbServerList;

	IBOutlet NSArrayController *mgxArrayController;
	IBOutlet NSArrayController *dbArrayController;
	
    IBOutlet NSTextFieldCell *downloadPath;
    IBOutlet NSTextFieldCell *previewPath;
    
    IBOutlet NSTextFieldCell *stillPath;
    IBOutlet NSMenu *transcodeFormat;
    IBOutlet NSPopUpButton *transcodeButton;
    
	NSUserDefaults *defaults;
	
}

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)addMgx:(id)sender;
- (IBAction)addDb:(id)sender;

- (void)setUIFromDefaults;
- (void)setTitle:(NSCell *)cell forKey:(NSString *)key;

- (NSArray<NSString *> *)getMgxNameList;
- (NSArray<NSString *> *)getMgxIpList;
- (NSArray<NSString *> *)getDbNameList;
- (NSArray<NSString *> *)getDbIpList;

@end

NS_ASSUME_NONNULL_END
