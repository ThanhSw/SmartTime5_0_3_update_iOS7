//
//  MoveArea.m
//  IVo
//
//  Created by Left Coast Logic on 6/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MoveArea.h"
#import "TaskView.h"

#define HASHMARK_TOP_MARGIN 7
//#define HASHMARK_WIDTH 20
#define HASHMARK_HEIGHT 2
//#define HASHMARK_BETWEEN_SPACE 6
#define HASHMARK_BETWEEN_SPACE 5

#define TIME_SLOT_HEIGHT 22

//adjust for task/event with small duration
#define HASHMARK_SPACE_ADJUSTMENT 0
#define HASHMARK_TOP_MARGIN_ADJUSTMENT -2

extern MoveAreaStyle _app_movearea_style;
extern MoveAreaMarginStyle _app_movearea_margin_style;

@implementation MoveArea

@synthesize howLong;
@synthesize enable;
@synthesize visible;
@synthesize taskType;
@synthesize selected;

- (id)initWithFrame:(CGRect)frame {
	//ILOG(@"[MoveArea initWithFrame\n")
	
	if (self = [super initWithFrame:frame]) {
		// Initialization code
		self.backgroundColor = [UIColor clearColor];
		self.howLong = SMALL;
		self.enable = YES;
		self.visible = YES;
		self.selected = NO;
		
		hashMarkYMargin = 0;
	}
	
	//ILOG(@"MoveArea initWithFrame]\n")
	return self;
}

- (void) setSelected:(BOOL) selectedVal
{
	//ILOG(@"[MoveArea setSelected\n")
	
	BOOL needsDisplay = (selected != selectedVal);
	
	selected = selectedVal;

	if (needsDisplay)
	{
		[self setNeedsDisplay];
	}
	
	//ILOG(@"MoveArea setSelected]\n")
}

/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//ILOG(@"[MoveArea touchesBegan\n")
	
	if (self.enable)
	{
		TaskView *taskview = (TaskView *) self.superview;
	
		[taskview beginMoveTaskView];
	}
	//ILOG(@"MoveArea touchesBegan]\n")
}
*/

- (void)drawRect:(CGRect)rect {
	//ILOG(@"[MoveArea drawRect\n")
	// Drawing code
	if (!self.visible)
	{
		return;
	}
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextClearRect(ctx, rect);
	CGFloat offset = hashMarkYMargin;
	
	CGPoint points[2];
	
	UIColor *darkColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
	
	UIColor *lightColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
	
	UIColor *disableColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.3];

	UIColor *enableColor = [UIColor whiteColor];
	
	if (self.selected)
	{
		enableColor = [UIColor yellowColor];
		lightColor = [UIColor yellowColor];
	}
	
	CGFloat leftMargin = [MoveArea getHashmarkXMargin];
	
	NSInteger max = MAXDURATION;

	CGFloat topMargin = HASHMARK_TOP_MARGIN;
	if (self.taskType == TYPE_CALENDAR_TASK && self.howLong == SMALL)
	{
		topMargin += HASHMARK_TOP_MARGIN_ADJUSTMENT;
	}
	
	for (NSInteger i=SMALL; i<max; i++)
	{
		points[0].x = leftMargin;
		points[0].y = topMargin + offset;
		
		if (self.taskType == TYPE_CALENDAR_TASK && self.frame.size.height <=TIME_SLOT_HEIGHT)
		{
			points[0].y += HASHMARK_TOP_MARGIN_ADJUSTMENT;
		}
		
		points[1].x = points[0].x + HASHMARK_WIDTH;
		points[1].y = points[0].y;
		
		switch (_app_movearea_style)
		{
			case APPLE_STYLE:
			{
				CGRect rec = CGRectMake(points[0].x, points[0].y, HASHMARK_WIDTH, HASHMARK_HEIGHT);
		
				if (i <= self.howLong)
				{
					CGFloat r = (double) 139/255;
					CGFloat g = (double) 158/255;
					CGFloat b = (double) 177/255;
				
					UIColor *grayColor = [UIColor colorWithRed:r green:g blue:b alpha:1];
				
					[grayColor setFill];
					CGContextFillRect(ctx, rec);

					[darkColor set];

					CGContextSetLineWidth(ctx, 0.5);
	
					CGContextStrokeLineSegments(ctx, points, 2);
				}
				else
				{
					[disableColor setFill];
					CGContextFillRect(ctx, rec);					
				}
				
				points[0].y += HASHMARK_HEIGHT;
				points[1].y = points[0].y;
				
				CGContextSetLineWidth(ctx, 0.25);
				
				[lightColor set];
				
				CGContextStrokeLineSegments(ctx, points, 2);
				
			}
				break;
			case IVO_STYLE:
			{
				if (i <= self.howLong)
				{
					[enableColor set];
					CGContextSetLineWidth(ctx, 1.25);
				}
				else
				{
					CGContextSetLineWidth(ctx, 2);
					[disableColor set];
				}
				
				CGContextStrokeLineSegments(ctx, points, 2);
				
				if (i <= self.howLong)
				{
					points[0].x += 1;
					points[0].y += 1.75;
					points[1].x += 1;
					points[1].y += 1.75;
										
					[darkColor set];
					CGContextSetLineWidth(ctx, 0.25);
					CGContextStrokeLineSegments(ctx, points, 2);
				}
				else
				{
					points[0].y += 1.75;
					points[1].y += 1.75;
					
					[lightColor set];
					CGContextSetLineWidth(ctx, 0.25);
					CGContextStrokeLineSegments(ctx, points, 2);					
				}
			}
				break;
		}
		
		offset += HASHMARK_BETWEEN_SPACE;
		if (self.taskType == TYPE_CALENDAR_TASK && self.howLong == SMALL)
		{
			offset += HASHMARK_SPACE_ADJUSTMENT;
		}
		
	}
	//ILOG(@"MoveArea drawRect]\n")
 }

- (void) setHashmarkYMargin:(CGFloat) margin
{
	hashMarkYMargin = margin;
}

- (void)dealloc {
	[super dealloc];
}

+ (CGFloat) getHashmarkXMargin
{
	switch (_app_movearea_margin_style)
	{
		case LEFT_MARGIN:
			return HASHMARK_SPACING;
			
			break;
		case RIGHT_MARGIN:
		{
			return (MOVE_AREA_WIDTH - HASHMARK_WIDTH - HASHMARK_SPACING - BOX_RIGHT_SHADING);
		}
			break;
	}
	
	return 0;
}

+ (CGFloat) getHashmarkVisibleWidth
{
	return 2*HASHMARK_SPACING + HASHMARK_WIDTH;
}


@end
