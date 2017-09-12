//
//  TableCellTaskDetailNotes.m
//  SmartTime
//
//  Created by Nang Le on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TableCellTaskDetailNotes.h"


@implementation TableCellTaskDetailNotes
@synthesize cellContent;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
	if(cellContent && ![cellContent superview])
	[self addSubview:cellContent];
    // Configure the view for the selected state
}


- (void)dealloc {
	[cellContent release];
    [super dealloc];
}


@end
