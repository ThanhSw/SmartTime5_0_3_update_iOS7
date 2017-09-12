//
//  WeekViewTableCell.m
//  SmartTime
//
//  Created by Nang Le on 2/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WeekViewTableCell.h"

@implementation WeekViewTableCell
@synthesize taskName;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		taskName=[[UILabel alloc] initWithFrame:CGRectMake(12, 0, 55, 32)];
		//taskName=[[UILabel alloc] initWithFrame:CGRectMake(12, 0, frame.size.width, 30)];
		taskName.highlightedTextColor=[UIColor whiteColor];
		taskName.font=[UIFont systemFontOfSize:13];
		taskName.numberOfLines=2;
		taskName.backgroundColor=[UIColor clearColor];
		
		[self addSubview:taskName];
		[taskName release];
		
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
