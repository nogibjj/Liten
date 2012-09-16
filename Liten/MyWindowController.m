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
	self = [super init];
	
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
	NSString *resultStr = [NSString stringWithFormat:@"Duplicates found: %u", [tableRecords count]];
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

//Right Click Context Menu:  Move To Trash
- (IBAction) moveToTrash:(id)sender
{
	
    NSInteger clickedRow = [myTableView clickedRow];
	if (clickedRow != -1){
    
    
    NSLog(@"sender: %@", sender);
	NSIndexSet *indexSet = [myTableView selectedRowIndexes];
    //NSNumber *index;
    NSMutableArray *tempArray = [NSMutableArray array];
    NSLog(@"indexSet: %@", indexSet);
    id tempObject;

 
    NSBeep();
    NSRunAlertPanel(@"Warning!", 
                    @"Are you sure you want to send these file(s) to the Trash?", 
                    @"OK", 
                    @"Cancel", nil);
    NSLog(@"Outside of loop: %@", indexSet);
    for (unsigned long i = [indexSet firstIndex]; i != NSNotFound; i = [indexSet indexGreaterThanIndex:i]) {
        // i equals the next index in the set.
        NSLog(@"index number:%lu",i);
        tempObject = [tableRecords objectAtIndex:i]; // No modification, no problem
        [tempArray addObject:tempObject]; // keep track of the record to delete in tempArray
        NSLog(@"tempObject:%@",tempObject);
        NSLog(@"tempArray:%@",tempArray);

        //Ok, actually send file to trash now.
        NSDictionary* objectDict = tempObject;
        NSLog(@"objectDict raw: %@", objectDict);
        if (objectDict != nil){
            NSLog(@"Processing objectDict: %@", objectDict);
            NSString *pathStr = [objectDict valueForKey: @"path"];
            NSArray *file = [NSArray arrayWithObject:[objectDict valueForKey: @"name"]];
            NSString *trashDir = [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
            [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
        													 source:pathStr destination:trashDir files:file tag:nil];
        }
    }
    //Finally clean out the UI, and then refresh it.
    [tableRecords removeObjectsInArray:tempArray];
    [myTableView reloadData];
    return;

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

// ----------------------------------------------------------------------

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
	NSLog(@"sender: %@", sender);
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
	
	[openPanel setResolvesAliases:YES];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseFiles:NO];
	[openPanel setPrompt:@"Choose"];
	[openPanel setMessage:@"Choose a directory to deduplicate:"];
	[openPanel setTitle:@"Choose"];
	
	[openPanel beginSheetForDirectory:nil file:nil types:nil modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(chooseDidEnd:returnCode:contextInfo:) contextInfo:nil];
    NSLog(@"sender: %@", sender);
    //[openPanel beginSheetModalForWindow:self.window completionHandler:nil];
    
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
    return timer;
}

// -------------------------------------------------------------------------------
//	setTimer:value
// -------------------------------------------------------------------------------
- (void)setTimer:(NSTimer *)value
{
    if (timer != value)
	{
        timer = value;
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
		NSLog(@"Ascending Sort: %@", tableColumn);
	}
	else
	{
		[inTableView setIndicatorImage:[NSImage imageNamed:@"NSDescendingSortIndicator"] inTableColumn:tableColumn];
		NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:[tableColumn identifier] ascending:NO];
		[self sortWithDescriptor:sortDesc];
		NSLog(@"Descending Sort: %@", tableColumn);
	}
}

@end
