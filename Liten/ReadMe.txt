NSOperationSample

"NSOperationSample" is a Cocoa sample application that demonstrates how to use the NSOperation and NSOperationQueue classes. 

The NSOperation class manages the execution of a single encapsulated task.  Operations are typically scheduled by adding them to an operation queue object (an instance of NSOperationQueue class), although you can execute them directly by explicitly invoking their "start" method.  Operations remain in the queue until they are cancelled or finish executing.

===========================================================================
Sample Requirements
The supplied Xcode project was created using Xcode v3.0 running under Mac OS X 10.5 or later.
The project will create a Universal Binary.

===========================================================================
About the Sample
"NSOperationSample" illustrates how to use NSOperation and NSOperationQueue classes by searching the file system for certain image files.  One NSOperation is created for recursively searching a given directory, other NSOperation instances are then created for each file found and used to examine the file.  It uses NSOperationQueue to manage these operations so users can stop the search.

===========================================================================
Using the Sample
Simply build and run the sample using Xcode.  Choose a directory to start the search of image files.  The sample will recursively search that directory for all image files.  You can stop the search by clicking "Stop".

===========================================================================
Changes from Previous Versions:

Version 1.0 - First version.
Version 1.1 - Fixed memory leak, some code reformatting.

===========================================================================
Copyright (C) 2006-2009 Apple Inc. All rights reserved.

Feedback and Bug Reports
Please send all feedback about this sample by connecting to the Contact ADC page.
Please submit any bug reports about this sample to the Bug Reporting page.


Developer Technical Support
The Apple Developer Connection Developer Technical Support (DTS) team is made up of highly qualified engineers with development expertise in key Apple technologies. Whether you need direct one-on-one support troubleshooting issues, hands-on assistance to accelerate a project, or helpful guidance to the right documentation and sample code, Apple engineers are ready to help you.  Refer to the Apple Developer Technical Support page.