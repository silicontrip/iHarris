#import <Cocoa/Cocoa.h>

@interface BrowseActionListener : NSObject  {
	NSTextFieldCell *tf;
	NSString *title;
	int mode;
}
- (id)initWithField:(NSTextFieldCell *)tf title:(NSString *)tt mode:(int)m;
- (id)initWithField:(NSTextFieldCell *)tf title:(NSString *)tt;

- (void)actionPerformed:(NSEvent *)theEvent;

@end

