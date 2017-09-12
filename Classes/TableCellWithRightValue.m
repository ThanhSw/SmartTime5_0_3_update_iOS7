//
//  TableCellWithRightValue.m
//  SmartTime
//
//  Created by Nang Le on 10/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TableCellWithRightValue.h"
#import "Colors.h"

@implementation TableCellWithRightValue
@synthesize value;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		value=[[UILabel alloc] initWithFrame:CGRectMake(85, 0, 200, 45)];
		value.backgroundColor=[UIColor clearColor];
		value.textAlignment=NSTextAlignmentRight;
		value.highlightedTextColor=[UIColor whiteColor];
		value.textColor=[Colors darkSteelBlue];
		[self addSubview:value];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}


- (void)dealloc {
	[value removeFromSuperview];
	[value release];
    [super dealloc];
}


@end
