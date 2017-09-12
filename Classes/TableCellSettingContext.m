//
//  TableCellSettingContext.m
//  SmartTime
//
//  Created by Nang Le on 10/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TableCellSettingContext.h"
#import "Colors.h"
#import "IvoCommon.h"

@implementation TableCellSettingContext
@synthesize contextName,weekDayValue,weekEndValue,imageView;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		
        // Initialization code
		contextName=[[UILabel alloc] initWithFrame: CGRectMake(20, 10, 90, 20)];
        contextName.backgroundColor=[UIColor clearColor];
		contextName.highlightedTextColor=[UIColor whiteColor];
		contextName.textAlignment=NSTextAlignmentLeft;
		contextName.font=[UIFont boldSystemFontOfSize:16];
		[self addSubview:contextName];
		
		weekDayName=[[UILabel alloc] initWithFrame:CGRectMake(20, 30, 90, 20)];
        weekDayName.backgroundColor=[UIColor clearColor];
		weekDayName.font=[UIFont systemFontOfSize:16];
		weekDayName.highlightedTextColor=[UIColor whiteColor];
		weekDayName.text=NSLocalizedString(@"contextWDayCellText", @"")/*contextWDayCellText*/;
		[self addSubview:weekDayName];
		//[weekDayName release];
		
		weekEndName=[[UILabel alloc] initWithFrame:CGRectMake(20, 50, 90, 20)];
        weekEndName.backgroundColor=[UIColor clearColor];
		weekEndName.font=[UIFont systemFontOfSize:16];
		weekEndName.highlightedTextColor=[UIColor whiteColor];
		weekEndName.text=NSLocalizedString(@"contextWEndCellText", @"")/*contextWEndCellText*/;
		[self addSubview:weekEndName];
		//[weekEndName release];
		
		weekDayValue=[[UILabel alloc] initWithFrame: CGRectMake(90, 30, 195, 20)];
        weekDayValue.backgroundColor=[UIColor clearColor];
		weekDayValue.highlightedTextColor=[UIColor whiteColor];
		weekDayValue.textColor=[Colors darkSteelBlue];
		weekDayValue.textAlignment=NSTextAlignmentRight;
		[self addSubview:weekDayValue];

		weekEndValue=[[UILabel alloc] initWithFrame: CGRectMake(90, 50, 195, 20)];
        weekEndValue.backgroundColor=[UIColor clearColor];
		weekEndValue.highlightedTextColor=[UIColor whiteColor];
		weekEndValue.textColor=[Colors darkSteelBlue];
		weekEndValue.textAlignment=NSTextAlignmentRight;
		[self addSubview:weekEndValue];
		
		imageView=[[UIImageView alloc] initWithFrame:CGRectMake(272, 10, 13, 13)];
		[self addSubview:imageView];
		
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[contextName release];
	[weekDayValue release];
	[weekEndValue release];
	[imageView release];
	[weekDayName release];
	[weekEndName release];
	
    [super dealloc];
}


@end
