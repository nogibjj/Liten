#import "MyWindowController.h"
#import "GetPathsOperation.h"
#import "LoadOperation.h"


// -------------------------------------------------------------------------------
@interface MyWindowController (Private)

- (void)loadFilePaths:(NSString *)fromPath;
- (void)setResultsString:(NSString *)string;
- (void)updateProgress:(NSTimer *)t;
- (NSTimer *)timer;
- (void)setTimer:(NSTimer *)value;
- (void)updateCountIndicator;

@end

@implementation MyWindowController


// -------------------------------------------------------------------------------
//	awakeFromNib:
// -------------------------------------------------------------------------------
- (void)awakeFromNib
{	
	// register for the notification when a duplicate file has been loaded by the NSOperation: "LoadOperation"
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(anyThread_handleLoadedImages:) name:LoadImageDidFinish object:nil];
	
	// make sure double-click on a table row calls "doubleClickAction"
	[myTableView setTarget:self];
	[myTableView setDoubleAction:@selector(doubleClickAction:)];

}

// -------------------------------------------------------------------------------
//	init:
// -------------------------------------------------------------------------------
- (id)init
{
	[super init];
	
	queue = [[NSOperationQueue alloc] init];
	tableRecords = [[NSMutableArray alloc] init];

	return self;
}

-(void)setFileSizeLimit:(id)sender
{

	fs = sender;
	NSLog(@"Search Filter Size Set: %@", fs);
}


- (NSIndexSet *)selectedNodes { 
	return [myTableView selectedRowIndexes];	
}

//-(void)setSearchQuery:(id)sender
//{
//	
//	NSLog(@"searchQuery: %@" , searchQuery);
//}

// -------------------------------------------------------------------------------
//	updateCountIndicator:
//
//	Canned routine for updating the number of items in the table (used in several places).
// -------------------------------------------------------------------------------
-(void)updateCountIndicator
{
	// set the number of images found indicator string
	NSString *resultStr = [NSString stringWithFormat:@"Duplicates found: %ld", [tableRecords count]];
	[self setResultsString: resultStr];
}

// -------------------------------------------------------------------------------
//	applicationShouldTerminateAfterLastWindowClosed:sender
//
//	NSApplication delegate method placed here so the sample conveniently quits
//	after we close the window.
// -------------------------------------------------------------------------------
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	NSLog(@"sender: %@" ,sender);
    return YES;
}

// -------------------------------------------------------------------------------
//	mainThread_handleLoadedImages:note
//
//	The method used to modify the table's data source on the main thread.
//	This will cause the table to update itself once the NSArrayController is changed.
//
//	The notification contains an NSDictionary containing the image file's info
//	to add to the table view.
// -------------------------------------------------------------------------------
- (void)mainThread_handleLoadedImages:(NSNotification *)note
{
    // Pending NSNotifications can possibly back up while waiting to be executed,
	// and if the user stops the queue, we may have left-over pending
	// notifications to process.
	//
	// So make sure we have "active" running NSOperations in the queue
	// if we are to continuously add found image files to the table view.
	// Otherwise, we let any remaining notifications drain out.
	//
	if ([myStopButton isEnabled])
	{
		[tableRecords addObject:[note userInfo]];
		[myTableView reloadData];
		
		// set the number of duplicates found indicator string
		[self updateCountIndicator];
	}
}

// -------------------------------------------------------------------------------
//	anyThread_handleLoadedImages:note
//
//	This method is called from any possible thread (any NSOperation) used to 
//	update our table view and its data source.
//	
//	The notification contains the NSDictionary containing the image file's info
//	to add to the table view.
// -------------------------------------------------------------------------------
- (void)anyThread_handleLoadedImages:(NSNotification *)note
{
	// update our table view on the main thread
	[self performSelectorOnMainThread:@selector(mainThread_handleLoadedImages:) withObject:note waitUntilDone:NO];
}

// -------------------------------------------------------------------------------
//	alertDidEnd:
// -------------------------------------------------------------------------------
//-(void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
//{
//    NSLog(@"alert: %@", alert);
//    NSLog(@"returnCode: %@", returnCode);
//    NSLog(@"contextInfo: %@", contextInfo);
//}
// -------------------------------------------------------------------------------
//	windowShouldClose:
// -------------------------------------------------------------------------------
- (BOOL)windowShouldClose:(id)sender
{
	
    //NSLog(@"sender: %@", sender);
    // are you sure you want to close, (threads running)
	NSInteger numOperationsRunning = [[queue operations] count];
	
	if (numOperationsRunning > 0)
	{
		NSAlert *alert = [NSAlert alertWithMessageText: @"Duplicate files are currently loading."
									defaultButton: @"OK"
								  alternateButton: nil
									  otherButton: nil
						informativeTextWithFormat: @"Please click the \"Stop\" button before closing."];
		[alert beginSheetModalForWindow: [self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
	}
	
	return (numOperationsRunning == 0);
}

// -------------------------------------------------------------------------------
//	loadFilePaths:fromPath
// -------------------------------------------------------------------------------
-(void)loadFilePaths:(NSString *)fromPath
{
	[queue cancelAllOperations];
	
	// start the GetPathsOperation with the root path to start the search
	
	GetPathsOperation* getPathsOp = [[GetPathsOperation alloc] initWithRootPath:fromPath operationClass:[LoadOperation class] queue:queue filterSize:fs];
	
	[queue addOperation: getPathsOp];	// this will start the "GetPathsOperation"
	[getPathsOp release];
}

// -------------------------------------------------------------------------------
//	setResultsString:string
// -------------------------------------------------------------------------------
-(void)setResultsString:(NSString *)string
{
	[self willChangeValueForKey:@"duplicatesFoundStr"];
	duplicatesFoundStr = [NSMutableString stringWithString:string];
	[self didChangeValueForKey:@"duplicatesFoundStr"];
}

#pragma mark - Actions

//Context Menu Section

//Right Click Context Menu:  Search filename in Spotlight
- (IBAction) searchInSpotlight:(id)sender
{
	
	
	//NSLog(@"sender: %@", sender);
    //MULTIPLE SELECT CODE
	
	//Grab the selected rows
	//NSIndexSet *indexSet = [myTableView selectedRowIndexes];
	//NSLog(@"selectedNodes set: %@", indexSet);
	//NSUInteger currentIndex = [indexSet firstIndex];
	//NSLog(@"currentIndex: %lu", currentIndex);
	//NSUInteger idx = [indexSet indexGreaterThanOrEqualToIndex: 0];
	//while (idx != NSNotFound) {
		// idx equals the next index in the set.
	//	NSLog(@"currentIndex in loop: %lu", idx);
	//	NSDictionary* objectDict = [tableRecords objectAtIndex: idx];
	//		if (objectDict != nil){
	//			NSString *nameStr = [objectDict valueForKey: @"name"];
	//			NSLog(@"Right Click searchInSpotlight: %@ ", nameStr);
	//	[[NSWorkspace sharedWorkspace] showSearchResultsForQueryString:nameStr];
	//	
		//increment
	//	idx = [indexSet indexGreaterThanIndex: idx];
	//	}
	
	//}
	//NSUInteger idx = [indexSet indexGreaterThanOrEqualToIndex: 0];
	//NSLog(@"idx: %@", idx);
	//while (idx != NSNotFound) {
		// idx equals the next index in the set.
	//	idx = [indexSet indexGreaterThanIndex: idx];
	//	NSLog(@"%@", idx);
	//}	
	//END MULTIPLE SELECT CODE
	
	NSInteger clickedRow = [myTableView clickedRow];	
	if (clickedRow != -1)
	{
		NSDictionary* objectDict = [tableRecords objectAtIndex: clickedRow];
		if (objectDict != nil){
			NSString *nameStr = [objectDict valueForKey: @"name"];
			NSLog(@"Right Click searchInSpotlight: %@ ", nameStr);
			[[NSWorkspace sharedWorkspace] showSearchResultsForQueryString:nameStr];
		}
	}
}
- (IBAction)tableViewSelected:(id)sender
{
    int row = [sender selectedRow];
    NSLog(@"the user just clicked on row %d", row);
}
//Right Click Context Menu:  Move To Trash
- (IBAction) moveToTrash:(id)sender
{
	
	NSLog(@"sender: %@", sender);
	//MULTIPLE SELECT CODE
	//Grab the selected rows
	NSIndexSet *indexSet = [myTableView selectedRowIndexes];
	NSLog(@"selectedNodes set: %@", indexSet);
	//NSUInteger currentIndex = [indexSet firstIndex];
	//NSLog(@"currentIndex: %lu", currentIndex);
	 NSUInteger idx = [indexSet indexGreaterThanOrEqualToIndex: 0];
	while (idx != NSNotFound) {
		
		// idx equals the next index in the set.
		NSLog(@"currentIndex in loop: %lu", idx);
		NSDictionary* objectDict = [tableRecords objectAtIndex: idx];
		if (objectDict != nil){
			NSString *pathStr = [objectDict valueForKey: @"path"];
			NSString *completeURLStr = [pathStr stringByAppendingPathComponent:[objectDict valueForKey: @"name"]];
			NSLog(@"Right Click moveToTrash: %@ ", completeURLStr);
	//		
	//		NSArray *file = [NSArray arrayWithObject:[objectDict valueForKey: @"name"]];
	//		NSString *trashDir = [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
	//		
	//		[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
	//													 source:pathStr destination:trashDir files:file tag:nil];
	//
	//		//Update UI
			[tableRecords removeObjectAtIndex:idx];
			[myTableView reloadData];
	//		
	//		//increment
			//idx = [indexSet indexGreaterThanIndex: idx];
            //NSLog(@"idx: %lu", idx);
	//		
	}
	//END MULTIPLE SELECT CODE
		
	
	//NSInteger clickedRow = [myTableView clickedRow];
	//if (clickedRow != -1)
	//{
	//	NSDictionary* objectDict = [tableRecords objectAtIndex: clickedRow];
	//	if (objectDict != nil){
	//		NSString *pathStr = [objectDict valueForKey: @"path"];
			//NSString *completeURLStr = [pathStr stringByAppendingPathComponent:[objectDict valueForKey: @"name"]];
			//NSLog(@"Right Click moveToTrash: %@ ", completeURLStr);
	//		NSArray *file = [NSArray arrayWithObject:[objectDict valueForKey: @"name"]];
	//		NSString *trashDir = [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
	//		[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
	//													 source:pathStr destination:trashDir files:file tag:nil];
			//Update Table View
	//		[tableRecords removeObjectAtIndex:clickedRow];
			//Reload the Table View
	//		[myTableView reloadData];
	//	}		

	}
}
//Right Click Context Menu:  Reveal In Finder
- (IBAction) revealInFinder:(id)sender
{
	//NSLog(@"sender: %@", sender);
    NSInteger clickedRow = [myTableView clickedRow];
	if (clickedRow != -1)
	{
		NSDictionary* objectDict = [tableRecords objectAtIndex: clickedRow];
		if (objectDict != nil){
			NSString *pathStr = [objectDict valueForKey: @"path"];
			NSString *completeURLStr = [pathStr stringByAppendingPathComponent:[objectDict valueForKey: @"name"]];
			NSLog(@"Right Click revealInFinder: %@ ", completeURLStr);
			[[NSWorkspace sharedWorkspace] selectFile:completeURLStr inFileViewerRootedAtPath:completeURLStr];
	}
	}
	
}

// -------------------------------------------------------------------------------
//	createChecksum:
// -------------------------------------------------------------------------------

- (void)quickLookShell:(NSString *)fullPath
{

	NSTask *task;
	task = [[NSTask alloc] init];
	[task setLaunchPath: @"/usr/bin/qlmanage"];
	
	NSArray *arguments;
	arguments = [NSArray arrayWithObjects: @"-p", fullPath,nil];
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
	NSLog(@"QUICKLOOK:%@", rawString);
	
}

//Right Click Context Menu:  Quick Look Preview
- (IBAction) quickLookPreview:(id)sender
{
	//NSLog(@"sender: %@", sender);
    NSInteger clickedRow = [myTableView clickedRow];
	if (clickedRow != -1)
	{
		NSDictionary* objectDict = [tableRecords objectAtIndex: clickedRow];
		if (objectDict != nil){
			NSString *pathStr = [objectDict valueForKey: @"path"];
			NSString *completeURLStr = [pathStr stringByAppendingPathComponent:[objectDict valueForKey: @"name"]];
			NSLog(@"Right Click quickLookPreivew: %@ ", completeURLStr);
            [self quickLookShell: completeURLStr];

        }
	}
	
}

// -------------------------------------------------------------------------------
//	doubleClickAction:sender
//
//	Inspect our selected objects (user double-clicked them).
// -------------------------------------------------------------------------------
 - (void)doubleClickAction:(id)sender
{
	NSTableView *theTableView = (NSTableView *)sender;
	NSInteger selectedRow = [theTableView selectedRow];
	if (selectedRow != -1)
	{
		NSDictionary* objectDict = [tableRecords objectAtIndex: selectedRow];
		if (objectDict != nil)
		{
			NSString *pathStr = [objectDict valueForKey: @"path"];
			NSString *completeURLStr = [pathStr stringByAppendingPathComponent:[objectDict valueForKey: @"name"]];
			
			NSLog(@"doubleClick: %@ ", completeURLStr);
			[[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:completeURLStr]];
		}
	}
} 

// -------------------------------------------------------------------------------
//	stopAction:sender
// -------------------------------------------------------------------------------
- (IBAction)stopAction:(id)sender
{
	//NSLog(@"sender: %@", sender);
    [queue cancelAllOperations];
		
	[myStopButton setEnabled:NO];
	[myStartButton setEnabled:YES];

	[myProgressInd setHidden:YES];
	[myProgressInd stopAnimation:self];
	
	[self updateCountIndicator];
}

// -------------------------------------------------------------------------------
//	chooseDidEnd:panel:returnCode:contextInfo
// -------------------------------------------------------------------------------
-(void)chooseDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	//NSLog(@"contextInfo: %@", contextInfo);

    [panel orderOut:self];
	[panel release];
	
	if (returnCode == NSFileHandlingPanelOKButton)
	{
		// user has chosen a directory, start finding image files:
		
		[tableRecords removeAllObjects];	// clear the table data
		[self updateCountIndicator];
		
		[myStopButton setEnabled:YES];
		[myStartButton setEnabled:NO];
		
		[myProgressInd setHidden:NO];
		[myProgressInd startAnimation:self];
		
		[self loadFilePaths:[[panel URL] path]];	// start the file search NSOperation
		
		// schedule our update timer for the spinning gear control
        [self setTimer: [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                         target: self
                                                       selector: @selector(updateProgress:)
                                                       userInfo: nil
                                                        repeats: YES]];
	}
}

// -------------------------------------------------------------------------------
//	startAction:sender
// -------------------------------------------------------------------------------
- (IBAction)startAction:(id)sender
{	
	//NSLog(@"sender: %@", sender);
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
	
	[openPanel setResolvesAliases:YES];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseFiles:NO];
	[openPanel setPrompt:@"Choose"];
	[openPanel setMessage:@"Choose a directory to deduplicate:"];
	[openPanel setTitle:@"Choose"];
	
	[openPanel beginSheetForDirectory:nil file:nil types:nil modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(chooseDidEnd:returnCode:contextInfo:) contextInfo:nil];
}


#pragma mark - Timer Support

// -------------------------------------------------------------------------------
//	updateProgress:timer
// -------------------------------------------------------------------------------
-(void)updateProgress:(NSTimer *)t
{
	if ([[queue operations] count] == 0)
	{
		[t invalidate];
		[self setTimer: nil];
		
		[myProgressInd stopAnimation:self];
		[myProgressInd setHidden:YES];
		[myStopButton setEnabled:NO];
		[myStartButton setEnabled:YES];
		
		// set the number of images found indicator string
		[self updateCountIndicator];
	}
}

// -------------------------------------------------------------------------------
//	timer:
// -------------------------------------------------------------------------------
- (NSTimer *)timer
{
    return [[timer retain] autorelease];
}

// -------------------------------------------------------------------------------
//	setTimer:value
// -------------------------------------------------------------------------------
- (void)setTimer:(NSTimer *)value
{
    if (timer != value)
	{
        [timer release];
        timer = [value retain];
    }
}

#pragma mark - Data Source

// -------------------------------------------------------------------------------
//	numberOfRowsInTableView:aTableView
// -------------------------------------------------------------------------------
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	//NSLog(@"tableView: %@", aTableView);
    return [tableRecords count];
}

// -------------------------------------------------------------------------------
//	objectValueForTableColumn:aTableColumn:row
// -------------------------------------------------------------------------------
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    //NSLog(@"tableView: %@", aTableView);
    id theRecord, theValue;
    
    theRecord = [tableRecords objectAtIndex:rowIndex];
    theValue = [theRecord objectForKey:[aTableColumn identifier]];
    return theValue;
}

// -------------------------------------------------------------------------------
//	sortWithDescriptor:descriptor
// -------------------------------------------------------------------------------
- (void)sortWithDescriptor:(id)descriptor
{
	NSMutableArray *sorted = [[NSMutableArray alloc] initWithCapacity:1];
	[sorted addObjectsFromArray:[tableRecords sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]]];
	[tableRecords removeAllObjects];
	[tableRecords addObjectsFromArray:sorted];
	[myTableView reloadData];
	[sorted release];
}



// -------------------------------------------------------------------------------
//	didClickTableColumn:tableColumn
// -------------------------------------------------------------------------------
- (void)tableView:(NSTableView *)inTableView didClickTableColumn:(NSTableColumn *)tableColumn
{	
	NSArray *allColumns=[inTableView tableColumns];
	NSInteger i;
	for (i=0; i<[inTableView numberOfColumns]; i++) 
	{
		if ([allColumns objectAtIndex:i]!=tableColumn)
		{
			[inTableView setIndicatorImage:nil inTableColumn:[allColumns objectAtIndex:i]];
		}
	}
	[inTableView setHighlightedTableColumn:tableColumn];
	
	if ([inTableView indicatorImageInTableColumn:tableColumn] != [NSImage imageNamed:@"NSAscendingSortIndicator"])
	{
		
		[inTableView setIndicatorImage:[NSImage imageNamed:@"NSAscendingSortIndicator"] inTableColumn:tableColumn];  
		NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:[tableColumn identifier] ascending:YES];
		[self sortWithDescriptor:sortDesc];
		[sortDesc release];
		NSLog(@"Ascending Sort: %@", tableColumn);
	}
	else
	{
		[inTableView setIndicatorImage:[NSImage imageNamed:@"NSDescendingSortIndicator"] inTableColumn:tableColumn];
		NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:[tableColumn identifier] ascending:NO];
		[self sortWithDescriptor:sortDesc];
		NSLog(@"Descending Sort: %@", tableColumn);
		[sortDesc release];
	}
}

@end
