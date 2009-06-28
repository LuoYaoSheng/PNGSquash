//
//  PNGOutFormatter.m
//  PNGSquash
//
//  Created by Michael on 6/27/09.
//  Copyright 2009 Michael Sanders. All rights reserved.

#import "ExecFormatter.h"

@implementation ExecFormatter

- (void)dealloc
{
	[oldValue release];
	[super dealloc];
}

- (NSString *)stringForObjectValue:(id)obj
{
	return obj == nil ? nil : [NSString stringWithString:obj];
}

- (BOOL)getObjectValue:(id *)obj
			 forString:(NSString *)string
	  errorDescription:(NSString **)errorString
{
	NSFileManager *manager = [NSFileManager defaultManager];

	// Only accept path if it's executable
	NSString *path = [string stringByExpandingTildeInPath];
	if (![path isEqualToString:@""] && [manager isExecutableFileAtPath:path]) {
		*obj = path;

		// Save old value
		[path retain];
		[oldValue release];
		oldValue = path;
	} else {
		*obj = oldValue;
	}

	return YES;
}

@end
