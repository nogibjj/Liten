#import <Cocoa/Cocoa.h>


@interface MyWindowController : NSWindowController
{

	IBOutlet NSTableView			*myTableView;		// the table holding the duplicate paths
	NSMutableArray					*tableRecords;		// the data source for the table
	IBOutlet NSComboBox				*fileSizeLimit;		// Size to limit in the search:  i.e. KB, MB, GB
	NSString						*fs;				// NSTableView Query
	//IBOutlet NSSearchField			*searchQuery;		// Search query to query NSTableView
	IBOutlet NSProgressIndicator	*myProgressInd;
	IBOutlet NSButton				*myStartButton;
	IBOutlet NSButton				*myStopButton;
    IBOutlet NSMenu					*duplicatesContextMenu; //Wires Up Right Click Context Menu
	NSOperationQueue				*queue;				// the queue of NSOperations (1 for parsing file system, 2+ for loading duplicate files)
	NSTimer							*timer;				// update timer for progress indicator
	
	NSMutableString					*duplicatesFoundStr;	// indicates the number of duplicates found, (NSTextField is bound to this value)
}

- (IBAction)startAction:(id)sender;
- (IBAction)stopAction:(id)sender;
- (IBAction)moveToTrash:(id)sender;
- (IBAction)revealInFinder:(id)sender;
- (IBAction)searchInSpotlight:(id)sender;
- (IBAction)quickLookPreview:(id)sender;
- (IBAction)setFileSizeLimit:(id)sender;
- (void)quickLookShell:(NSString *)fullPath;
- (IBAction)tableViewSelected:(id)sender;
- (NSIndexSet *)selectedNodes;
//- (IBAction)setSearchQuery:(id)sender;

@end

