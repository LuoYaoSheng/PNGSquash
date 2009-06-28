//
//  ImageCompressor.m
//  PNGSquash
//
//  Created by Michael Sanders on 6/15/09.
//  Copyright 2009 Michael Sanders. All rights reserved.

#import "ImageCompressor.h"

@interface ImageCompressor (PrivateMethods)

- (NSString *)moveFileToTrash:(NSString *)file error:(NSError **)error;
- (void)runTask:(NSString *)taskname withArgs:(NSArray *)args;
- (void)runTask:(NSString *)taskname
	   withArgs:(NSArray *)args
		 absolutePath:(NSString *)path;
- (void)ranTask:(NSNotification *)note;
- (void)compressNextFile;

@end

@implementation ImageCompressor

- (void)dealloc
{
	[infile release];
	[outfiles release];
	[delegate release];
	[compressDelegate release];
	[super dealloc];
}

@synthesize delegate;
@synthesize pngoutPath;

- (void)compressFiles:(NSArray *)files
              atLevel:(unsigned int)compressLevel
       didEndSelector:(SEL)selector
			   object:(id)object
{
	// Copy filenames
	NSArray *copy = [files copy];
	[outfiles release];
	outfiles = copy;

	[compressDelegate release];
	[object retain];
	compressDelegate = object;

	// Set up options
	level = compressLevel;
	compressorCount = level > 4 ? 3 : 2;
	if (pngoutPath != nil && level >= 6) {
		compressorCount++;
	}

	didEndSelector = selector;
	outfilesCount = [outfiles count];
	imageIndex = progIndex = 0;
	[self compressNextFile];
}

@synthesize compressorCount;

// Called after each task is complete
- (void)compressNextFile
{
	if (progIndex >= compressorCount) {
		if (delegate && [delegate respondsToSelector:
							@selector(compressedFile:toFile:)]) {
			[delegate compressedFile:infile toFile:outfile];
		}
		progIndex = 0;
		imageIndex++;

		if (imageIndex >= outfilesCount) {
			[compressDelegate performSelector:didEndSelector withObject:nil];
			return;
		}
	}

	NSString *levelStr;

	// Cycle through compressors
	if (progIndex == 0) {
		DLog(@"Optimizing at level %i", level);
		[infile release];

		NSError *error = nil;
		outfile = [outfiles objectAtIndex:imageIndex];
		infile = [[self moveFileToTrash:outfile error:&error] retain];
		if (error != nil) {
			[compressDelegate performSelector:didEndSelector withObject:error];
			return; // Cancel if file couldn't be moved to trash.
		}

		// Compress and remove gama via pngcrush.
		levelStr = [NSString stringWithFormat:@"-l%d", level];
		[self runTask:@"pngcrush" withArgs:[NSArray arrayWithObjects:
		    @"-q", @"-rem", @"cHRM", @"-rem", @"gAMA", @"-rem", @"iCCP",
		    @"-rem", @"sRGB", levelStr, (level > 5 ? @"-brute" : @"-"),
		    infile, outfile, nil]];
	} else if (progIndex == 1) {
		levelStr = [NSString stringWithFormat:@"-o%d", level];
		// Compress further via optipng
		[self runTask:@"optipng" withArgs:[NSArray arrayWithObjects:
		                                   @"-q", levelStr, outfile, nil]];
	} else if (progIndex == 2) {
		// Compress further via advpng on level 1 – 4.
		// (level can normally range from 1 – 7)
		levelStr = [NSString stringWithFormat:@"-z%d", (level < 5 ? 1 : level - 3)];
		[self runTask:@"advpng" withArgs:[NSArray arrayWithObjects: @"-q",
		                                  levelStr, outfile, nil]];
	} else if (progIndex == 3) {
		[self runTask:[pngoutPath lastPathComponent]
			 withArgs:[NSArray arrayWithObjects: @"-q", outfile, nil]
		  absolutePath:pngoutPath];
	}

	progIndex++;
}

// Returns the path of outfile moved to the trash, or nil if it fails.
- (NSString *)moveFileToTrash:(NSString *)file error:(NSError **)error
{
	NSString *newPath;
	NSFileManager *manager = [NSFileManager defaultManager];

	newPath = [NSString stringWithFormat:@"%@/%@.old",
	                    [@"~/.Trash" stringByExpandingTildeInPath],
	                    [file lastPathComponent]];

	// If file has been previously moved to trash, delete the previously
	// moved image.
	if ([manager fileExistsAtPath:newPath]) {
		[manager removeFileAtPath:newPath handler:nil];
	}

	if ([manager movePath:file toPath:newPath handler:nil]) {
		return newPath;
	}

	if (error != NULL) {
		NSString *errorString = [NSString stringWithFormat:
			@"Could not move file “%@” to trash.", file];
		NSDictionary *info = [NSDictionary dictionaryWithObject:errorString
														 forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:NSPOSIXErrorDomain
									 code:1
								 userInfo:info];
	}
	return nil;
}

// Moves current image from the trash back to its original location.
// Returns nil on success, error on failure.
- (NSError *)undoMoveToTrash
{
	NSFileManager *manager = [NSFileManager defaultManager];
	if ([manager fileExistsAtPath:outfile]) {
		[manager removeFileAtPath:outfile handler:nil];
	}

	if ([manager movePath:infile toPath:outfile handler:nil]) {
		return nil;
	}

	NSString *errorString = [NSString stringWithFormat:
				 @"Could not move “%@” to “%@”.", infile, outfile];
	NSDictionary *info = [NSDictionary dictionaryWithObject:errorString
													 forKey:NSLocalizedDescriptionKey];
	return [NSError errorWithDomain:NSPOSIXErrorDomain
							   code:1
						   userInfo:info];
}

- (void)runTask:(NSString *)taskname withArgs:(NSArray *)args
{
	NSString *path = [[NSBundle mainBundle] pathForResource:taskname
													 ofType:nil];
	[self runTask:taskname withArgs:args absolutePath:path];
}

- (void)runTask:(NSString *)taskname
	   withArgs:(NSArray *)args
	absolutePath:(NSString *)path
{
	if (delegate && [delegate respondsToSelector:@selector(runCompressor:forFile:)]
	    && ![delegate runCompressor:taskname forFile:(imageIndex + 1)]) {
		return;
	}

	currentTask = [[NSTask alloc] init];
	[currentTask setLaunchPath:path];
	[currentTask setArguments:args];

	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	[nc addObserver:self
	       selector:@selector(ranTask:)
	           name:NSTaskDidTerminateNotification
	         object:currentTask];

	[currentTask launch];
}

// Clean up task when it is complete, and run the next one if it
// terminated normally.
- (void)ranTask:(NSNotification *)note
{
	int status = [currentTask terminationStatus];

	[currentTask release];
	currentTask = nil;
	if (status == 0) {
		[self compressNextFile];
	} else {
		DLog(@"Task cancelled.");
	}
}

- (NSError *)cancelCompressing
{
	DLog(@"Cancelling compression.");

	[currentTask terminate];
	[currentTask waitUntilExit];

	NSError *error = [self undoMoveToTrash];
	return error;
}

@end
