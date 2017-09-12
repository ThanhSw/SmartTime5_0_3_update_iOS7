//
//  MonthlyCellView.m
//  SmartTime
//
//  Created by Left Coast Logic on 12/31/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MonthlyCellView.h"
#import "TaskManager.h"
#import "Setting.h"

extern TaskManager *taskmanager;
extern BOOL _startDayAsMonday;

@implementation MonthlyCellView

@synthesize day;
@synthesize month;
@synthesize year;

@synthesize index;
@synthesize selected;
@synthesize gray;
@synthesize isWeekend;
@synthesize isToday;
@synthesize freeRatio;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		
		dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 20, 20)];
		dayLabel.font = [UIFont systemFontOfSize:14];
		dayLabel.backgroundColor = [UIColor clearColor];
		
		[self addSubview:dayLabel];
		
		self.selected = NO;
		self.isWeekend = NO;
		gray = NO;
		isToday = NO;
		
		freeRatio = 0;
    }
    return self;
}

-(void)setFreeRatio:(CGFloat)ratio
{
	freeRatio = ratio;
	
	if (selected)
	{
		self.backgroundColor = [UIColor colorWithRed:0.37 green:0.57 blue:0.9 alpha:1];
		return;
	}
	
	UIColor *color = [UIColor blackColor];
	
	if(taskmanager.currentSetting.iVoStyleID==0)
	{
		if (freeRatio == 0)
		{
			//color = [UIColor colorWithRed:0.65 green:0.63 blue:0.68 alpha:1];
			color = [UIColor colorWithRed:(CGFloat)196/255 green:(CGFloat)191/255 blue:(CGFloat)204/255 alpha:1];
		}
		else if (freeRatio <= 0.25)
		{
			//color = [UIColor colorWithRed:0.68 green:0.66 blue:0.71 alpha:1];
			color = [UIColor colorWithRed:(CGFloat)176/255 green:(CGFloat)171/255 blue:(CGFloat)184/255 alpha:1];
		}
		else if (freeRatio <= 0.5)
		{
			//color = [UIColor colorWithRed:0.71 green:0.69 blue:0.74 alpha:1];	
			color = [UIColor colorWithRed:(CGFloat)156/255 green:(CGFloat)151/255 blue:(CGFloat)164/255 alpha:1];
		}
		else if (freeRatio <= 0.75)
		{
			//color = [UIColor colorWithRed:0.74 green:0.72 blue:0.77 alpha:1];
			color = [UIColor colorWithRed:(CGFloat)136/255 green:(CGFloat)131/255 blue:(CGFloat)144/255 alpha:1];
		}
		else
		{
			//color = [UIColor colorWithRed:0.77 green:0.75 blue:0.8 alpha:1];
			color = [UIColor colorWithRed:(CGFloat)116/255 green:(CGFloat)111/255 blue:(CGFloat)124/255 alpha:1];
		}		
	}
	else
	{
		if (freeRatio == 0)
		{
			//color = [UIColor colorWithRed:(CGFloat)20/255 green:(CGFloat)20/255 blue:(CGFloat)20/255 alpha:1];
			color = [UIColor colorWithRed:(CGFloat)100/255 green:(CGFloat)100/255 blue:(CGFloat)100/255 alpha:1];				
		}
		else if (freeRatio <= 0.25)
		{
			//color = [UIColor colorWithRed:(CGFloat)40/255 green:(CGFloat)40/255 blue:(CGFloat)40/255 alpha:1];
			color = [UIColor colorWithRed:(CGFloat)80/255 green:(CGFloat)80/255 blue:(CGFloat)80/255 alpha:1];
		}
		else if (freeRatio <= 0.5)
		{
			color = [UIColor colorWithRed:(CGFloat)60/255 green:(CGFloat)60/255 blue:(CGFloat)60/255 alpha:1];				
		}
		else if (freeRatio <= 0.75)
		{
			//color = [UIColor colorWithRed:(CGFloat)80/255 green:(CGFloat)80/255 blue:(CGFloat)80/255 alpha:1];
			color = [UIColor colorWithRed:(CGFloat)40/255 green:(CGFloat)40/255 blue:(CGFloat)40/255 alpha:1];
		}
		else
		{
			//color = [UIColor colorWithRed:(CGFloat)100/255 green:(CGFloat)100/255 blue:(CGFloat)100/255 alpha:1];	
			color = [UIColor colorWithRed:(CGFloat)20/255 green:(CGFloat)20/255 blue:(CGFloat)20/255 alpha:1];
		}
	}
	
	self.backgroundColor = color;
	
}

/*
-(void)setIsWeekend:(BOOL)weekend
{
	isWeekend = weekend;
	
	if(taskmanager.currentSetting.iVoStyleID==0)
	{
		// for aesthetic reasons (the background is black), make the nav bar black for this particular page
		self.backgroundColor = isToday?
								//[UIColor colorWithRed:(CGFloat)114/255 green:(CGFloat)136/255 blue:(CGFloat)165/255 alpha:1]:		
								[UIColor colorWithRed:(CGFloat)90/255 green:(CGFloat)111/255 blue:(CGFloat)140/255 alpha:1]:		
								(isWeekend?
								[UIColor colorWithRed:0.72 green:0.70 blue:0.75 alpha:1]:
								[UIColor colorWithRed:0.77 green:0.75 blue:0.8 alpha:1]);
		//dayLabel.textColor = [UIColor blackColor];
	}
	else
	{
		// for aesthetic reasons (the background is black), make the nav bar black for this particular page
		self.backgroundColor = isToday?
								[UIColor colorWithRed:(CGFloat)90/255 green:(CGFloat)111/255 blue:(CGFloat)140/255 alpha:1]:
								(isWeekend?
								[UIColor colorWithRed:(CGFloat)60/255 green:(CGFloat)60/255 blue:(CGFloat)60/255 alpha:1]:
								[UIColor colorWithRed:(CGFloat)40/255 green:(CGFloat)40/255 blue:(CGFloat)40/255 alpha:1]);
		
		//dayLabel.textColor = [UIColor whiteColor];
								
	}		

}
*/

-(void)setIsToday:(BOOL) isTodayVal
{
	isToday = isTodayVal;
	
	[self setNeedsDisplay];
	
	//[self setIsWeekend:isWeekend];
	//[self setFreeRatio:freeRatio]; //change the color
}

-(void)setGray:(BOOL) isGray
{
	gray = isGray;
	
	if (isGray)
	{
		//dayLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
		
		if(taskmanager.currentSetting.iVoStyleID==0)
		{
			dayLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
		}
		else
		{
			dayLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
		}			
	}
	else
	{
		if(taskmanager.currentSetting.iVoStyleID==0)
		{
			dayLabel.textColor = [UIColor blackColor];
		}
		else
		{
			dayLabel.textColor = [UIColor whiteColor];				
		}			
	}
	
}

-(void)setSelected:(BOOL) isSelected
{
	if (selected != isSelected)
	{
		selected = isSelected;

		if (selected)
		{
			self.backgroundColor = [UIColor colorWithRed:0.37 green:0.57 blue:0.9 alpha:1];
		}
		else
		{
			//[self setIsWeekend:isWeekend];
			[self setFreeRatio:freeRatio];
		}
	}
}

-(void)setDay:(NSInteger) dayValue
{
	day = dayValue;
	
    dayLabel.text = dayValue>0?[NSString stringWithFormat:@"%ld", (long)dayValue]:@"";
}

- (BOOL)checkToday
{
	NSDate *date = [NSDate date];
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;			
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
	
	[gregorian release];
	
	if (day == comps.day && month == comps.month && year == comps.year)
	{
		return YES;
	}
	
	return NO;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();

	UIColor *darkColor = [UIColor grayColor];
	UIColor *lightColor = [UIColor whiteColor];
	
	if(taskmanager.currentSetting.iVoStyleID==0)
	{
		darkColor = [UIColor grayColor];
		lightColor = [UIColor whiteColor];
	}
	else
	{
		//darkColor = [UIColor blackColor];
		darkColor = [UIColor darkGrayColor];
		//lightColor = [UIColor grayColor];
		lightColor = [UIColor lightGrayColor];
	}			
	
	[darkColor set];
	
	CGContextSetLineWidth(ctx, 1);	
	CGContextStrokeRect(ctx, self.bounds);	
	
	[lightColor set];
	
	CGContextSetLineWidth(ctx, 0.5);
	
	CGContextMoveToPoint(ctx,  self.bounds.origin.x,  self.bounds.origin.y + 0.5);
	CGContextAddLineToPoint( ctx,  self.bounds.origin.x + self.bounds.size.width, self.bounds.origin.y + 0.5);
	CGContextStrokePath(ctx);
	
	CGContextMoveToPoint(ctx, self.bounds.origin.x + self.bounds.size.width - 0.5, self.bounds.origin.y);	
	CGContextAddLineToPoint( ctx, self.bounds.origin.x + self.bounds.size.width - 0.5, self.bounds.origin.y + self.bounds.size.height);
	CGContextStrokePath(ctx);
	
	if (self.isToday)
	{
		CGContextSetLineWidth(ctx, 2);
		
		[[UIColor colorWithRed:(CGFloat)90/255 green:(CGFloat)111/255 blue:(CGFloat)140/255 alpha:1] set];
		
		CGContextStrokeRect(ctx, CGRectMake(self.bounds.origin.x + 1, self.bounds.origin.y + 1, self.bounds.size.width - 2, self.bounds.size.height - 2));
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	MonthlyCalendarView *parent = (MonthlyCalendarView *)[self superview];
	[parent selectCell:self.index];
}

- (void)dealloc {
	[dayLabel release];
	
    [super dealloc];
}


@end
