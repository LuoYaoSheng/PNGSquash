//
//  PNGOutFormatter.h
//  PNGSquash
//
//  Created by Michael on 6/27/09.
//  Copyright 2009 Michael Sanders. All rights reserved.


//  Formatter for pngout's location text field.
//  Ensures only executables are entered.

#import <Foundation/Foundation.h>

@interface ExecFormatter : NSFormatter
{
	NSString *oldValue;
}

@end
