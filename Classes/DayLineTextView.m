//
//  DayLineTextView.m
//  SmartTime
//
//  Created by Left Coast Logic on 10/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DayLineTextView.h"

#import "IvoCommon.h"
#import "Setting.h"
#import "TaskManager.h"

//extern Setting *currentSetting;
extern TaskManager	*taskmanager;

@implementation DayLineTextView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		//self.editable = NO;
		self.font = [UIFont italicSystemFontOfSize:12];
		self.textAlignment = NSTextAlignmentCenter;
/*		
		switch(currentSetting.iVoStyleID)
		{
			case BG_DEFAULT:
				self.textColor = [UIColor blackColor];
				break;
			case BG_BLACK:
				self.textColor = [UIColor whiteColor];
				break;
		}
*/		
    }
    return self;
}

- (void)drawRect:(CGRect)rect 
{
	switch(taskmanager.currentSetting.iVoStyleID)
	{
		case BG_DEFAULT:
			self.textColor = [UIColor darkGrayColor];
			break;
		case BG_BLACK:
			self.textColor = [UIColor whiteColor];
			break;
	}

	[super drawRect:rect];
}
/*
- (void)drawRect:(CGRect)rect {
    // Drawing code
	UIColor *color = [UIColor blackColor];
	
	switch(currentSetting.iVoStyleID)
	{
		case BG_DEFAULT:
			break;
		case BG_BLACK:
			color = [UIColor whiteColor];
			break;
	}
	
	[color set];
	
	[self.text drawInRect:self.frame withFont:[UIFont italicSystemFontOfSize:12] lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentCenter];
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
