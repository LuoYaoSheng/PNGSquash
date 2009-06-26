//
//  ByteFormatter.m
//  PNG Squash
//
//  Created by Michael on 4/21/09.
//  Copyright 2009 Michael Sanders. All rights reserved.

#import "ByteFormatter.h"

@implementation ByteFormatter

- (NSString *)stringForObjectValue:(NSNumber *)aNumber
{
	int number = [aNumber intValue];
	double rounded;
	NSString *type;

	if (number < 1024) { // Bytes
		rounded = number;
		type = number == 1 ? @"byte" : @"bytes";
	} else if (number < 1048576) { // Kilobytes
		rounded = (double) number / 1024.0;
		type = @"KB";
	} else { // Megabytes
		rounded = (double) number / 1048576.0;
		type = @"MB";
	}

	return [NSString stringWithFormat:@"%.3f %@", rounded, type];
}

@end
