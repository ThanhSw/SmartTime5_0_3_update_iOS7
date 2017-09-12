//
//  MonthlyTableView.m
//  SmartTime
//
//  Created by Left Coast Logic on 2/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MonthlyTableView.h"
#import "MonthlyTableViewCell.h"
#import "TaskManager.h"
#import "ivo_Utilities.h"
#import "Setting.h"
#import "WeekViewCalController.h"
#import "MonthlyView.h"
#import "MonthlyDayTimeFinder.h" 
#import "SmartTimeAppDelegate.h"
#import "CalendarIconView.h"

extern TaskManager *taskmanager;
extern ivo_Utilities *ivoUtility;
extern SmartTimeAppDelegate *App_Delegate;
extern NSTimeZone *App_defaultTimeZone;

@implementation MonthlyTableView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
/*		
        // Initialization code
		UIColor *txtColor = [UIColor whiteColor];

		CGFloat toWeekButtonWidth = 2*frame.size.width/3;
		
		NSString *weekTitle = @"Week";

		toWeekButton=[ivoUtility createButton:weekTitle 
										   buttonType:UIButtonTypeCustom 
												frame:CGRectMake((frame.size.width - toWeekButtonWidth)/2, 2, toWeekButtonWidth, MONTH_TITLE_HEIGHT - 2) 
										   titleColor:[UIColor whiteColor]
											   target:self 
											 selector:@selector(toWeek:) 
									 normalStateImage:@"no-mash-blue.png" 
								   selectedStateImage:nil];
		
		[self addSubview:toWeekButton];
		
		dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, MONTH_TITLE_HEIGHT - 3, frame.size.width, DAY_TITLE_HEIGHT + 2)];
		dayLabel.text = @"Today";
		dayLabel.font = [UIFont italicSystemFontOfSize:12];
		dayLabel.backgroundColor = [UIColor clearColor];
		dayLabel.textAlignment = NSTextAlignmentCenter;
		dayLabel.textColor = txtColor;
		
		[self addSubview:dayLabel];
 */
		
		//listView = [[UITableView alloc] initWithFrame:CGRectMake(0, MONTH_TITLE_HEIGHT + DAY_TITLE_HEIGHT, frame.size.width, frame.size.height) style:UITableViewStylePlain];
		listView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
		
		listView.separatorStyle = UITableViewCellSeparatorStyleNone;				
		listView.indicatorStyle=UIScrollViewIndicatorStyleWhite;
		listView.delegate = self;
		listView.dataSource = self;

		listView.backgroundColor = [UIColor clearColor];
		/*
		if(taskmanager.currentSetting.iVoStyleID==0){
			// for aesthetic reasons (the background is black), make the nav bar black for this particular page
			listView.backgroundColor=[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
		}else{
			// for aesthetic reasons (the background is black), make the nav bar black for this particular page
			listView.backgroundColor=[UIColor blackColor];
		}		
		*/
		
		[self addSubview:listView];
		
		//tfView = [[MonthlyDayTimeFinder alloc] initWithFrame:CGRectMake(frame.size.width - MONTHVIEW_FREETIME_WIDTH, MONTH_TITLE_HEIGHT + DAY_TITLE_HEIGHT, MONTHVIEW_FREETIME_WIDTH, frame.size.height - MONTH_TITLE_HEIGHT - DAY_TITLE_HEIGHT)];
		//tfView = [[MonthlyDayTimeFinder alloc] initWithFrame:CGRectMake(frame.size.width - MONTHVIEW_FREETIME_WIDTH, 0, MONTHVIEW_FREETIME_WIDTH, frame.size.height - MONTH_TITLE_HEIGHT - DAY_TITLE_HEIGHT)];
		tfView = [[MonthlyDayTimeFinder alloc] initWithFrame:CGRectMake(frame.size.width - MONTHVIEW_FREETIME_WIDTH, 0, MONTHVIEW_FREETIME_WIDTH, frame.size.height)];
		
		[self addSubview:tfView];
		
		[tfView release];
		
		taskList = nil;
    }
    return self;
}

- (void)setCalendarDate:(NSDate *)date isFilter:(BOOL)isFilter
{
	App_Delegate.me.networkActivityIndicatorVisible=YES;
	
	if (calendarDate != nil)
	{
		[calendarDate release];
	}
		
	calendarDate = [date copy];
	
	MonthlyView *parent = [[self superview] superview];	
	
	NSString *dayTitle = [ivoUtility createStringFromDate:calendarDate isIncludedTime:NO];
	
	[parent showDayTitle:dayTitle];
	
    [dayTitle release];
    
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit|NSSecondCalendarUnit;
	
	NSDateComponents *comps = [gregorian components:unitFlags  fromDate:calendarDate];
	/////
	CFGregorianDate gregDate;
	CFAbsoluteTime absTime;
//	SInt32 weekOfYear;
	CFTimeZoneRef zone = CFTimeZoneCreateWithTimeIntervalFromGMT( NULL , 0.0 );
	gregDate.year = comps.year ;
	gregDate.month = comps.month;
	gregDate.day = comps.day;
	gregDate.hour = comps.hour;
	gregDate.minute = comps.minute;
	gregDate.second = comps.second;
	
//	BOOL result = CFGregorianDateIsValid(gregDate, kCFGregorianAllUnits);
	absTime = CFGregorianDateGetAbsoluteTime(gregDate,  NULL );
	
	/////
	NSString *weekTitle = [NSString stringWithFormat:@"Week #%d", CFAbsoluteTimeGetWeekOfYear(absTime,zone)];//[comps week]]; 
/*
	NSDateFormatter *weekFormatter = [[NSDateFormatter alloc] init];
	[weekFormatter setDateFormat:@"w"];
	NSString *weekDateString = [weekFormatter stringFromDate:date];
	[weekFormatter release];
*/	
	[parent showWeekTitle: weekTitle];

	[gregorian release];
	CFRelease(zone);
    
	if (taskList != nil)
	{
		[taskList release];
	}
		
	//taskList = [[taskmanager getTaskListFromDate:calendarDate toDate:calendarDate splitLongTask:YES] retain];
	taskList = [[taskmanager getTaskListFromDate:calendarDate toDate:calendarDate splitLongTask:YES isUpdateTaskList:NO isSplitADE:YES] retain];
	
//	printf("--- Month Day List ---\n");
//	[ivoUtility printTask:taskList];
//	printf("------------------\n");
	
	[listView reloadData];
	
	[tfView showFreeTime:taskList];
	
	App_Delegate.me.networkActivityIndicatorVisible=NO;	
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

/*
-(void)toWeek:(id)sender{
	MonthlyView *parent = [self superview];
	
	[parent toWeek];
}
*/
/*
- (UIButton *)getButton:(NSString *)title 
			 buttonType:(UIButtonType)buttonType
				  frame:(CGRect)frame
				 target:(id)target
			   selector:(SEL)selector
   normalStateTextColor:(UIColor *)normalStateTextColor
 selectedStateTextColor:(UIColor *)selectedStateTextColor

{
	// create a UIButton with buttonType
	UIButton *button = [[UIButton buttonWithType:buttonType] retain];
	button.frame = frame;
	[button setTitle:title forState:UIControlStateNormal];
	button.font=[UIFont systemFontOfSize:14];
	
	[button setTitleColor:normalStateTextColor forState:UIControlStateNormal];
	[button setTitleColor:selectedStateTextColor forState:UIControlStateSelected];
	
	//button.backgroundColor = [UIColor clearColor];
	[button setBackgroundImage:[[UIImage imageNamed:@"no-mash-blue.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[button setBackgroundImage:[[UIImage imageNamed:@"no-mash-white.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateSelected];
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	
	return button;
}
*/

- (void)dealloc {
	if (calendarDate != nil)
	{
		[calendarDate release];
	}
	
	if (taskList != nil)
	{
		[taskList release];
	}
	
	[listView release];
	
	//[toWeekButton release];
	//[dayLabel release];
	
    [super dealloc];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return taskList.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    static NSString *CellIdentifier = @"MonthlyCell";
    
    MonthlyTableViewCell *cell = [( MonthlyTableViewCell *)tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[MonthlyTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	else
	{
		[cell resetIvoStyle];
		NSArray *arr=[cell.contentView subviews];
		for (id view in arr) {
			if ([view isKindOfClass:[CalendarIconView class]]) {
				[view removeFromSuperview];
			}
		}
	}
	
/*	
	if(taskmanager.currentSetting.iVoStyleID==0){
		// for aesthetic reasons (the background is black), make the nav bar black for this particular page
		cell.textColor = [UIColor blackColor];
		//taskName.backgroundColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];
	}else{
		// for aesthetic reasons (the background is black), make the nav bar black for this particular page
		cell.textColor = [UIColor whiteColor];
		//taskName.backgroundColor=[UIColor blackColor];
	}	
*/    
    // Set up the cell...
	cell.selectionStyle=UITableViewCellSelectionStyleNone;
	
	cell.textLabel.font=[UIFont systemFontOfSize:14];
	
	//NSInteger cellIdx = indexPath.row;
	
	if (indexPath.row < taskList.count)
	{
		Task *tmp=[taskList objectAtIndex:indexPath.row];
	
		if (tmp.taskPinned)
		{
			[cell setType:(tmp.isAllDayEvent?0:1) :tmp.taskProject];
		
			[cell setName:(tmp.isAllDayEvent?
						   tmp.taskName:			 
			[NSString stringWithFormat:@"[%@-%@] %@",[ivoUtility getTimeStringFromDate:tmp.taskStartTime],[ivoUtility getTimeStringFromDate:tmp.taskEndTime],tmp.taskName])];
		}
		else
		{
			[cell setType:2 :tmp.taskProject];
		
			if(tmp.taskIsUseDeadLine==1)
			{
				[cell setName:[NSString stringWithFormat:@"[%@] %@",[ivoUtility getShortStringFromDate:tmp.taskDeadLine],tmp.taskName]];
			}
			else
			{
				[cell setName:tmp.taskName];
			}
		}
	}
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 32;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */



@end
