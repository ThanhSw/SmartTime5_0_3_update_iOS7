//
//  TableCellTaskDetailButton.m
//  SmartTime
//
//  Created by Nang Le on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TableCellTaskDetailButton.h"


@implementation TableCellTaskDetailButton
@synthesize cellName,cellValue,buttonView,editButton,cellValue2,cellName2;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		//cellName=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, 30)];
		//cellName.backgroundColor=[UIColor clearColor];
		//cellName.font=[UIFont systemFontOfSize:16];
		//cellName.textColor=[UIColor darkGrayColor];
		//[self addSubview:cellName];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

	if(cellName && ![cellName superview]){
		[self addSubview:cellName];
	}
	
	if(cellValue && ![cellValue superview]){
		[self addSubview:cellValue];
	}
	
	if(buttonView && ![buttonView superview]){
		[self addSubview:buttonView];
	}
	
	if(editButton && ![editButton superview]){
		[self addSubview:editButton];
	}
	
	if(cellValue2 && ![cellValue2 superview]){
		[self addSubview:cellValue2];
	}
	
	if(cellName2 && ![cellName2 superview]){
		[self addSubview:cellName2];
	}
    // Configure the view for the selected state
}


- (void)dealloc {
	[cellName release];
	[cellValue release];
	[buttonView release];
	[editButton release];
	[cellValue2 release];
	[cellName2 release];
    [super dealloc];
}


@end
