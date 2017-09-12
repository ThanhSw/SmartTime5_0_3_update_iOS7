//
//  MonthlyTitleBackgroundView.m
//  SmartTime
//
//  Created by Left Coast Logic on 2/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MonthlyTitleBackgroundView.h"
#import "TaskManager.h"
#import "Setting.h"

extern TaskManager *taskmanager;

@implementation MonthlyTitleBackgroundView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code

		
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGFloat borders[3];
	
	size_t num_locations = 4;
	CGFloat locations[4] = { 0.0, 0.5, 0.5, 1.0 };
	
	CGFloat components[16] = { 1, 1, 1, 1.0,  // Start color
	1, 1, 1, 1.0, 1, 1, 1, 1.0, 1, 1, 1, 1.0};
	
	if(taskmanager.currentSetting.iVoStyleID==0){
		// for aesthetic reasons (the background is black), make the nav bar black for this particular page
		components[0] = (CGFloat) 197/255; 
		components[1] = (CGFloat) 206/255;
		components[2] = (CGFloat) 218/255;
		
		components[4] = (CGFloat) 131/255; 
		components[5] = (CGFloat) 150/255;
		components[6] = (CGFloat) 176/255;
		
		components[8] = (CGFloat) 128/255; 
		components[9] = (CGFloat) 148/255;
		components[10] = (CGFloat) 174/255;
		
		components[12] = (CGFloat) 114/255; 
		components[13] = (CGFloat) 136/255;
		components[14] = (CGFloat) 165/255;
		
		borders[0] = (CGFloat) 89/255;
		borders[1] = (CGFloat) 107/255;
		borders[2] = (CGFloat) 134/255;		
	}
	else
	{
		// for aesthetic reasons (the background is black), make the nav bar black for this particular page
		components[0] = (CGFloat) 98/255; 
		components[1] = (CGFloat) 98/255;
		components[2] = (CGFloat) 98/255;

		components[4] = (CGFloat) 31/255; 
		components[5] = (CGFloat) 31/255;
		components[6] = (CGFloat) 31/255;

		components[8] = (CGFloat) 16/255; 
		components[9] = (CGFloat) 16/255;
		components[10] = (CGFloat) 16/255;

		components[12] = (CGFloat) 23/255; 
		components[13] = (CGFloat) 23/255;
		components[14] = (CGFloat) 23/255;
		
		borders[0] = (CGFloat) 128/255;
		borders[1] = (CGFloat) 128/255;
		borders[2] = (CGFloat) 128/255;		
	}		
	
	CGGradientRef myGradient;
	CGColorSpaceRef myColorspace;
	
	//myColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	myColorspace = CGColorSpaceCreateWithName(CFSTR("kCGColorSpaceGenericRGB"));
	myGradient = CGGradientCreateWithColorComponents (myColorspace, components,locations, num_locations);
	
	CGPoint myStartPoint, myEndPoint;
	myStartPoint.x = rect.origin.x;
	myStartPoint.y = rect.origin.y;
	myEndPoint.x = rect.origin.x;
	myEndPoint.y = rect.origin.y + rect.size.height;
	
	CGContextDrawLinearGradient(ctx, myGradient, myStartPoint, myEndPoint, 0);
	
	UIColor *color = [UIColor colorWithRed:borders[0] green:borders[1] blue:borders[2] alpha:1];
	
	[color set];
	
	CGContextMoveToPoint(ctx, 0 , 0);
	CGContextAddLineToPoint(ctx, rect.size.width, 0);
	CGContextStrokePath(ctx);	
	
	//color = [UIColor colorWithRed:borders[1][0] green:borders[1][1] blue:borders[1][2] alpha:1];
	color = [UIColor colorWithRed:borders[0] green:borders[1] blue:borders[2] alpha:1];
	
	[color set];	

	CGContextMoveToPoint(ctx, 0 , rect.size.height);
	CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height);
	CGContextStrokePath(ctx);	
    
    CGColorSpaceRelease(myColorspace);
    CGGradientRelease(myGradient);
}


- (void)dealloc {
    [super dealloc];
}


@end
