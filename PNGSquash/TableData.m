//
//  TableData.m
//  PNG Squash
//
//  Created by Michael on 4/20/09.
//  Copyright 2009 Michael Sanders. All rights reserved.

#import "TableData.h"

@implementation TableData

- (void)awakeFromNib
{
	data = [[NSMutableArray alloc] init];
	[self setDataSource:self];
}

- (void)dealloc
{
	[data release];
	[super dealloc];
}

- (void)addRow:(NSDictionary *)item
{
	[data addObject:item];
	[self reloadData];
}

- (void)clearAllRows
{
	[data release];
	data = [[NSMutableArray alloc] init];
	[self reloadData];
}

#pragma mark TableView data source methods

- (id)          tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
                      row:(int)rowIndex;
{
	return [[data objectAtIndex:rowIndex] objectForKey:[tableColumn identifier]];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [data count];
}

@end
