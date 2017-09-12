//
//  SmartStartView.m
//  iVo
//
//  Created by Nang Le on 8/15/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SmartStartView.h"
#import "IvoCommon.h"

@implementation SmartStartView


- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		// Initialization code
		self.alpha=0.6;
	}
	return self;
}


- (void)drawRect:(CGRect)rect {
	//ILOG(@"[SmartStartView drawRect\n");
	// Drawing code
	CGContextRef myContext = UIGraphicsGetCurrentContext();
	
	CGGradientRef myGradient;
	CGColorSpaceRef myColorspace;
	size_t num_locations = 3;
	
	CGFloat locations[3] = { 0.0,0.07,1.0 };
	CGFloat components[12] = { 1, 1, 1, 0.0, // Start color
		0, 0, 0, 1.0, 
	0.1, 0.1, 0.1, 0.0 };
	
	//myColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	myColorspace = CGColorSpaceCreateWithName(CFSTR("kCGColorSpaceGenericRGB"));
	
	myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
													  locations, num_locations);
	
	CGPoint myStartPoint, myEndPoint;
	myStartPoint.x = self.bounds.origin.x;
	myStartPoint.y =self.bounds.origin.y;
	myEndPoint.x =self.bounds.origin.y;
	myEndPoint.y = self.bounds.size.width;
	
	CGContextDrawLinearGradient (myContext, myGradient, myStartPoint, myEndPoint, 0);	
	
	CGGradientRelease(myGradient);
	//ILOG(@"SmartStartView drawRect]\n");
}


- (void)dealloc {
	[super dealloc];
}


@end
