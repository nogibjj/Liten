Compiling a build:

You will need to target the 10.7 SDK because Liten depends on a deprecated API calls.  

Background:

The original project was started by building off of some sample code.  The core algorithm of finding duplicates was built from this Python code:  http://code.google.com/p/liten/

Essentially, an md5 checksum is only performed after the size of the file matches a key in a hash.  This makes for a pretty efficient tree walk.

TO DO:

1.  Updating the deprecated API calls to 10.8
2.  Fixing various UI bugs
3.  Getting a better sort in the UI for human readable duplicates.
4.  Would love to do a folder merge.
5.  Better bulk delete



