//
//  DottedView.m
//  PNGSquash
//
//  Created by Michael Sanders on 6/14/09.
//  Copyright 2009 Me. All rights reserved.
//

#import "DottedView.h"
#define GRAYCOLOR colorWithDeviceRed:0.54 green:0.54 blue:0.54 alpha:1.0

@interface DottedView (PrivateMethods)
- (void)animate;
@end

@implementation DottedView

- (id)initWithFrame:(NSRect)frame
{
	[super initWithFrame:frame];

	// Initiate the shape of the arrow & box, but don't actually draw them yet.
	defaultWindowColor = [[[self window] backgroundColor] retain];

	// The rect must be inset to remove to draw the entire line.
	NSRect r = NSInsetRect([self bounds], 1, 1);
	roundPath = [[NSBezierPath bezierPathWithRoundedRect:r
												xRadius:8.0
												yRadius:8.0] retain];
	[roundPath setLineWidth:2.0];


	// Draw the end of the arrow (the point)
	arrowPoint = [[NSBezierPath bezierPath] retain];
	NSSize middle = {r.size.width / 2, r.size.height / 2};
	NSPoint p1 = NSMakePoint(r.origin.x - 13.5 + middle.width,
			                 r.origin.y - 5.5 + middle.height);
	[arrowPoint moveToPoint:p1];
	NSPoint p2 = p1;
	p2.x += 30;
	[arrowPoint lineToPoint:p2];
	p2.x -= 15.5;
	p2.y -= 15;
	[arrowPoint lineToPoint:p2];
	[arrowPoint lineToPoint:p1];

	// Line to the drop arrow
	r = NSMakeRect(middle.width - 2.5, middle.height - 5.5, 10, 20);
	arrowLine = [[NSBezierPath bezierPathWithRect:r] retain];

    return self;
}

- (void)dealloc
{
	[self setAnimateDashes:NO];
	[defaultWindowColor release];
	[roundPath release];
	[arrowPoint release];
	[arrowLine release];
	[super dealloc];
}

- (void)drawRect:(NSRect)rect
{
	static const float pattern[] = { 20.0, 10.0 };

	[roundPath setLineDash:pattern count:2 phase:phase];

	if (dimmed) [[NSColor whiteColor] set];
	else [[NSColor GRAYCOLOR] set];

	[roundPath stroke];
	[arrowPoint fill];
	[arrowLine fill];
}

// Animate dotted rectangle by moving the dots each time.
- (void)animate
{
	phase += 6;
	[self display];
}

- (void)setAnimateDashes:(BOOL)animate
{
	if (animate) {
		animateTimer = [[NSTimer scheduledTimerWithTimeInterval:0.1
														target:self
													  selector:@selector(animate)
													  userInfo:nil
													   repeats:YES] retain];
	}
	else {
		[animateTimer invalidate];
		[animateTimer release];
		animateTimer = nil;
	}
}

@synthesize dimmed;

- (void)setDimmed:(BOOL)dim
{
	dimmed = dim;

	if (dimmed) {
		[[self window] setBackgroundColor:[NSColor lightGrayColor]];
		[dropTextField setTextColor:[NSColor whiteColor]];

		notifyTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:3.0]
											   interval:0.0
												 target:self
											   selector:@selector(wakeUpUser:)
											   userInfo:nil
												repeats:NO];
		[[NSRunLoop currentRunLoop] addTimer:notifyTimer
									 forMode:NSDefaultRunLoopMode];

	} else {
		[[self window] setBackgroundColor:defaultWindowColor];
		[dropTextField setTextColor:[NSColor GRAYCOLOR]];

		[notifyTimer invalidate];
		[notifyTimer release];
		notifyTimer = nil;
		if (oldString != nil) {
			[dropTextField setStringValue:oldString];
			[oldString release];
			oldString = nil;
		}
	}

	[self setNeedsDisplay:YES];
}

- (void)wakeUpUser:(NSTimer *)timer
{
	oldString = [[dropTextField stringValue] retain];
	[dropTextField setStringValue:@"Drop it already!"];
}

@end
