//
//  AutoMappingTableViewCell.m
//  SmartTime
//
//  Created by Huy Le on 8/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AutoMappingTableViewCell.h"
#import "IvoCommon.h"

@implementation AutoMappingTableViewCell

@synthesize projectLabel;
@synthesize gcalLabel;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		projectLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 5, 280, 25)];
		projectLabel.backgroundColor=[UIColor clearColor];
		projectLabel.font=[UIFont boldSystemFontOfSize:16];
		projectLabel.textColor=[UIColor blackColor];
		projectLabel.highlightedTextColor=[UIColor whiteColor];
		projectLabel.text = NSLocalizedString(@"projectText", @"")/*projectText*/;//@"Project";
		[self addSubview:projectLabel];
		[projectLabel release];
		
		gcalLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, 30, 280, 25)];
		gcalLabel.backgroundColor=[UIColor clearColor];
		gcalLabel.font=[UIFont boldSystemFontOfSize:16];
		gcalLabel.textColor=[UIColor blackColor];
		gcalLabel.highlightedTextColor=[UIColor whiteColor];
		gcalLabel.textAlignment = NSTextAlignmentRight;
		gcalLabel.text = NSLocalizedString(@"noneText", @"")/*noneText*/;
		[self addSubview:gcalLabel];
		[gcalLabel release];
		
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
