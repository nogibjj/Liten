#import <Cocoa/Cocoa.h>

// NSNotification name to tell the Window controller a duplicate file was found
extern NSString *LoadImageDidFinish;

@interface LoadOperation : NSOperation
{
	NSString *loadPath;
	
}

- (id)initWithPath:(NSString *)path;
- (NSString *)stringFromFileSize:(int)theSize;

@end
