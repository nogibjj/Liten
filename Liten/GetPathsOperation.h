#import <Cocoa/Cocoa.h>

@interface GetPathsOperation : NSOperation
{
	NSString			*rootPath;
	NSString			*filterSize;
	NSOperationQueue	*queue;
	Class				opClass;
}

- (id)initWithRootPath:(NSString *)pp operationClass:(Class)cc queue:(NSOperationQueue *)qq filterSize:(NSString *) fs;
- (NSString *)createChecksum:(NSString *)fullPath;
- (unsigned long long)intFromFileSize:(NSString *)fileSize;

@end
