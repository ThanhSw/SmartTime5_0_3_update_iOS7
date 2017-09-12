//
//  TableViewCellLeftRightValue.m
//  SmartTime
//
//  Created by NangLe on 10/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TableViewCellLeftRightValue.h"


@implementation TableViewCellLeftRightValue
@synthesize leftLabel;
@synthesize rightLabel;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		leftLabel=[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 135, 44)];
		leftLabel.backgroundColor=[UIColor clearColor];
		leftLabel.textAlignment=NSTextAlignmentCenter;
		leftLabel.font=[UIFont systemFontOfSize:14];
		leftLabel.numberOfLines=2;
		leftLabel.highlightedTextColor=[UIColor whiteColor];
		
		[self.contentView addSubview:leftLabel];
		[leftLabel release];
		
		rightLabel=[[UILabel alloc] initWithFrame:CGRectMake( 160, 0, 135, 44)];
		rightLabel.backgroundColor=[UIColor clearColor];
		rightLabel.font=[UIFont systemFontOfSize:14];
		rightLabel.textAlignment=NSTextAlignmentCenter;
		rightLabel.numberOfLines=2;
		rightLabel.highlightedTextColor=[UIColor whiteColor];
		
		[self.contentView addSubview:rightLabel];
		[rightLabel release];
		
		UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(140, 15, 20, 14)];
		imgView.image=[UIImage imageNamed:@"syncIcon.png"];
		[self.contentView addSubview:imgView];
		[imgView release];
		
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
