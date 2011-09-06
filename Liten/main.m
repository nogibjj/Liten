#import <Cocoa/Cocoa.h>
#include <objc/objc-auto.h>

int main(int argc, char *argv[])
{
	
    objc_startCollectorThread();
	return NSApplicationMain(argc, (const char **) argv);
}
