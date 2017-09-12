//
//  TableCellSettingAutoBump.m
//  SmartTime
//
//  Created by Nang Le on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TableCellSettingAutoBump.h"


@implementation TableCellSettingAutoBump
@synthesize bumpName,notes,switchControl,button;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		bumpName=[[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 20)];
		bumpName.font=[UIFont boldSystemFontOfSize:16];
		bumpName.backgroundColor=[UIColor clearColor];
		[self addSubview:bumpName];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
	if(notes && ![notes superview] ){
		[self addSubview:notes];
	}
	
	if(switchControl && ![switchControl superview]){
		[self addSubview:switchControl];
	}
	
	
	if(button && ![button superview]){
		[self addSubview:button];
	}
	
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
}

- (void)dealloc {
	[button release];
	[bumpName release];
	[notes release];
	[switchControl release];
    [super dealloc];
}


@end
