//
//  LinearInterpView.m
//  OCfbbez
//
//  Created by Don Mag on 4/11/17.
//  Copyright © 2017 DonMag. All rights reserved.
//

#import "LinearInterpView.h"

@implementation LinearInterpView
{
	UIBezierPath *path; // (3)
}

- (id)initWithCoder:(NSCoder *)aDecoder // (1)
{
	if (self = [super initWithCoder:aDecoder])
	{
		[self setMultipleTouchEnabled:NO]; // (2)
//		[self setBackgroundColor:[UIColor whiteColor]];
		path = [UIBezierPath bezierPath];
		[path setLineWidth:2.0];
	}
	return self;
}

- (void)drawRect:(CGRect)rect // (5)
{
	[[UIColor blackColor] setStroke];
	[path stroke];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint p = [touch locationInView:self];
	[path moveToPoint:p];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint p = [touch locationInView:self];
	[path addLineToPoint:p]; // (4)
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}
@end

