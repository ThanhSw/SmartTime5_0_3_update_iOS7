//
//  EventView.m
//  IVo
//
//  Created by Left Coast Logic on 6/20/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "EventView.h"
#import "ivo_Utilities.h"

#define EVENT_WIDTH 320
#define EVENT_HEIGHT 40

#define EVENT_FONT_SIZE 12
//#define TIME_FONT_SIZE 8
#define TIME_FONT_SIZE 10

static BOOL _eventStartTimeOnLeft = NO;
extern ivo_Utilities	*ivoUtility;
extern MoveAreaMarginStyle _app_movearea_margin_style;
extern CGFloat _shadowColor[];

@implementation EventView

- (id)initWithTask:(Task *)task
{
	//ILOG(@"[EventView initWithTask\n")
	
	if (self = [super initWithTask:task])
	{
		NSString *eventName = [NSString stringWithFormat:@"[%@ %d]: %@", [ivoUtility createMonthName:self.startTime], [ivoUtility getDay:self.startTime], self.name];
		self.name = eventName;
		
		if (task.taskRepeatID > 0)
		{
			self.type = TYPE_SMART_RE;
			
			if (task.isOneMoreInstance)
			{
				self.type = TYPE_SMART_RE_MORE;
			}
		}
		else if (task.parentRepeatInstance > 0)
		{
			self.type = TYPE_SMART_RE_EXC;
		}
		
	}

	//ILOG(@"EventView initWithTask]\n")
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	//ILOG(@"[EventView initWithFrame\n")
	
	if (self = [super initWithFrame:frame]) {
		// Initialization code
		
		if (_app_movearea_margin_style == RIGHT_MARGIN)
		{
			_eventStartTimeOnLeft = YES;
		}
	}
	
	//ILOG(@"EventView initWithFrame]\n")
	return self;
}

- (TaskTypeEnum) getTaskType
{
	return TYPE_SMART_EVENT;
}

- (CGSize) calculateSize
{
	//ILOG(@"[EventView calculateSize\n")
	
	CGSize size;
	
	size.width = EVENT_WIDTH;
	size.height = EVENT_HEIGHT;
	
	if (self.defaultValue == 1)
	{
		CGRect bounds = CGRectMake(0, 0, size.width, size.height);
		
		bounds.origin.x += BOX_TEXT_PADDING;
		bounds.origin.y += BOX_TEXT_PADDING;
		bounds.size.width -= 2*BOX_TEXT_PADDING;
		bounds.size.height -= 2*BOX_TEXT_PADDING;
		
		CGSize timeSize = [ivoUtility getTimeSize:TIME_FONT_SIZE];
		
		bounds.origin.x = (MOVE_AREA_WIDTH - HASHMARK_WIDTH)/2 + timeSize.width;
		bounds.size.width -= (MOVE_AREA_WIDTH - HASHMARK_WIDTH)/2 + 2*timeSize.width;		
		CGFloat fontSize = EVENT_FONT_SIZE;
		
		UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
		
		CGSize fitSize = [self.name sizeWithFont:font constrainedToSize:bounds.size lineBreakMode:UILineBreakModeWordWrap];
		CGSize textSize = [self.name sizeWithFont:font];
		
		size.height = ceil(textSize.width/fitSize.width + 1.5)*textSize.height; 
	}	

	//ILOG(@"EventView calculateSize]\n")
	return size;
}

- (void)layoutSubviews {
	//ILOG(@"[EventView layoutSubviews\n")
	
    [super layoutSubviews];

	CGSize timeSize = [ivoUtility getTimeSize:TIME_FONT_SIZE];
	
	if (!_eventStartTimeOnLeft && _app_movearea_margin_style == LEFT_MARGIN)
	{
		timeSize.height = 0;
	}

	switch (_app_movearea_margin_style)
	{
		case LEFT_MARGIN:
			[moveArea setHashmarkYMargin:timeSize.height];
			
			break;
		case RIGHT_MARGIN:
			[moveArea setHashmarkYMargin:0];			

			break;
	}
	
	//ILOG(@"EventView layoutSubviews]\n")
}

- (void) drawTime:(CGContextRef) ctx
{
	//ILOG(@"[EventView drawTime\n")
	
	CGSize timeSize = [ivoUtility getTimeSize:TIME_FONT_SIZE];
	
	CGRect rec = CGRectZero;
	rec.origin.x = [MoveArea getHashmarkXMargin] - 2;
	rec.origin.y = 2;
	rec.size = timeSize;
	
	UITextAlignment alignment = NSTextAlignmentCenter;
	
	if (_eventStartTimeOnLeft)
	{
		rec.origin.x = HASHMARK_SPACING;
		alignment = NSTextAlignmentLeft;
	}
	else
	{
		rec.origin.x = self.bounds.size.width - timeSize.width - HASHMARK_SPACING - BOX_RIGHT_SHADING;
		alignment = NSTextAlignmentRight;
	}
	
	[[UIColor whiteColor] set];
	
	if (self.selected)
	{
		[[UIColor yellowColor] set];
	}
	
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:TIME_FONT_SIZE];	
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle: NSDateFormatterShortStyle];

	NSString *date = [dateFormatter stringFromDate:self.startTime];
	
	[date drawInRect:rec withFont:font lineBreakMode:UILineBreakModeMiddleTruncation alignment:alignment];

	rec.origin.x = self.bounds.size.width - timeSize.width - 6;
	rec.origin.y = self.bounds.size.height - timeSize.height - 4;
	
	rec.size = timeSize;
	
	alignment = NSTextAlignmentRight;
	
	date = [dateFormatter stringFromDate:self.endTime];
	[date drawInRect:rec withFont:font lineBreakMode:UILineBreakModeMiddleTruncation alignment:alignment];	
	
	[dateFormatter release];
	
	//ILOG(@"EventView drawTime]\n")
}

- (void) drawText:(CGContextRef) ctx
{
	//ILOG(@"[EventView drawText\n")
	
	CGRect bounds = self.bounds;

	CGSize timeSize = [ivoUtility getTimeSize:TIME_FONT_SIZE];
	
	if (_eventStartTimeOnLeft)
	{
		bounds.origin.x = timeSize.width + HASHMARK_SPACING;	
		bounds.size.width -= 2*timeSize.width + 2*HASHMARK_SPACING + BOX_RIGHT_SHADING;
	}
	else
	{
		switch (_app_movearea_margin_style)
		{
			case LEFT_MARGIN:
			{
				CGFloat hashmarkWidth = [MoveArea getHashmarkVisibleWidth]; 
				bounds.origin.x = hashmarkWidth;
				bounds.size.width -= timeSize.width + hashmarkWidth + BOX_RIGHT_SHADING + HASHMARK_SPACING;
			}
				break;
			case RIGHT_MARGIN:
				bounds.origin.x = HASHMARK_SPACING;
				bounds.size.width -= timeSize.width + HASHMARK_SPACING + BOX_RIGHT_SHADING;
				break;
		}
	}
	
	bounds.origin.y += BOX_TEXT_PADDING;
	bounds.size.height -= 2*BOX_TEXT_PADDING;
	
	CGFloat fontSize = EVENT_FONT_SIZE;
	
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

	CGRect textRec = bounds;
	
	//[[UIColor cyanColor] set];
	//CGContextStrokeRect(ctx, bounds);	
	
	CGRect embossedRec = CGRectOffset(textRec, 0, -1);
	
	NSString * loc = [self.location stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	
	if (self.defaultValue == 1)
	{
		[embossedColor set];
		[self.name drawInRect:embossedRec withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:NSTextAlignmentLeft];
		
		[textColor set];
		[self.name drawInRect:textRec withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:NSTextAlignmentLeft];		
	}
	else
	{
		CGSize nameSize = [self.name sizeWithFont:font];
		
		if (nameSize.width < bounds.size.width)
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
	}
	
	//ILOG(@"EventView drawText]\n")
}

- (void)drawRect:(CGRect)rect {
	//ILOG(@"[EventView drawRect\n")
	// Drawing code
	
    // Drawing code here.
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextClearRect(ctx, rect);
	
	[self drawShape:ctx];
	[self drawText:ctx];

	if (!self.isADE)
	{
		[self drawTime:ctx];
	}
	
	if (inPast)
	{
		[self drawOverlay:ctx];
	}
	
	//ILOG(@"EventView drawRect]\n")
}

- (void)dealloc {
	[super dealloc];
}


@end
