//
//  CalendarEventView.m
//  iVo
//
//  Created by Left Coast Logic on 7/24/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "IvoCommon.h"
#import "CalendarEventView.h"

#define TASK_FONT_SIZE 12

#define TIME_FONT_SIZE 8

extern MoveAreaMarginStyle _app_movearea_margin_style;
extern CGFloat _shadowColor[];

@implementation CalendarEventView

- (id)initWithTask:(Task *)task
{
	//ILOG(@"[EventView initWithTask\n")
	
	if (self = [super initWithTask:task])
	{
		if (task.taskRepeatID > 0)
		{
			self.type = TYPE_CALENDAR_RE;
            if (task.taskPinned==0) {
                self.isRepeatTask=YES;
            }else{
                self.isRepeatTask=NO;
            }
		}
		else if (task.parentRepeatInstance > 0)
		{
			self.type = TYPE_CALENDAR_RE_EXC;
		}		
	}
	
	return self;
}
- (id)initWithFrame:(CGRect)frame {
	//ILOG(@"[CalendarEventView initWithFrame\n")
	
	if (self = [super initWithFrame:frame]) {
		// Initialization code
	}
	
	//ILOG(@"CalendarEventView initWithFrame]\n")
	return self;
}

- (TaskTypeEnum) getTaskType
{
	return TYPE_CALENDAR_EVENT;
}

- (void)drawRect:(CGRect)rect {
	// Drawing code
	[super drawRect:rect];
}

- (void) drawText:(CGContextRef) ctx
{
	//ILOG(@"[CalendarEventView drawText\n")
	CGRect bounds = self.bounds;
	
	bounds.origin.y += BOX_TEXT_PADDING;
	bounds.size.height -= 2*BOX_TEXT_PADDING;
	
	CGFloat fontSize = TASK_FONT_SIZE;
	
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
	
	CGFloat r = _shadowColor[0]/255;
	CGFloat g = _shadowColor[1]/255;
	CGFloat b = _shadowColor[2]/255;
	
	UIColor *embossedColor = [UIColor colorWithRed:r green:g blue:b alpha:1];
	
	UIColor *textColor = [UIColor whiteColor];	
			
	if (selected)
	{
		textColor = [UIColor yellowColor];
	}

	CGFloat hashmarkWidth = [MoveArea getHashmarkVisibleWidth];

	switch (_app_movearea_margin_style)
	{
		case LEFT_MARGIN:
			bounds.origin.x = hashmarkWidth;
			bounds.size.width -= hashmarkWidth + HASHMARK_SPACING + BOX_RIGHT_SHADING;
			break;
		case RIGHT_MARGIN:
			bounds.origin.x = HASHMARK_SPACING;
			bounds.size.width -= hashmarkWidth + HASHMARK_SPACING + BOX_RIGHT_SHADING;
			break;
	}

	CGRect textRec = bounds;
	
	//[[UIColor cyanColor] set];
	//CGContextStrokeRect(ctx, bounds);	
	
	CGRect embossedRec = CGRectOffset(textRec, 0, -1);
		
	CGSize nameSize = [self.name sizeWithFont:font];
	
	NSString * loc = [self.location stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

	if (self.duration == SMALL || nameSize.width >= 2*bounds.size.width)
	{
		[embossedColor set];
		[self.name drawInRect:embossedRec withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentLeft];
	
		[textColor set];
		[self.name drawInRect:textRec withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentLeft];
	}
	else if (nameSize.width < bounds.size.width)
	{
		textRec.size.height = nameSize.height;
		
		embossedRec = CGRectOffset(textRec, 0, -1);
		
		[embossedColor set];
		[self.name drawInRect:embossedRec withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentLeft];
		
		[textColor set];
		[self.name drawInRect:textRec withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentLeft];
		
		textRec = CGRectOffset(textRec, 0, textRec.size.height);
		embossedRec = CGRectOffset(textRec, 0, -1);
		
		font = [UIFont fontWithName:@"Helvetica" size:fontSize];

		[embossedColor set];
		[loc drawInRect:embossedRec withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentLeft];
		
		[textColor set];
		[loc drawInRect:textRec withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentLeft];
		
	}
	else if (nameSize.width < 2*bounds.size.width)
	{
		CGSize oneCharSize = [@"A" sizeWithFont:font];
		NSInteger maxChars = floor(2*bounds.size.width/oneCharSize.width);
		
		NSInteger length = [self.name length];
		NSString *s = self.name;
		
		if (length > maxChars)
		{
			s = [s substringToIndex:maxChars]; 
		}
						   
		CGSize size = [s sizeWithFont:font constrainedToSize:bounds.size lineBreakMode:UILineBreakModeTailTruncation];
		
		[embossedColor set];
		[self.name drawInRect:embossedRec withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentLeft];
		
		[textColor set];
		[self.name drawInRect:textRec withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentLeft];

		textRec.size.width = bounds.size.width - (nameSize.width - size.width);
		textRec.origin.x = bounds.origin.x + bounds.size.width - textRec.size.width;
		textRec.size.height = nameSize.height;
		textRec.origin.y = bounds.origin.y + nameSize.height;
		
		if (textRec.size.width >= 20)
		{
			textRec.origin.x += 6;
			textRec.size.width -= 6;
		
			embossedRec = CGRectOffset(textRec, 0, -1);
		
			font = [UIFont fontWithName:@"Helvetica" size:fontSize];
		
			[embossedColor set];
			[loc drawInRect:embossedRec withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentLeft];
		
			[textColor set];
			[loc drawInRect:textRec withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentLeft];
		}
	}
	else
	{
		embossedRec = CGRectOffset(textRec, 0, -1);
		
		[embossedColor set];
		[self.name drawInRect:embossedRec withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentLeft];
		
		[textColor set];
		[self.name drawInRect:textRec withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentLeft];			
	}
	
	//ILOG(@"[CalendarEventView drawText\n")
}

- (void)dealloc {
	[super dealloc];
}


@end
