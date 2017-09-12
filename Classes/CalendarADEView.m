//
//  CalendarADEView.m
//  SmartTime
//
//  Created by Left Coast Logic on 1/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CalendarADEView.h"
#import "CalendarADE.h"
#import "ivo_Utilities.h"
#import "TaskManager.h"
#import "IvoCommon.h"
#import "Setting.h"
#import "CalendarView.h"
#import "SmartViewController.h"

extern ivo_Utilities	*ivoUtility;
extern TaskManager *taskmanager;
extern CalendarView *_calendarView;
extern SmartViewController *_smartViewController;
extern CGFloat _shadowColor[];

extern NSMutableArray *projectList;

#define MAX_ADE 5
#define ADE_SQUARE_SIZE 12
#define ADE_HEIGHT 25
//#define ADE_WIDTH 120

@implementation CalendarADEView

@synthesize adeList;
@synthesize selected;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		
		self.backgroundColor = [UIColor clearColor];
		
		currentIndex = 0;
		startIndex = 0;
		
		lastTouchTime = nil;
		scrollToRight = NO;
		
		selected = NO;
/*		
		CalendarADE *ade1 = [[CalendarADE alloc] init];
		ade1.key = 1;
		ade1.project = 0;
		ade1.name = @"ADE1";

		CalendarADE *ade2 = [[CalendarADE alloc] init];
		ade2.key = 2;
		ade2.project = 1;
		ade2.name = @"ADE2";
		
		adeList = [[NSMutableArray alloc] initWithCapacity:2];
		[adeList addObject:ade1];
		[ade1 release];
		
		[adeList addObject:ade2];
		[ade2 release];
*/
    }
    return self;
}

-(void)resetIndex
{
	printf("resetIndex\n");
	
	self.selected = NO;
	
	currentIndex = 0;
	startIndex = 0;
	
	scrollToRight = NO;
}

- (void) changeBackgroundStyle
{
	[self setNeedsDisplay];
}

-(void)scroll:(BOOL)toRight
{
	self.selected = NO;
	scrollToRight = toRight;
	
	if (toRight && (currentIndex < [adeList count] - 1))
	{
		currentIndex += 1;
		
		if (currentIndex >= startIndex + MAX_ADE)
		{
			startIndex += 1;
		}
		
		[self setNeedsDisplay];
	}
	else if (!toRight && currentIndex > 0)
	{
		currentIndex -= 1;
		
		if (currentIndex < startIndex)
		{
			startIndex = currentIndex;
		}
		
		[self setNeedsDisplay];
	}
}

- (void) setSelected:(BOOL) selectedVal
{
	BOOL needsDisplay = (selected != selectedVal);
	
	selected = selectedVal;
	
	if (selected)
	{
		[_calendarView unselectTaskView];	
	}
	
	if (currentIndex >= 0 && currentIndex < adeList.count)
	{
		CalendarADE *ade = [adeList objectAtIndex:currentIndex];
		NSInteger key = ade.key;
		
		printf("ADE key: %d\n", key);
		
		[_smartViewController resetQuickEditMode:!selected taskKey:key];	
		
	}
	
	if (needsDisplay)
	{
		[self setNeedsDisplay];
	}
}

- (NSInteger) getSelectedKey
{
	if (self.selected && currentIndex >= 0 && currentIndex < adeList.count)
	{
		CalendarADE *ade = [adeList objectAtIndex:currentIndex];
		NSInteger key = ade.key;
		
		return key;
	}
	
	return -1;
}

//trung ST3.1
- (NSInteger) getSelectedTaskKey
{
	if (self.selected && currentIndex >= 0 && currentIndex < adeList.count)
	{
		CalendarADE *ade = [adeList objectAtIndex:currentIndex];
		NSInteger key = ade.key;

		//Nang 3.3
//		[ivoUtility fillREInstanceToList:taskmanager.taskList dummykey:key parentKey:ade.parentKey startTime:ade.startTime];
		
		return key;
	}
	
	return -1;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	
	if (adeList == nil || adeList.count == 0)
	{
		return;
	}

	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextClearRect(ctx, rect);
	
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
	
	CGSize leftSize = [@" ADE:" sizeWithFont:font];
	
	switch(taskmanager.currentSetting.iVoStyleID)
	{
		case BG_DEFAULT:
			[[UIColor blackColor] set];
			break;
		case BG_BLACK:
			[[UIColor whiteColor] set];
			break;
	}	
	
	[@" ADE:" drawInRect:CGRectMake(0, 10, leftSize.width, leftSize.height) withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentLeft];	
	
	CGFloat x = 4 + leftSize.width;
	
	for (int i=startIndex; i<currentIndex; i++)
	{
		CalendarADE *ade = [adeList objectAtIndex:i];
		
		//UIColor *color = [[ivoUtility getRGBColorForProject:ade.project isGetFirstRGB:NO] colorWithAlphaComponent:0.5];
		//EK Sync
		//NSInteger colorId = [[projectList objectAtIndex:ade.project] colorId];
		UIColor *color = [[ivoUtility getRGBColorForProject:ade.project isGetFirstRGB:NO] colorWithAlphaComponent:0.5];
		
		[color setFill];
		
		CGContextFillRect(ctx, CGRectMake(x, 12, ADE_SQUARE_SIZE, ADE_SQUARE_SIZE));
		
		x += ADE_SQUARE_SIZE + 4;
	}
	
	CalendarADE *ade = [adeList objectAtIndex:currentIndex];
	
	BOOL moreThan5 = NO;
	
	if (ade != nil)
	{
		CGSize size = [ade.name sizeWithFont:font];

		NSInteger count = adeList.count;
		
		if (adeList.count > MAX_ADE)
		{
			if (startIndex < count - MAX_ADE)
			{
				moreThan5 = YES;
			}
			
			count = MAX_ADE;			
		}
		
		size.width = 320 - leftSize.width - 2*4 - (moreThan5?count:count-1) *(ADE_SQUARE_SIZE + 4); 
		
		CGRect adeRect = CGRectMake(x, 6, size.width, ADE_HEIGHT);

		//UIColor *prjColor = [ivoUtility getRGBColorForProject:ade.project isGetFirstRGB:NO];
		//EK Sync
		//NSInteger colorId = [[projectList objectAtIndex:ade.project] colorId];
		UIColor *prjColor = [ivoUtility getRGBColorForProject:ade.project isGetFirstRGB:NO];
		
		[prjColor setFill];
		
		fillRoundedRect(ctx, adeRect, 4, 4);
		
		if (self.selected)
		{
			[[UIColor yellowColor] set];
			
			CGContextSetLineWidth(ctx, 2);
			
			strokeRoundedRect(ctx, adeRect, 4, 4);
		}		
		
		adeRect.origin.y += BOX_TEXT_PADDING;
		adeRect.size.height -= 2*BOX_TEXT_PADDING;

		adeRect.origin.x += BOX_TEXT_PADDING;
		adeRect.size.width -= 2*BOX_TEXT_PADDING;
		
		CGFloat r = _shadowColor[0]/255;
		CGFloat g = _shadowColor[1]/255;
		CGFloat b = _shadowColor[2]/255;	
		
		UIColor *embossedColor = [UIColor colorWithRed:r green:g blue:b alpha:1];
		
		UIColor *textColor = [UIColor whiteColor];
		
		CGRect embossedRec = CGRectOffset(adeRect, 0, -1);
		
		[embossedColor set];
		[ade.name drawInRect:embossedRec withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentLeft];
		
		[textColor set];
		
		[ade.name drawInRect:adeRect withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentLeft];
		
		x += size.width + 4;		
	}
	
	for (int i=currentIndex + 1; i<startIndex + MAX_ADE; i++)
	{
		if (i < adeList.count)
		{
			CalendarADE *ade = [adeList objectAtIndex:i];
			
			//UIColor *color = [[ivoUtility getRGBColorForProject:ade.project isGetFirstRGB:NO] colorWithAlphaComponent:0.5];
			//EK Sync
			//NSInteger colorId = [[projectList objectAtIndex:ade.project] colorId];
			UIColor *color = [[ivoUtility getRGBColorForProject:ade.project isGetFirstRGB:NO] colorWithAlphaComponent:0.5];			
			
			[color setFill];
			
			CGContextFillRect(ctx, CGRectMake(x, 12, ADE_SQUARE_SIZE, ADE_SQUARE_SIZE));
			
			x += ADE_SQUARE_SIZE + 4;			
		}
		else
		{
			break;
		}
	}
	
	if (moreThan5)
	{
		switch(taskmanager.currentSetting.iVoStyleID)
		{
			case BG_DEFAULT:
				[[UIColor blackColor] set];
				break;
			case BG_BLACK:
				[[UIColor whiteColor] set];
				break;
		}	
		
		[@"..." drawInRect:CGRectMake(x, 6, ADE_SQUARE_SIZE, ADE_HEIGHT) withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentLeft];	
		
	}	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	BOOL doubleTouch = NO;
	
	if (lastTouchTime != nil)
	{
		NSTimeInterval diff = [lastTouchTime timeIntervalSinceNow]*(-1);

		[lastTouchTime release];
		
		lastTouchTime = nil;
		
		if (diff <= 0.5) //double touch
		{
			doubleTouch = YES;
		}
	}
	
//	if (!doubleTouch)
	{
		CGPoint newTouchPoint;
		CGPoint prevTouchPoint;
		
		for (UITouch* touch in touches)
		{
			newTouchPoint = [touch locationInView:self];
			prevTouchPoint = [touch previousLocationInView:self];
		}
		
		UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
		
		CGSize leftSize = [@" ADE:" sizeWithFont:font];
		
		NSInteger count = adeList.count;
		
		BOOL moreThan5 = NO;
		
		if (adeList.count > MAX_ADE)
		{
			if (startIndex < count - MAX_ADE)
			{
				moreThan5 = YES;
			}
			
			count = MAX_ADE;			
		}
		
		CGFloat adeWidth = 320 - leftSize.width - 2*4 - (moreThan5?count:count-1) *(ADE_SQUARE_SIZE + 4); 
		
		CGFloat x = leftSize.width + 4 + (currentIndex - startIndex) *(ADE_SQUARE_SIZE + 4);
		
		//	printf("x:%f touchx:%f\n", x, newTouchPoint.x);
		
		if (newTouchPoint.x > x + adeWidth)
		{
			[self scroll:YES];
		}
		else if (newTouchPoint.x < x)
		{
			[self scroll:NO];
		}
		else
		{
			NSInteger key = -1;

			//trung ST3.1
			NSInteger parentKey = -1;
			NSDate *startTime = nil;
			
			if (currentIndex >= 0 && currentIndex < adeList.count)
			{
				CalendarADE *ade = [adeList objectAtIndex:currentIndex];
				key = ade.key;
				
				//trung ST3.1
				parentKey = ade.parentKey;
				startTime = ade.startTime;
			}
			
			if (doubleTouch)
			{
				printf("double touch\n");
				
				//trung ST3.1 
				//[_calendarView executeCommand:VIEW_TASK key: key];
				[_calendarView executeCommand:VIEW_TASK key: key parentKey:parentKey startTime:startTime];
			}
			else
			{
				printf("select\n");
				
				self.selected = !self.selected;
				
				lastTouchTime = [[NSDate date] copy];
			}
		}
	}
//	else
//	{
//		[self scroll:!scrollToRight];//step back
//	}
}

- (void)dealloc {
	
	if (adeList != nil)
	{
		[adeList release];
	}
	
    [super dealloc];
}


@end
