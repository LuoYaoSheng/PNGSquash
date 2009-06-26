//
//  TableData.h
//  PNG Squash
//
//  Created by Michael on 4/20/09.
//  Copyright 2009 Michael Sanders. All rights reserved.

#import <Cocoa/Cocoa.h>

//  This is essentially just a TableView with its dataSource set to itself.
//  It makes it a bit more convenient to add rows one-by-one.
@interface TableData : NSTableView
{
	NSMutableArray *data;
}

- (void)addRow:(NSDictionary *)item;
- (void)clearAllRows;

@end

