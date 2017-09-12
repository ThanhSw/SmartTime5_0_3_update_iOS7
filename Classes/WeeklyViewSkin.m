//
//  WeeklyViewSkin.m
//  SmartTime
//
//  Created by Left Coast Logic on 3/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WeeklyViewSkin.h"
#import "IvoCommon.h"
#import "TaskManager.h"
#import "Setting.h"

extern TaskManager *taskmanager;

@implementation WeeklyViewSkin


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.userInteractionEnabled = NO;
		self.backgroundColor = [UIColor clearColor];
        cellWidth=frame.size.width/7;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	UIColor *darkColor = [UIColor darkGrayColor];
	UIColor *lightColor = [UIColor whiteColor];
	UIColor *brightColor = [UIColor whiteColor];
	UIColor *dimColor = [UIColor grayColor];
	
	if(taskmanager.currentSetting.iVoStyleID==0)
	{
		darkColor = [UIColor grayColor];
		lightColor = [UIColor whiteColor];
		//dimColor = [UIColor colorWithRed:(CGFloat) 89/255 green:(CGFloat) 107/255 blue:(CGFloat) 134/255 alpha:1];
		//brightColor = [UIColor grayColor];
		brightColor = [UIColor whiteColor];
		dimColor = [UIColor colorWithRed:(CGFloat) 60/255 green:(CGFloat) 60/255 blue:(CGFloat) 60/255 alpha:1];
	}
	else
	{
		//darkColor = [UIColor grayColor];
		//lightColor = [UIColor whiteColor];
		darkColor = [UIColor blackColor];
		lightColor = [UIColor grayColor];
		brightColor = [UIColor whiteColor];
		dimColor = [UIColor grayColor];
	}

//	[dimColor setFill];
//	CGContextFillRect(ctx, CGRectMake(0, WEEKVIEW_ADE_HEIGHT - 1, rect.size.width, 0.75));	
	
//	[brightColor setFill];
//	CGContextFillRect(ctx, CGRectMake(0, WEEKVIEW_ADE_HEIGHT - 0.75, rect.size.width, 0.75));

	
	[dimColor set];

	CGContextSetLineWidth(ctx, 2);

	CGContextMoveToPoint(ctx,  0, 0);
	CGContextAddLineToPoint( ctx, rect.size.width, 0);
	CGContextStrokePath(ctx);	
/*
	CGContextMoveToPoint(ctx,  0, WEEKVIEW_ADE_HEIGHT - 2);
	CGContextAddLineToPoint( ctx, rect.size.width, WEEKVIEW_ADE_HEIGHT - 2);
	CGContextStrokePath(ctx);
*/	
	[brightColor set];
	CGContextSetLineWidth(ctx, 0.5);
	
	CGContextMoveToPoint(ctx,  0, -0.25);
	CGContextAddLineToPoint( ctx, rect.size.width, -0.25);
	CGContextStrokePath(ctx);	

	CGContextMoveToPoint(ctx,  0, WEEKVIEW_ADE_HEIGHT - 0.5);
	CGContextAddLineToPoint( ctx, rect.size.width, WEEKVIEW_ADE_HEIGHT - 0.5);
	CGContextStrokePath(ctx);
/*	
	[brightColor set];
	CGContextSetLineWidth(ctx, 0.25);

	CGContextMoveToPoint(ctx,  0, - 0.25);
	CGContextAddLineToPoint( ctx, rect.size.width, - 0.25);
	CGContextStrokePath(ctx);	

	CGContextMoveToPoint(ctx,  0, WEEKVIEW_ADE_HEIGHT - 2 + 0.75);
	CGContextAddLineToPoint( ctx, rect.size.width, WEEKVIEW_ADE_HEIGHT - 2 + 0.75);
	CGContextStrokePath(ctx);
*/
	CGFloat offsetX = 2;
	
	CGFloat weekendAdjustX = 0.5; // set 0.75 when using reversed color weekend-day 
	
	//draw Sunday border
	[darkColor set];
	CGContextSetLineWidth(ctx, 1);
	
	CGContextMoveToPoint(ctx, cellWidth + offsetX, WEEKVIEW_ADE_HEIGHT);
	CGContextAddLineToPoint( ctx, cellWidth + offsetX, rect.size.height);
	CGContextStrokePath(ctx);		
	
	[lightColor set];
	CGContextSetLineWidth(ctx, 0.5);
	
	CGContextMoveToPoint(ctx, cellWidth + offsetX + weekendAdjustX, WEEKVIEW_ADE_HEIGHT);
	CGContextAddLineToPoint( ctx, cellWidth + offsetX + weekendAdjustX, rect.size.height);
	CGContextStrokePath(ctx);		

	//draw Mon-Fri borders 
	for (int i=2; i<6; i++)
	{
		//CGFloat offsetX = (i==1?2:0);
		
		NSInteger mod = i%2;
		
		CGFloat dy = (mod == 0?-weekendAdjustX:weekendAdjustX);
		
		[darkColor set];
		CGContextSetLineWidth(ctx, 1);
		
		CGContextMoveToPoint(ctx, i*cellWidth + offsetX, WEEKVIEW_ADE_HEIGHT);
		CGContextAddLineToPoint( ctx, i*cellWidth + offsetX, rect.size.height);
		CGContextStrokePath(ctx);		

		[lightColor set];
		CGContextSetLineWidth(ctx, 0.5);
		
		//CGContextMoveToPoint(ctx, i*cellWidth + offsetX - 0.75, WEEKVIEW_ADE_HEIGHT);
		CGContextMoveToPoint(ctx, i*cellWidth + offsetX + dy, WEEKVIEW_ADE_HEIGHT);
		//CGContextAddLineToPoint( ctx, i*cellWidth + offsetX - 0.75, rect.size.height);
		CGContextAddLineToPoint( ctx, i*cellWidth + offsetX + dy, rect.size.height);
		CGContextStrokePath(ctx);		
	}
	//draw Sat border
	[darkColor set];
	CGContextSetLineWidth(ctx, 1);
	
	CGContextMoveToPoint(ctx, 6*cellWidth + offsetX, WEEKVIEW_ADE_HEIGHT);
	CGContextAddLineToPoint( ctx, 6*cellWidth + offsetX, rect.size.height);
	CGContextStrokePath(ctx);		
	
	[lightColor set];
	CGContextSetLineWidth(ctx, 0.5);
	
	CGContextMoveToPoint(ctx, 6*cellWidth + offsetX - weekendAdjustX, WEEKVIEW_ADE_HEIGHT);
	CGContextAddLineToPoint( ctx, 6*cellWidth + offsetX - weekendAdjustX, rect.size.height);
	CGContextStrokePath(ctx);	

}


- (void)dealloc {
    [super dealloc];
}


@end
