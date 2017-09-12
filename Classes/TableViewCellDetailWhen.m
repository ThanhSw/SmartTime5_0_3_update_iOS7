//
//  TableViewCellDetailWhen.m
//  SmartTime
//
//  Created by Nang Le on 1/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TableViewCellDetailWhen.h"
#import "Colors.h"

@implementation TableViewCellDetailWhen
@synthesize title1,title2,value1,value2;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		title1=[[UILabel alloc] initWithFrame:CGRectMake(20, 2.5, 160, 30)];
		title1.backgroundColor=[UIColor clearColor];
		title1.font=[UIFont systemFontOfSize:16];
		title1.textColor=[UIColor darkGrayColor];
		title1.highlightedTextColor=[UIColor whiteColor];
		[self addSubview:title1];
		[title1 release];

		title2=[[UILabel alloc] initWithFrame:CGRectMake(20, 27.5, 160, 30)];
		title2.backgroundColor=[UIColor clearColor];
		title2.font=[UIFont systemFontOfSize:16];
		title2.textColor=[UIColor darkGrayColor];
		title2.highlightedTextColor=[UIColor whiteColor];
		[self addSubview:title2];
		[title2 release];
		
		value1=[[UILabel alloc] initWithFrame:CGRectMake(95, 2.5, 190, 30)];
		value1.backgroundColor=[UIColor clearColor];
		value1.font=[UIFont systemFontOfSize:16];
		value1.textColor=[Colors darkSteelBlue];
		value1.highlightedTextColor=[UIColor whiteColor];
		value1.adjustsFontSizeToFitWidth=YES;
		value1.textAlignment=NSTextAlignmentRight;
		[self addSubview:value1];
		[value1 release];
		
		value2=[[UILabel alloc] initWithFrame:CGRectMake(95, 27.5, 190, 30)];
		value2.backgroundColor=[UIColor clearColor];
		value2.font=[UIFont systemFontOfSize:16];
		value2.textColor=[Colors darkSteelBlue];
		value2.highlightedTextColor=[UIColor whiteColor];
		value2.textAlignment=NSTextAlignmentRight;
		value2.adjustsFontSizeToFitWidth=YES;
		[self addSubview:value2];
		[value2 release];
		
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
