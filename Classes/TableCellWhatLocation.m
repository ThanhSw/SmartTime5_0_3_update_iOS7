//
//  TableCellWhatLocation.m
//  SmartTime
//
//  Created by Nang Le on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TableCellWhatLocation.h"


@implementation TableCellWhatLocation
@synthesize cellContent,editLocationButton;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		//cellContent=[[UILabel alloc] initWithFrame:CGRectMake(20, 2, 250, 74)];
		//cellContent.highlightedTextColor=[UIColor whiteColor];
		//cellContent.numberOfLines=0;
		//[self addSubview:cellContent];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

	if(cellContent && ![cellContent superview])
		[self addSubview:cellContent];
	
	if(editLocationButton && ![editLocationButton superview])
		[self addSubview:editLocationButton];
    // Configure the view for the selected state
}


- (void)dealloc {
	[editLocationButton release];
	[cellContent release];
    [super dealloc];
}


@end
