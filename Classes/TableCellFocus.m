//
//  TableCellFocus.m
//  SmartTime
//
//  Created by Nang Le on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TableCellFocus.h"
#import "Colors.h"

@implementation TableCellFocus
@synthesize taskName,startTime,leftImgView,rightButton;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		taskName=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 27)];
		taskName.highlightedTextColor=[UIColor whiteColor];
		taskName.font=[UIFont systemFontOfSize:14];
		taskName.backgroundColor=[UIColor clearColor];
		
		[self addSubview:taskName];
		
		startTime=[[UILabel alloc] initWithFrame:CGRectMake(200, 20, 100, 10)];
		startTime.font=[UIFont systemFontOfSize:10];
		startTime.textColor=[UIColor redColor];
		startTime.highlightedTextColor=[UIColor whiteColor];
		startTime.textAlignment=NSTextAlignmentRight;
		startTime.backgroundColor=[UIColor clearColor];
		[self addSubview:startTime];

    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
	if(selected){
		CGRect frm=CGRectMake(40, 0, 230, 27);
		taskName.frame=frm;
		frm=CGRectMake(180, 20, 100, 10);
		startTime.frame=frm;

		//if(leftButton && ![leftButton superview]){
		//	[self addSubview:leftButton];
		//}

		//if(rightButton && ![rightButton superview]){
		//	[self addSubview:rightButton];
		//}
	}else {
		CGRect frm=CGRectMake(40, 0, 260, 27);
		taskName.frame=frm;
		frm=CGRectMake(200, 20, 100, 10);
		startTime.frame=frm;
		
		//if([leftButton superview]){
		//	[leftButton removeFromSuperview];
		//}
		
		//if([rightButton superview]){
		//	[rightButton removeFromSuperview];
		//}
	}

	
	
    // Configure the view for the selected state
}


- (void)dealloc {
	[taskName release];
	[startTime release];
	[leftImgView release];
	[rightButton release];
    [super dealloc];
}


@end
