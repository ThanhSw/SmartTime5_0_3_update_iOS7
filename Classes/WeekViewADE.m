//
//  WeekViewADE.m
//  SmartTime
//
//  Created by Nang Le on 2/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WeekViewADE.h"
#import "ivo_Utilities.h"
#import "Projects.h"
#import "IvoCommon.h"

extern ivo_Utilities	*ivoUtility;

//EKSync
extern NSMutableArray *projectList;

@implementation WeekViewADE
@synthesize adeName,projectID;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		viewFrame=frame;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code

 	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextClearRect(ctx, rect);
	
	[[UIColor whiteColor] set];
	
	UIFont *font=[UIFont systemFontOfSize:12];
			
	CGRect adeRect = CGRectMake(0,0, viewFrame.size.width,viewFrame.size.height);
		
	//UIColor *prjColor = [ivoUtility getRGBColorForProject:self.projectID isGetFirstRGB:NO];
	//EKSync
	//NSInteger colorId = [[projectList objectAtIndex:self.projectID] colorId];
	UIColor *prjColor = [ivoUtility getRGBColorForProject:self.projectID isGetFirstRGB:NO];
	
	[prjColor setFill];
		
	fillRoundedRect(ctx, adeRect, 4, 4);
	
	adeRect = CGRectOffset(adeRect, 0, -1);
		
	UIColor *textColor = [UIColor whiteColor];
	[textColor set];
		
	[[NSString stringWithFormat:@" %@", self.adeName] drawInRect:adeRect withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:NSTextAlignmentLeft];
			
}


- (void)dealloc {
    [super dealloc];
}


@end
