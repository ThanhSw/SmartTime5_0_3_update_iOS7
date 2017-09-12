//
//  TableCellTaskDetailTitle.m
//  SmartTime
//
//  Created by Nang Le on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TableCellTaskDetailTitle.h"


@implementation TableCellTaskDetailTitle
@synthesize taskName,location,editButton;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
	if(taskName && ![taskName superview]){
		[self addSubview:taskName];
	}
	if(location && ![location superview]){
		[self addSubview:location];
	}

	if(editButton && ![editButton superview]){
		[self addSubview:editButton];
	}
    // Configure the view for the selected state
}


- (void)dealloc {
	[taskName release];
	[location release];
	[editButton release];
    [super dealloc];
}


@end
