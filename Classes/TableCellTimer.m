//
//  TableCellTimer.m
//  SmartTime
//
//  Created by Nang Le on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TableCellTimer.h"


@implementation TableCellTimer
@synthesize cellValue,button;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
	
	if(cellValue && ![cellValue superview]){
//		[cellValue removeFromSuperview];
//	}
		cellValue.backgroundColor=[UIColor clearColor];
		[self addSubview:cellValue];
	}
	
	
	if(selected){
		if(button && ![button superview]){
			CGRect frm=CGRectMake(120, 0, 150, 43);
			cellValue.frame=frm;	
			[self addSubview:button];
		}
	}else {
		if(button && [button superview]){
			CGRect frm=CGRectMake(120, 0, 175, 43);
			cellValue.frame=frm;	
			[button removeFromSuperview];
		}
	}


	
    // Configure the view for the selected state
}


- (void)dealloc {
	[cellValue release];
	[button release];
    [super dealloc];
}


@end
