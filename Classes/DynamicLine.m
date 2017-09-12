//
//  DynamicLine.m
//  IVo
//
//  Created by Left Coast Logic on 5/7/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DynamicLine.h"
#import "IvoCommon.h"
#import "Setting.h"
#import "DayLineTextView.h"
#import "ivo_Utilities.h"

#define DAYLINE_TEXT_YOFFSET -18

//extern Setting			*currentSetting;
extern ivo_Utilities    *ivoUtility;

@implementation DynamicLine

//Trung 08101301
/*
- (id)init:(BOOL) isTodayDayLine
{
	if (self = [super init])
	{
		self.todayDayLine = isTodayDayLine;
	}
	
	return self;
}
*/
- (id)initWithFrame:(CGRect)frame
{
	self.type = TYPE_SMART_DYNAMICLINE;

    if (self = [super initWithFrame:frame]) {
        // Initialization code here.
		NSString *dayLine = @"DayLine.png";

		UIImage *image = [UIImage imageNamed:dayLine];
		//UIImageView *dayLineView = [[UIImageView alloc] initWithImage:image];
		dayLineView = [[UIImageView alloc] initWithImage:image];
		[self addSubview:dayLineView];
		[dayLineView release];

		textView = [[DayLineTextView alloc] initWithFrame:frame];
		//textView.text = @"Hello World";
				
		[self addSubview:textView];
		[textView release];

    }
    return self;
}

- (void) setTodayDayLine:(BOOL)isTodayDayLine
{
	todayDayLine = isTodayDayLine;
	
	NSDate *today = [NSDate date];
	
	if (!todayDayLine) //tomorrow day line
	{
		today = [today dateByAddingTimeInterval:24*60*60]; 
	}
	
	NSString *formattedDateString = [ivoUtility createStringFromDate:today isIncludedTime:NO];
	textView.text = [NSString stringWithFormat:@"%@", formattedDateString];
	
	[formattedDateString release];	
}

- (void)layoutSubviews 
{
	CGRect frm = self.bounds;
	
	dayLineView.frame = frm;
	
	frm.size.height -= DAYLINE_TEXT_YOFFSET;
	frm.origin.y += DAYLINE_TEXT_YOFFSET;
	
	textView.frame = frm;
    [dayLineView setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
/*
#define DYNAMIC_LINE_PADDING 8
#define CIRCLE_SIZE 6
#define DYNAMIC_LINE_BETWEEN 2*DYNAMIC_LINE_PADDING
#define DYNAMIC_LINE_HEIGHT 3
  
	// Drawing code here.
	CGPoint points[2];
	points[0] = rect.origin;
	points[1] = rect.origin;
	
	points[0].y += DYNAMIC_LINE_PADDING;
	points[1].y += DYNAMIC_LINE_PADDING;	
	
	points[0].x += CIRCLE_SIZE;
	points[1].x = self.frame.size.width - CIRCLE_SIZE;

	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	UIColor *color = [UIColor whiteColor];
	
	switch(currentSetting.iVoStyleID)
	{
		case BG_DEFAULT:
			color = [[UIColor purpleColor] colorWithAlphaComponent:0.8];
			break;
		case BG_BLACK:
			color = [UIColor yellowColor];
			break;
	}
	
	[color set];
	[color setFill];
	
	CGContextSetLineWidth(ctx, DYNAMIC_LINE_HEIGHT);
	CGContextStrokeLineSegments(ctx, points, 2);

	CGRect rec = CGRectMake(0,points[0].y - CIRCLE_SIZE/2,CIRCLE_SIZE,CIRCLE_SIZE);
	CGContextFillEllipseInRect(ctx, rec);

	rec.origin.x += self.frame.size.width - CIRCLE_SIZE;
	CGContextFillEllipseInRect(ctx, rec);
*/
}


- (void)dealloc
{
	[super dealloc];
}

@end
