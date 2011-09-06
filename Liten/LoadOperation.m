#import "LoadOperation.h"

@implementation LoadOperation

// NSNotification name to tell the Window controller a duplicate file was found
NSString *LoadImageDidFinish = @"LoadDuplicateDidFinish";

// -------------------------------------------------------------------------------
//	initWithPath:path
// -------------------------------------------------------------------------------
- (id)initWithPath:(NSString *)path
{
	self = [super init];
    loadPath = path;

    return self;
}
// -------------------------------------------------------------------------------
//	isDuplicateFile:filePath
//  We check to see if we need to even bother reporting this file.
- (BOOL)isDuplicateFileReportable:(NSString *)filePath
{
    BOOL isReportable = NO;
    FSRef fileRef;
    Boolean isDirectory;

    if (FSPathMakeRef((const UInt8 *)[filePath fileSystemRepresentation], &fileRef, &isDirectory) == noErr)
    {
		
		isReportable = YES;
	}
    return isReportable;
}

- (NSString *)stringFromFileSize:(int)theSize
{
	float floatSize = theSize;
	if (theSize<1023)
		return([NSString stringWithFormat:@"%i bytes",theSize]);
	floatSize = floatSize / 1024;
	if (floatSize<1023)
		return([NSString stringWithFormat:@"%1.1f KB",floatSize]);
	floatSize = floatSize / 1024;
	if (floatSize<1023)
		return([NSString stringWithFormat:@"%1.1f MB",floatSize]);
	floatSize = floatSize / 1024;
	
	// Add as many as you like
	
	return([NSString stringWithFormat:@"%1.1f GB",floatSize]);
}


-(void)main
{	

	if (![self isCancelled])
        
        
        @try {

            //The Try block
        
	{
		// test to see if it's a duplicate file
		if ([self isDuplicateFileReportable: loadPath])
		{
			// in this example, we just get the file's info (mod date, file size) and report it to the table view
			FSRef ref;
			Boolean isDirectory;
			if (FSPathMakeRef((const UInt8 *)[loadPath fileSystemRepresentation], &ref, &isDirectory) == noErr)
			{
				FSCatalogInfo catInfo;
				if (FSGetCatalogInfo(&ref, (kFSCatInfoContentMod | kFSCatInfoDataSizes), &catInfo, nil, nil, nil) == noErr)
				{
					CFAbsoluteTime cfTime;
					if (UCConvertUTCDateTimeToCFAbsoluteTime(&catInfo.contentModDate, &cfTime) == noErr)
					{
						CFDateRef dateRef = nil;
						dateRef = CFDateCreate(kCFAllocatorDefault, cfTime);
						if (dateRef != nil)
						{
							NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
							[formatter setTimeStyle:NSDateFormatterNoStyle];
							[formatter setDateStyle:NSDateFormatterShortStyle];
							
							NSString *modDateStr = [formatter stringFromDate:(__bridge_transfer NSDate*)dateRef];
							
							//Get byte size
							NSFileManager *man = [[NSFileManager alloc] init];
							NSDictionary *attrs = [man attributesOfItemAtPath: loadPath error: NULL];
							unsigned long long fileSize = [attrs fileSize];
							int nfileSize = (int) fileSize;
							//Convert to human readable string
							NSString *humanFileSize = [self stringFromFileSize: nfileSize];
							NSNumber *sNumber;
							sNumber = [[NSNumber alloc] initWithInt:fileSize];
							NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
														[loadPath lastPathComponent], @"name",
														[loadPath stringByDeletingLastPathComponent], @"path",
														modDateStr, @"modified",
														//[NSString stringWithFormat:@"%llu", fileSize], @"size",
														sNumber, @"size",
														humanFileSize , @"hsize",
														nil];
						
							if (![self isCancelled])
							{
					
								[[NSNotificationCenter defaultCenter] postNotificationName:LoadImageDidFinish object:nil userInfo:info];
							}
							
							CFRelease(dateRef);
						}
					}
				}		
			}
		}
	}

    }
    @catch (NSException *exception) {
        NSLog(@"Load Operation EXCEPTION!: %@ | Path: %@" , exception, loadPath);
    }


}

@end
