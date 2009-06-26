//
//  DragView.h
//  PNGSquash
//
//  Created by Michael Sanders on 6/14/09.
//  Copyright 2009 Michael Sanders. All rights reserved.

#import <Cocoa/Cocoa.h>
@class DottedView;

@interface DragView : NSView
{
	IBOutlet DottedView *dottedView;
	id delegate;
}

@property (nonatomic, retain) id delegate;

@end
