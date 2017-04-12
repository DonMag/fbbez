//
//  SmoothedBIView.m
//  OCfbbez
//
//  Created by Don Mag on 4/11/17.
//  Copyright © 2017 DonMag. All rights reserved.
//

#import "SmoothedBIView.h"



@implementation SmoothedBIView
{
	UIBezierPath *path;
	UIImage *incrementalImage;
	CGPoint pts[5]; // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
	uint ctr;
	
	UIColor *bkgColor;
	
	NSMutableArray *aPoints;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		[self commonInit];
	}
	return self;
	
}
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit {
	// 102 204 255
	bkgColor = [UIColor colorWithRed:102.0 / 255.0 green:204.0 / 255.0 blue:1.0 alpha:1.0];
	
	[self setMultipleTouchEnabled:NO];
	path = [UIBezierPath bezierPath];
	[path setLineWidth:2.0];

	aPoints = [NSMutableArray array];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	[incrementalImage drawInRect:rect];
	[path stroke];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	ctr = 0;
	UITouch *touch = [touches anyObject];
	pts[0] = [touch locationInView:self];

	[path moveToPoint:pts[0]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint p = [touch locationInView:self];
	ctr++;
	pts[ctr] = p;
	if (ctr == 4)
	{
		pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
		
//		[path moveToPoint:pts[0]];
		[path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
		
//		NSArray *a = [[NSArray alloc] initWithObjects:
//					  [NSValue valueWithCGPoint:pts[0]],
//					  [NSValue valueWithCGPoint:pts[1]],
//					  [NSValue valueWithCGPoint:pts[2]],
//					  [NSValue valueWithCGPoint:pts[3]],
//					  [NSValue valueWithCGPoint:pts[4]],
//					  nil];

//		[aPoints addObjectsFromArray:a];
//		[aPoints addObject:a];
		
//		for (int i = 0; i < 5 ; i++) {
//			NSLog(@"%@", NSStringFromCGPoint(pts[i]));
//		}
//		NSLog(@"\n\n");
		
		
		[self setNeedsDisplay];
		// replace points and get ready to handle the next segment
		pts[0] = pts[3];
		pts[1] = pts[4];
		ctr = 1;
	}
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[path closePath];
	[self drawBitmap];
	[self setNeedsDisplay];

//	NSLog(@"\n\n%@\n\n", [path description]);
	
//	[self archiveArray:aPoints withName:@"testPoints"];
//	[self archivePath:path withName:@"testpath"];
	
	[path removeAllPoints];
	ctr = 0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

- (void)drawBitmap
{
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
	
	if (!incrementalImage) // first time; paint background white
	{
		UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
		[bkgColor setFill];
		[rectpath fill];
	}
	[incrementalImage drawAtPoint:CGPointZero];
	
	[[UIColor redColor] setFill];
	[path fill];
	
	[[UIColor blueColor] setStroke];
	[path stroke];
	
	CGFloat thick = 16.0;
	CGPathRef pathOutline = CGPathCreateCopyByStrokingPath([path CGPath], NULL, thick, kCGLineCapSquare, kCGLineJoinBevel, thick);
	UIBezierPath *oPath = [UIBezierPath bezierPathWithCGPath:pathOutline];

	[[UIColor yellowColor] setFill];
	[oPath fill];
	
	UIBezierPath *uPath = [oPath fb_union:path];
	CGAffineTransform move = CGAffineTransformMakeTranslation(0, 200);
	
	[uPath applyTransform:move];
	
	[[UIColor greenColor] setFill];
	[uPath fill];
	
	[[UIColor purpleColor] setStroke];
	[uPath stroke];

	
	incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
}

- (NSURL *)documentsDirectory
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)archiveArray:(NSMutableArray *)theArray withName:(NSString *)archiveName {
	NSString *savePath = [[[self documentsDirectory] URLByAppendingPathComponent:archiveName] path];
	
	NSString *s = [theArray description];
	
	[s writeToFile:savePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
	
//	BOOL b = [theArray writeToFile:savePath atomically:NO];
	
	NSLog(@"file %@", savePath);
	
//	savePath = [[[self documentsDirectory] URLByAppendingPathComponent:@"abc"] path];
//	NSString *t = @"This should write to a file.";
//	[t writeToFile:savePath atomically:NO];
	NSLog(@"file %@", savePath);
}

- (void)archivePath:(UIBezierPath*)bPath withName:(NSString *)archiveName
{
	NSString *savePath = [[[self documentsDirectory] URLByAppendingPathComponent:archiveName] path];
	[NSKeyedArchiver archiveRootObject:bPath toFile:savePath];
	NSLog(@"file %@", savePath);
}

- (UIBezierPath *)unarchivePathWithName:(NSString *)archiveName
{
	return (UIBezierPath *)[NSKeyedUnarchiver unarchiveObjectWithFile:[[[self documentsDirectory] URLByAppendingPathComponent:archiveName] path]];
}

@end

