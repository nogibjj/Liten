#import "GetPathsOperation.h"
#import "LoadOperation.h"

@implementation GetPathsOperation

// -------------------------------------------------------------------------------
//	initWithRootPath:
// -------------------------------------------------------------------------------
- (id)initWithRootPath:(NSString *)pp operationClass:(Class)cc queue:(NSOperationQueue *)qq filterSize:(NSString *)fs
{
    self = [super init];
	
    // the operation class must have an -initWithPath: method.
    if (![cc instancesRespondToSelector:@selector(initWithPath:)])
	{
		return nil;
    }
	
    rootPath = pp;
    opClass = cc;
    queue = qq;
	filterSize = fs;
	NSLog(@"VALUE: in GetPathsOperation: %@", fs);
	//Set Max Threads
	[queue setMaxConcurrentOperationCount:2];
	
    return self;
}

// -------------------------------------------------------------------------------
//	createChecksum:
// -------------------------------------------------------------------------------

- (NSString *)createChecksum:(NSString *)fullPath
{
	//Since the btye size has been found we should do a sha 256 analysis
	NSTask *task;
	task = [[NSTask alloc] init];
	[task setLaunchPath: @"/usr/bin/shasum"];
	
	NSArray *arguments;
	arguments = [NSArray arrayWithObjects: @"-a", @"1", fullPath,nil];
	[task setArguments: arguments];
	
	NSPipe *cPipe;
	cPipe = [NSPipe pipe];
	[task setStandardOutput: cPipe];
	
	NSFileHandle *file;
	file = [cPipe fileHandleForReading];
	
	[task launch];
	[task waitUntilExit];
	
	NSData *data;
	data = [file readDataToEndOfFile];
	
	NSString *rawString;
	rawString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	NSArray *chunks = [rawString componentsSeparatedByString: @" "];
	NSString *shaHash = [chunks objectAtIndex: 0];
	NSLog(@"DIGEST:%@", shaHash);
	
	return shaHash;
}


// -------------------------------------------------------------------------------
//	intFromFileSize:
// -------------------------------------------------------------------------------

- (unsigned long long)intFromFileSize:(NSString *)fileSize
{

	if ([fileSize isEqualToString:@"KB"])
		{
		unsigned long long KB = 1024;//1K Files
		return KB;
		}
		
	if ([fileSize isEqualToString:@"MB"])
		{
		unsigned long long MB = 1048576;//1MB Files
		return MB;
		}
		
	if ([fileSize isEqualToString:@"GB"])
		{
		unsigned long long GB = 1073741824;//1GB Files
		return GB;
		}

	unsigned long long NoFilter = 0;//1K Files
	return NoFilter;//
}


// -------------------------------------------------------------------------------
//	main:
// -------------------------------------------------------------------------------
- (void)main
{	
    
    // iterate through the contents of "rootPath"
	NSString* sourceDirectoryFilePath = nil;
	NSDirectoryEnumerator* sourceDirectoryFilePathEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:rootPath];
	NSMutableDictionary* fileSizeDict = [NSMutableDictionary dictionary];
	NSMutableDictionary* hashDict = [NSMutableDictionary dictionary];
	while (sourceDirectoryFilePath = [sourceDirectoryFilePathEnumerator nextObject])
	{
		
		if ([self isCancelled])
		{
			NSLog(@"UI STOP Button Selected:  Directory Search 'break'");
			break;	// user cancelled this operation
		}
				
		NSDictionary *sourceDirectoryFileAttributes = [sourceDirectoryFilePathEnumerator fileAttributes];		
		NSString *sourceDirectoryFileType = [sourceDirectoryFileAttributes objectForKey:NSFileType];
	
		
		if ([sourceDirectoryFileType isEqualToString:NSFileTypeRegular] == YES)
		{
			
			NSString *fullSourceDirectoryFilePath = [rootPath stringByAppendingPathComponent:sourceDirectoryFilePath];
		
			if (fullSourceDirectoryFilePath)
			{
												
				
				//TO DO:  Convert to a Method That Returns a Bool.
				//Discard Low Size Files
				NSFileManager *man = [[NSFileManager alloc] init];
				NSDictionary *attrs = [man attributesOfItemAtPath: fullSourceDirectoryFilePath error: NULL];
				unsigned long long fileSize = [attrs fileSize];
				NSLog(@"FILESIZE: %llu", fileSize);
				unsigned long long discardSize = [self intFromFileSize: filterSize];
				if (fileSize < discardSize ) {
					continue;
				}
				
                

                
                
				NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%llu", fileSize], @"size",
									  fullSourceDirectoryFilePath, @"fullPath",
									  nil];				

				
				//NSLog(@"Size: %@", [info objectForKey:@"size"]);
				NSLog(@"Path: %@", fullSourceDirectoryFilePath);
				if ([fileSizeDict objectForKey:[info objectForKey:@"size"]]) {
					NSLog(@"SIZEKEY MATCH");
					
					NSString *shaHash = [self createChecksum: fullSourceDirectoryFilePath];
					
					//Now Check for A Hash.  If so, we can proceed to notify UI
					//This is a bit tricky because we have to send the path in the hash as well, but only once.
					if ([hashDict objectForKey:shaHash]){
						
						NSLog(@"HASHKEY MATCH");
						//Three Part Approach to Updating UI.
						
						//Part 1:  Send Path from sizeDict
						
						//Check The sizeDict Path to see if has been used yet.
						//Use it to send an update to the UI, then 
						NSString *sizePath = [fileSizeDict objectForKey:[info objectForKey:@"size"]];
						NSLog(@"sizeDict PATH:%@", sizePath);
						if (sizePath != @""){
							LoadOperation *opSizePath = [[LoadOperation alloc] initWithPath:sizePath];
							[opSizePath setQueuePriority: 2];// set priority medium	
							[queue addOperation: opSizePath];
							//Now Update sizeDict to have an empty Path.
							[fileSizeDict setValue:@"" forKey:[info objectForKey:@"size"]];
							NSLog(@"set fileSizeDict to empty string: %@", [fileSizeDict objectForKey:[info objectForKey:@"size"]]);
							}
						
						//Part 2:  Send Path from hashDict
						
						//Check The hashDict Path to see if has been used yet.
						//Use it to send an update to the UI, then 
						NSString *hashPath = [hashDict objectForKey:shaHash];
						NSLog(@"hashDict PATH:%@", hashPath);
						if (hashPath != @""){
							LoadOperation *opHashPath = [[LoadOperation alloc] initWithPath:hashPath];
							[opHashPath setQueuePriority: 2];	// set priority
							[queue addOperation: opHashPath];	// this will start the load operation
							//Now Update sizeDict to have an empty Path.
							[hashDict setValue:@"" forKey:shaHash];
							NSLog(@"set hashDict to empty string: %@", [hashDict objectForKey:[info objectForKey:shaHash]]);
						}
						
						//Part 3:  Send Path from current walk
						//Finally Send the Path of the Current File to the UI
						LoadOperation *op = [[LoadOperation alloc] initWithPath:fullSourceDirectoryFilePath];
						[op setQueuePriority: 2];	// set priority
						[queue addOperation: op];	// this will start the load operation
						NSLog(@"Adding current path to UI: %@", fullSourceDirectoryFilePath);
					}
					
					//Conditions for handling Hash key not found.
					//Because the Hash is being generated for first time, we need to check to see if it matches
					else {
						NSLog(@"HASHKEY Not Found");
						NSString *sizePath = [fileSizeDict objectForKey:[info objectForKey:@"size"]];
						NSString *shaByteSize = [self createChecksum: sizePath];
						NSLog(@"shaByteSize: %@", shaByteSize);
						NSLog(@"shaHash: %@", shaHash);
						
						//Newly Created Hash Matches path in byteSize Dictionary.
						if ([shaHash isEqualTo: shaByteSize ]) { //Note, we compare the actual Hash Strings Here
							NSLog(@"HASHMATCH: shaHash and SizeHash Match: %@", fullSourceDirectoryFilePath);
							
							//We need to send two files to the UI.  The current file, and the file in the byte cache.
							
                            
                            //Send Btye Size Cache File To UI
							NSLog(@"Adding Btye Size Cache File: %@", sizePath);
                            LoadOperation *opSizePath = [[LoadOperation alloc] initWithPath:sizePath];
							[opSizePath setQueuePriority: 2];// set priority medium	
							[queue addOperation: opSizePath];
							[fileSizeDict setValue:@"" forKey:[info objectForKey:@"size"]];	
                            
                            //Send Current File To UI
                            NSLog(@"Adding current File: %@", fullSourceDirectoryFilePath   );
							LoadOperation *opCurrentSizePath = [[LoadOperation alloc] initWithPath:fullSourceDirectoryFilePath];
							[opCurrentSizePath setQueuePriority: 2];	// set priority
							[queue addOperation: opCurrentSizePath];	// this will start the load operation
							
							//Make the path empty, so it won't be processed again
							[hashDict setValue:@"" forKey:shaHash];	
						}
						//Set the Hash Path, because this is the first entry
						//This exits loop
						else {
							NSLog(@"Setting Initial Hash (NO HASHMATCH): %@", fullSourceDirectoryFilePath);
							[hashDict setValue:fullSourceDirectoryFilePath forKey:shaHash];
						}
						
					}
					//End Hash Key Not Found
					
					
				}
				//Place the byte size in the dictionary.
				else
				{
					
					NSLog(@"SIZEKEY Not Found");
					[fileSizeDict setValue:fullSourceDirectoryFilePath forKey:[info objectForKey:@"size"]];

					
					if ([self isCancelled])
					{
						NSLog(@"UI STOP Button Selected:  Load Operation 'break'");
						break;	// user cancelled this operation
					}
					
				}


                }

                
		
			}
		}
	

}

@end
