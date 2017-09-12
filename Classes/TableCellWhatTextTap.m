//
//  TableCellWhatTextTap.m
//  SmartTime
//
//  Created by Nang Le on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TableCellWhatTextTap.h"


@implementation TableCellWhatTextTap
@synthesize instruction,buttonView,editText;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
	
	if(instruction && ![instruction superview])
		[self addSubview:instruction];

	if(buttonView && ![buttonView superview])
		[self addSubview:buttonView];
	
//	if(NSLocalizedString(@"editText", @"")/*editText*/ && ![NSLocalizedString(@"editText", @"")/*editText*/ superview])
//		[self addSubview:NSLocalizedString(@"editText", @"")/*editText*/];
	if(editText && ![editText superview])
		[self addSubview:editText];
	
    // Configure the view for the selected state
}


- (void)dealloc {
	[instruction release];
	[buttonView release];
	//editText.delegate=nil;
	[editText release];
    [super dealloc];
}


@end
