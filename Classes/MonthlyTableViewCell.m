//
//  MonthlyTableViewCell.m
//  SmartTime
//
//  Created by Left Coast Logic on 2/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MonthlyTableViewCell.h"
#import "IvoCommon.h"
#import "TaskManager.h"
#import "Setting.h"
#import "CalendarIconView.h"

extern TaskManager *taskmanager;

extern NSMutableArray *projectList;

@implementation MonthlyTableViewCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		
		self.backgroundColor = [UIColor clearColor];
		
		//projectIcon = [[UIImageView alloc] initWithFrame:CGRectMake(2, 10, 8, 8)];
		//projectIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle1.png"]];
		
		//[self addSubview:projectIcon];
		
		//taskName=[[UILabel alloc] initWithFrame:CGRectMake(12, 0, LISTVIEW_WIDTH, 32)];
		taskName=[[UILabel alloc] initWithFrame:CGRectMake(12, 0, LISTVIEW_WIDTH - 8, 32)];
		taskName.backgroundColor = [UIColor clearColor];
		//taskName.highlightedTextColor=[UIColor whiteColor];
		taskName.font=[UIFont systemFontOfSize:13];
		taskName.numberOfLines=2;
		
		[self resetIvoStyle];
		
		[self addSubview:taskName];
		
    }
    return self;
}

- (void) resetIvoStyle
{
	if(taskmanager.currentSetting.iVoStyleID==0){
		taskName.textColor = [UIColor blackColor];
	}else{
		taskName.textColor = [UIColor whiteColor];
	}		
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void) setType:(NSInteger)type :(NSInteger)project
{
	/*
	UIImage *image = nil;
	
	//EKSync
	NSInteger colorId = [(Projects*)[projectList objectAtIndex:project] colorId];
	
	switch(type)
	{
		case 0://ADE
			//image = [UIImage imageNamed:[NSString stringWithFormat:@"rec%d.png", project+1]];
			image = [UIImage imageNamed:[NSString stringWithFormat:@"rec%d.png", colorId+1]];
			break;
		case 1: //Event
			//image = [UIImage imageNamed:[NSString stringWithFormat:@"circle%d.png", project+1]];
			image = [UIImage imageNamed:[NSString stringWithFormat:@"circle%d.png", colorId+1]];
			break;
		case 2: //Task
			//image = [UIImage imageNamed:[NSString stringWithFormat:@"poly%d.png", project+1]];
			image = [UIImage imageNamed:[NSString stringWithFormat:@"poly%d.png", colorId+1]];
			break;
	}
	
	projectIcon.image = image;
	 */
	
	CalendarIconView *icon=[[CalendarIconView alloc] initWithFrame:CGRectMake(2, 13, 8, 8)];
	icon.backgroundColor=[UIColor clearColor];
	
	if(type==1){
		icon.isSquareBox=YES;
	}else {
		icon.isSquareBox=NO;
	}
	
	icon.calendarId=project;
	[icon setNeedsDisplay];
	[self.contentView addSubview:icon];
	[icon release];
	
}

-(void) setName:(NSString *)name
{
	taskName.text = name;
}

- (void)dealloc {
	[projectIcon release];
	[taskName release];
	
    [super dealloc];
}


@end
