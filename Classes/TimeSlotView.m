//
//  TimeSlotView.m
//  iVo
//
//  Created by Left Coast Logic on 7/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TimeSlotView.h"
#import "CalendarView.h"
#import "IvoCommon.h"
#import "Setting.h"
#import "TaskManager.h"

#define TIME_LINE_PAD 5
#define LEFT_MARGIN 3

//extern Setting *currentSetting;
extern TaskManager *taskmanager;

extern BOOL _is24HourFormat;

@implementation TimeSlotView

@synthesize time;

- (id)initWithFrame:(CGRect)frame {
	//ILOG(@"[TimeSlotView initWithFrame\n")
	
	if (self = [super initWithFrame:frame]) {
		// Initialization code
		self.backgroundColor = [UIColor clearColor];
	}
	
	//ILOG(@"TimeSlotView initWithFrame]\n")
	return self;
}
/*
- (void)drawRect:(CGRect)rect {
	//ILOG(@"[TimeSlotView drawRect\n")
	
	// Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextClearRect(ctx, rect);

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle: NSDateFormatterShortStyle];
	
	NSString *timeString = [dateFormatter stringFromDate:self.time];

	NSArray *timeArray = [timeString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@": "]];
	
	NSString *timestr = nil;
	
	NSString *hourString = [timeArray objectAtIndex:0];
	NSString *minuteString = [timeArray objectAtIndex:1];
	
	NSString *ampmString = nil;
	
	if ([timeArray count] == 3)
	{
		ampmString = [timeArray objectAtIndex:2];
	}

	if ([minuteString intValue] != 0) 
	{
		timestr = nil;
	}
	else if (ampmString == nil)
	{
		timestr = [NSString stringWithFormat:@"%@:%@", hourString, minuteString];
	}
	else if ([hourString intValue] == 12 && ([ampmString isEqualToString:@"PM"] || [ampmString isEqualToString:@"pm"]))
	{
		timestr = @"Noon";
	}
	else
	{
		timestr = hourString;
	}
	
	CGFloat fontSize = 12;
	
	CGRect bounds = self.bounds;
	
	CGSize timePaneSize = [CalendarView calculateTimePaneSize];
	
	UIFont *font = [UIFont fontWithName:@"Helvetica" size:fontSize-2];
	CGSize amsize = [@"AM" sizeWithFont:font];
	
	CGRect timePaneRec = CGRectZero;
	timePaneRec.size = timePaneSize;
	timePaneRec.origin.y = (bounds.size.height - amsize.height)/2;
	timePaneRec.origin.x = LEFT_MARGIN;
	
	CGPoint points[2];
	
	points[0].x = LEFT_MARGIN + timePaneSize.width + TIME_LINE_PAD;
	points[0].y = bounds.size.height/2;
	
	points[1].x = bounds.size.width;
	points[1].y = points[0].y;
	
	points[0].x = ceil(points[0].x);
	points[1].x = ceil(points[1].x);
	points[0].y = ceil(points[0].y);
	points[1].y = ceil(points[1].y);
	
	UIColor *lightColor;
	UIColor *darkColor;
	
	switch(currentSetting.iVoStyleID)
	{
		case BG_DEFAULT:
			darkColor = [UIColor colorWithRed:0.19 green:0.25 blue:0.31 alpha:1];
			lightColor = [UIColor blackColor];
			break;
		case BG_BLACK:
			darkColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
			lightColor = [UIColor whiteColor];
			break;
	}
	
	if (isHightLighted)
	{
		lightColor = [UIColor yellowColor];
		darkColor = [UIColor yellowColor];
	}
	
	[darkColor set];
	
	if (timestr != nil)
	{
		CGContextSetLineWidth(ctx, 0.3);
		CGContextStrokeLineSegments(ctx, points, 2);

		if (ampmString != nil && ![timestr isEqualToString:@"Noon"])
		{
			font = [UIFont fontWithName:@"Helvetica" size:fontSize-2];
				
			[ampmString drawInRect:timePaneRec withFont:font lineBreakMode:UILineBreakModeMiddleTruncation alignment:NSTextAlignmentRight];
				
			timePaneRec.size.width -= amsize.width + 4; //4 for space
		}
			
		[lightColor set];

		timePaneRec.size.width += LEFT_MARGIN;
		timePaneRec.origin.x = 0;
			
		font = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
		[timestr drawInRect:timePaneRec withFont:font lineBreakMode:UILineBreakModeMiddleTruncation alignment:NSTextAlignmentRight];
	}
	else
	{
		CGFloat lengths[] = {1, 1};
		CGContextSetLineWidth(ctx, 0.3);
		
		CGContextSetLineDash(ctx, 0, lengths, 2);
		
		CGContextStrokeLineSegments(ctx, points, 2);		
	}
	
	[dateFormatter release];
	//[gregorian release];
	//ILOG(@"TimeSlotView drawRect]\n")
}
*/

- (void)drawRect:(CGRect)rect {
	//ILOG(@"[TimeSlotView drawRect\n")
	
	// Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextClearRect(ctx, rect);
	
    if (self.time) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //[dateFormatter setTimeStyle: NSDateFormatterShortStyle];
        
        unsigned unitFlags = 0xFFFF;
        NSDateComponents *comps = [gregorian components:unitFlags fromDate:self.time];
        
        NSInteger minute = [comps minute];
        NSInteger hour = [comps hour];
        
        NSString *timestr = nil;
        
        NSString *timeStrings[24] =
        {
            @"12 AM", @"1 AM", @"2 AM", @"3 AM", @"4 AM", @"5 AM", @"6 AM", @"7 AM",
            @"8 AM", @"9 AM", @"10 AM", @"11 AM", @"Noon", @"1 PM", @"2 PM", @"3 PM",
            @"4 PM", @"5 PM", @"6 PM", @"7 PM", @"8 PM", @"9 PM", @"10 PM", @"11 PM"
        };
        
        NSString *timeStrings_24[24] =
        {
            @"0:00", @"1:00", @"2:00", @"3:00", @"4:00", @"5:00", @"6:00", @"7:00",
            @"8:00", @"9:00", @"10:00", @"11:00", @"12:00", @"13:00", @"14:00", @"15:00",
            @"16:00", @"17:00", @"18:00", @"19:00", @"20:00", @"21:00", @"22:00", @"23:00"
        };
        
        if (minute == 0)
        {
            //Trung 08102101
            //timestr = timeStrings[hour];
            if (_is24HourFormat)
            {
                timestr = timeStrings_24[hour];
            }
            else
            {
                timestr = timeStrings[hour];
            }
        }
        
        CGFloat fontSize = 12;
        
        CGRect bounds = self.bounds;
        
        CGSize timePaneSize = [CalendarView calculateTimePaneSize];
        
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:fontSize-2];
        CGSize amsize = [@"AM" sizeWithFont:font];
        
        CGRect timePaneRec = CGRectZero;
        timePaneRec.size = timePaneSize;
        timePaneRec.origin.y = (bounds.size.height - amsize.height)/2;
        timePaneRec.origin.x = LEFT_MARGIN;
        
        CGPoint points[2];
        
        points[0].x = LEFT_MARGIN + timePaneSize.width + TIME_LINE_PAD;
        points[0].y = bounds.size.height/2;
        
        points[1].x = bounds.size.width;
        points[1].y = points[0].y;
        
        points[0].x = ceil(points[0].x);
        points[1].x = ceil(points[1].x);
        points[0].y = ceil(points[0].y);
        points[1].y = ceil(points[1].y);
        
        UIColor *lightColor;
        UIColor *darkColor;
        
        switch(taskmanager.currentSetting.iVoStyleID)
        {
            case BG_DEFAULT:
                darkColor = [UIColor colorWithRed:0.19 green:0.25 blue:0.31 alpha:1];
                lightColor = [UIColor blackColor];
                break;
            case BG_BLACK:
                darkColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
                lightColor = [UIColor whiteColor];
                break;
        }
        
        if (isHightLighted)
        {
            lightColor = [UIColor yellowColor];
            darkColor = [UIColor yellowColor];
        }
        
        [darkColor set];
        
        if (timestr != nil)
        {
            CGContextSetLineWidth(ctx, 0.3);
            CGContextStrokeLineSegments(ctx, points, 2);
            
            //*Trung 08102101
            if (_is24HourFormat)
            {
                [lightColor set];
                font = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
                [timestr drawInRect:timePaneRec withFont:font lineBreakMode:UILineBreakModeMiddleTruncation alignment:NSTextAlignmentRight];
            }
            else
            {
                NSString *ampm = [timestr substringFromIndex: timestr.length - 2];
                NSString *s = [timestr substringToIndex:timestr.length - 2];
                
                if (hour != 12)
                {
                    font = [UIFont fontWithName:@"Helvetica" size:fontSize-2];
                    
                    [ampm drawInRect:timePaneRec withFont:font lineBreakMode:UILineBreakModeMiddleTruncation alignment:NSTextAlignmentRight];
                    timePaneRec.size.width -= amsize.width;
                }
                else
                {
                    s = timeStrings[hour];
                }
                
                [lightColor set];
                
                timePaneRec.size.width += LEFT_MARGIN;
                timePaneRec.origin.x = 0;
                
                font = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
                [s drawInRect:timePaneRec withFont:font lineBreakMode:UILineBreakModeMiddleTruncation alignment:NSTextAlignmentRight];
            }
            //Trung 08102101*
        }
        else
        {
            CGFloat lengths[] = {1, 1};
            CGContextSetLineWidth(ctx, 0.3);
            
            CGContextSetLineDash(ctx, 0, lengths, 2);
            
            CGContextStrokeLineSegments(ctx, points, 2);		
        }
        
        //[dateFormatter release];
        [gregorian release];
        //ILOG(@"TimeSlotView drawRect]\n")
    }
	
}

- (TimeSlotView *) hitTestRec: (CGRect) rec
{
	//ILOG(@"[TimeSlotView hitTestRec\n")
	
	CGRect frm = self.frame;
	
	frm.origin.y += (frm.size.height - 20)/2;
	frm.size.height = 20;
	
	if (CGRectIntersectsRect(frm, rec))
	{
		//ILOG(@"TimeSlotView hitTestRec] FOUND\n")
		return self;
	}

		//ILOG(@"TimeSlotView hitTestRec]\n")
	return nil;
}

- (void) hightlight
{
	//ILOG(@"[TimeSlotView hightlight\n")
	
	if (!isHightLighted)
	{
		isHightLighted = YES;
	
		[self setNeedsDisplay];
	}
	
	//ILOG(@"TimeSlotView hightlight]\n")
}

- (void) unhightlight
{
	//ILOG(@"[TimeSlotView unhightlight\n")
	
	if (isHightLighted)
	{
		isHightLighted = NO;
	
		[self setNeedsDisplay];
	}
	
	//ILOG(@"TimeSlotView unhightlight]\n")
}

- (void)dealloc {
	//ILOG(@"[TimeSlotView dealloc\n")
	
	[self.time release];

	
	[super dealloc];
	
	//ILOG(@"TimeSlotView dealloc]\n")
}

@end