//
//  FilterView.m
//  iVoProtoTypes
//
//  Created by Nang Le on 6/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FilterView.h"
#import "SmartTimeAppDelegate.h"
#import "Projects.h"
#import "SmartViewController.h"
#import "ivo_Utilities.h"
#import "ProjectViewController.h"

//#import "QuartzCore/QuartzCore.h"

#define kStdButtonWidth			106.0
#define kStdButtonHeight		40.0

extern NSMutableArray *projectList;
extern	ivo_Utilities	*ivoUtility;
extern CGRect	smartViewFrameAd;

@implementation FilterView
@synthesize rootView;
			//taskStyleCriterionClause,projectCriterionClause,contextCriterionClause,titleCriterionClause,queryClause,queryDoTodayClause;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		// Initialization code
		
		self.backgroundColor=[UIColor blackColor];
		UIButton *applyFilter=[self buttonWithTitle:NSLocalizedString(@"applyFilterText", @"")/*applyFilterText*/ 
											 target:self 
										   selector:@selector(applyFilter:) 
											  frame:CGRectMake(10, frame.size.height-44, 300, 35)
											  image:@"whiteButton.png" 
									   imagePressed:@"blueButton.png"
									  darkTextColor:NO];		
		[self addSubview:applyFilter];
		[applyFilter release];
		
		UIView *contentView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width,frame.size.height-60)];
		contentView.backgroundColor=[UIColor groupTableViewBackgroundColor];
		
		CGRect tableViewFrame;
#ifdef FREE_VERSION
		tableViewFrame = CGRectMake(0, 5+smartViewFrameAd.origin.y, frame.size.width,320-smartViewFrameAd.origin.y);
#else	
		tableViewFrame = CGRectMake(0, 5, frame.size.width,frame.size.height-60);
#endif
		//CGRect tableViewFrame = CGRectMake(0, 5, frame.size.width,320);
		tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
		//tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
		tableView.sectionHeaderHeight=3;
		tableView.sectionFooterHeight=4;
		tableView.delegate = self;
		tableView.dataSource = self;
		tableView.scrollEnabled=NO;
		[tableView setEditing:NO];
		[contentView addSubview:tableView];
		[tableView release];
		
		[self addSubview:contentView];
		[contentView release];
		
		titleView=[[UITextField alloc] initWithFrame:CGRectMake(10,2.5,280,25)];
		titleView.delegate=self;
		titleView.returnKeyType = UIReturnKeyDone;
		titleView.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
		titleView.placeholder=NSLocalizedString(@"keyWordText", @"")/*keyWordText*/;
		titleView.font=[UIFont systemFontOfSize:16];
		titleView.clearButtonMode=UITextFieldViewModeWhileEditing;
		
		taskButton=[self getButton:NSLocalizedString(@"taskText", @"")/*taskText*/
						   buttonType:UIButtonTypeCustom
								frame:CGRectMake(107, 5, 85, 30)
							   target:self 
							 selector:@selector(taskCriterion:)
			  normalStateTextColor:[UIColor brownColor]
			selectedStateTextColor:[UIColor whiteColor]];
		
		eventButton=[self getButton:NSLocalizedString(@"eventText", @"")/*eventText*/
							buttonType:UIButtonTypeCustom
								 frame:CGRectMake(205, 5, 85, 30)
								target:self 
							  selector:@selector(eventCriterion:)
				  normalStateTextColor:[UIColor brownColor]
				selectedStateTextColor:[UIColor whiteColor]];
		
		deskButton=[self getButton:NSLocalizedString(@"workText", @"")/*workText*/
						   buttonType:UIButtonTypeCustom
								frame:CGRectMake(107, 5, 85, 30)
							   target:self 
							 selector:@selector(deskCriterion:)
				 normalStateTextColor:[UIColor brownColor]
			   selectedStateTextColor:[UIColor whiteColor]];
		
		homeButton=[self getButton:NSLocalizedString(@"homeText", @"")/*homeText*/ 										 
						   buttonType:UIButtonTypeCustom
								frame:CGRectMake(205, 5, 85, 30) 
							   target:self 
							 selector:@selector(homeCriterion:)
				 normalStateTextColor:[UIColor brownColor]
			   selectedStateTextColor:[UIColor whiteColor]];
		
		projectViewController=[[ProjectViewController alloc] init];
		projectViewController.view.frame=CGRectMake(10, 0, 280, self.frame.size.height-250);
		projectViewController.keyEdit=PROJECT_FILTER;
		projectViewController.editing=YES;
	
		
	}
	return self;
}


- (void)drawRect:(CGRect)rect {
	// Drawing code
    /*
	CGContextRef myContext = UIGraphicsGetCurrentContext();
	
	CGGradientRef myGradient;
	CGColorSpaceRef myColorspace;
	size_t num_locations = 3;
	
	CGFloat locations[3] = { 0.0,1,1 };
	CGFloat components[12] = { 1, 1, 1, 0.0, // Start color
								0.25, 0.25, 0.25, 1.0, 
								0.1, 0.1, 0.1, 0.0 };
		
	//myColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	myColorspace = CGColorSpaceCreateWithName(CFSTR("kCGColorSpaceGenericRGB"));
	
	myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
														  locations, num_locations);
	
	CGPoint myStartPoint, myEndPoint;
	myStartPoint.x = self.bounds.origin.x;
	myStartPoint.y =self.bounds.origin.y;
	myEndPoint.x =self.bounds.origin.y;
	myEndPoint.y = self.bounds.size.width+30;
	
	CGContextDrawLinearGradient (myContext, myGradient, myStartPoint, myEndPoint, 0);	
	CGGradientRelease(myGradient);
     */
}


- (void)dealloc {

	tableView.delegate=nil;
	tableView.dataSource=nil;
	
	[rootView release];
	rootView=nil;
	
	[titleView release];
	[taskButton release];
	[eventButton release];
	[deskButton release];
	[homeButton release];
	[projectViewController release];
	/*
	[noneButton release];
	[urgentButton release];
	[privateButton release];
	[projectAButton release];
	[projectBButton release];
	[projectCButton release];
	[project7Button release];
	[project8Button release];
	[project9Button release];
	[project10Button release];
	[project11Button release];
	[project12Button release];
	*/
	[super dealloc];
}

#pragma mark touch methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	for (UITouch *touch in touches) {
		if(!CGRectContainsPoint([titleView frame], [touch locationInView:self])){
			//[titleView UITextViewTextDidEndEditingNotification];
		}
	}	
}


#pragma mark -
#pragma mark === TableView datasource methods ===
#pragma mark -

// As the delegate and data source for the table, the PreferencesView must respond to certain methods the table view
// will call to get the number of sections, the number of rows, and the cell for a row.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if(section==0){
		return nil;
	}else if(section==1){
		return nil;
	}else if(section==2){
		return nil;
	}else if(section==3){
		return NSLocalizedString(@"projectText", @"")/*projectText*/;//@"Project";
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
		return @"";
}

#pragma mark -
#pragma mark === TableView delegate methods ===
#pragma mark -
// Specify the kind of accessory view (to the far right of each row) we will use
//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
//		return UITableViewCellAccessoryNone;
//}

// Provide cells for the table, with each showing one of the available time signatures
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
	}else {
		NSArray *subViews=[cell.contentView subviews];
		for(id view in subViews){
			if([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UIButton class]] ||
			   [view isKindOfClass:[UITableView class]])

				[view removeFromSuperview];
		}
	}

	
	//cell.selectionStyle=UITableViewCellSelectionStyleNone;
	
	switch (indexPath.section) {
			cell.selectionStyle=UITableViewCellSelectionStyleGray;
		case 0:
			cell.textLabel.textColor=[UIColor darkGrayColor];
			cell.textLabel.font=[UIFont systemFontOfSize:14];
			cell.textLabel.text=@"";
			
			//if([titleView superview])
			//	[titleView removeFromSuperview];
			[cell.contentView addSubview:titleView];
			//[titleView release];

			break;
		case 1:
			cell.textLabel.text=NSLocalizedString(@"typeStrText", @"")/*typeStrText*/;//@"Type";
			cell.textLabel.font=[UIFont systemFontOfSize:14];
			cell.textLabel.textColor=[UIColor darkGrayColor];
			
			//if([taskButton superview])
			//	[taskButton removeFromSuperview];
			[cell.contentView addSubview:taskButton];
			//[taskButton release];
			
			//if([eventButton superview])
			//	[eventButton removeFromSuperview];
				[cell.contentView addSubview:eventButton];
			//[eventButton release];
			
			break;
		case 2:{
			//create buttons for Context criteria
			cell.textLabel.text=NSLocalizedString(@"contextText", @"Context")/*contextText*/;//@"Context";
			cell.textLabel.textColor=[UIColor darkGrayColor];
			cell.textLabel.font=[UIFont systemFontOfSize:14];

			//if([deskButton superview])
			//	[deskButton removeFromSuperview];
			[cell.contentView addSubview:deskButton];
			//[deskButton release];
			
			//if([homeButton superview])
			//	[homeButton removeFromSuperview];
			[cell.contentView addSubview:homeButton];
			//[homeButton release];
			break;
		}
		case 3:{
			
			[cell.contentView addSubview:projectViewController.view];
			
			/*
			
			cell.textLabel.text=@"";
			//if([noneButton superview])
			//	[noneButton removeFromSuperview];
			[cell.contentView addSubview:noneButton];
			//[noneButton release];
			
			//if([urgentButton superview])
			//	[urgentButton removeFromSuperview];
			[cell.contentView addSubview:urgentButton];
			//[urgentButton release];
			
			//if([privateButton superview])
			//	[privateButton removeFromSuperview];
			[cell.contentView addSubview:privateButton];
			//[privateButton release];
			
			//if([projectAButton superview])
			//	[projectAButton removeFromSuperview];
			[cell.contentView addSubview:projectAButton];
			//[projectAButton release];
			
			//if([projectBButton superview])
			//	[projectBButton removeFromSuperview];
			[cell.contentView addSubview:projectBButton];
			//[projectBButton release];
			
			//if([projectCButton superview])
			//	[projectCButton removeFromSuperview];
			[cell.contentView addSubview:projectCButton];
			//[projectCButton release];
			
			//if([project7Button superview])
			//	[project7Button removeFromSuperview];
			[cell.contentView addSubview:project7Button];
			//[project7Button release];
			
			//if([project8Button superview])
			//	[project8Button removeFromSuperview];
			[cell.contentView addSubview:project8Button];
			//[project8Button release];
			
			//if([project9Button superview])
			//	[project9Button removeFromSuperview];
			[cell.contentView addSubview:project9Button];
			//[project9Button release];
			
			//if([project10Button superview])
			//	[project10Button removeFromSuperview];
			[cell.contentView addSubview:project10Button];
			//[project10Button release];
			
			//if([project11Button superview])
			//	[project11Button removeFromSuperview];
			[cell.contentView addSubview:project11Button];
			//[project11Button release];
			
			//if([project12Button superview])
			//	[project12Button removeFromSuperview];
			[cell.contentView addSubview:project12Button];
			//[project12Button release];
			*/
			
			break;
		}
	}
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.section==3){
		return self.frame.size.height-240;
	}else if (indexPath.section==0){
		return 30;
	}

	return 40;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	if(section==3){
		return 25;
	}else if(section==0){
		return 8;
	}
	return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

	return 4;
}


- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	[table deselectRowAtIndexPath:newIndexPath animated:YES];
	[titleView resignFirstResponder];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	return UITableViewCellEditingStyleNone;	
}

/*
- (void)textViewDidEndEditing:(UITextView *)textView{
	if(titleView.text !=nil && ![titleView.text isEqualToString:@""]){
		self.titleCriterionClause=[[@"and Task_Name LIKE '%" stringByAppendingString:titleView.text]  stringByAppendingString:@"%' "];
	}else {
		self.titleCriterionClause=@"and Task_Name LIKE '%' ";
	}
	[self resetQueryInfo];

}
*/

#pragma mark action methods

-(void)applyFilter:(id)sender{
	//printf("\nquery filter: %s",[self.queryClause UTF8String]);
	
	NSString *title=titleView.text;
	//format: taskTitle|Task|Event|Work|Home|ProJ0|ProJ2|ProJ2|ProJ3|ProJ4|ProJ5
//	queryClauseWithFormat=[NSString stringWithFormat:@"%@|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d",title?title:@"",taskButton.selected?0:-1,eventButton.selected?1:-1,
//						   deskButton.selected?1:-1,homeButton.selected?0:-1,noneButton.selected?0:-1,urgentButton.selected?1:-1,
//						   privateButton.selected?2:-1,projectAButton.selected?3:-1,projectBButton.selected?4:-1,projectCButton.selected?5:-1,
//						   project7Button.selected?6:-1,project8Button.selected?7:-1,project9Button.selected?8:-1,project10Button.selected?9:-1,
//						   project11Button.selected?10:-1,project12Button.selected?11:-1];
	
	
	queryClauseWithFormat=[NSString stringWithFormat:@"%@|%d|%d|%d|%d",title?title:@"",taskButton.selected?0:-1,eventButton.selected?1:-1,
						   deskButton.selected?1:-1,homeButton.selected?0:-1];
	[self.rootView applyFilter:queryClauseWithFormat doTodayClause:queryClauseWithFormat];
	
	//[self.rootView applyFilter:self.queryClause doTodayClause:self.queryDoTodayClause];
}

/*
-(void)cancelFilter:(id)sender{
	[self.rootView filterTask:sender];
}
*/

-(void)taskCriterion:(id)sender{
	[self toggleButtonState:taskButton];
}

-(void)eventCriterion:(id)sender{
	[self toggleButtonState:eventButton];
}

-(void)deskCriterion:(id)sender{
	
	[self toggleButtonState:deskButton];
}

-(void)homeCriterion:(id)sender{
	[self toggleButtonState:homeButton];
}

/*
-(void)noneCriterion:(id)sender{
	[self toggleButtonState:noneButton];
}

-(void)urgentCriterion:(id)sender{
	[self toggleButtonState:urgentButton];
}

-(void)privateCriterion:(id)sender{
	[self toggleButtonState:privateButton];
}

-(void)projectACriterion:(id)sender{

	[self toggleButtonState:projectAButton];
}

-(void)projectBCriterion:(id)sender{
	[self toggleButtonState:projectBButton];
}

-(void)projectCCriterion:(id)sender{
	[self toggleButtonState:projectCButton];
}

//
-(void)project7Criterion:(id)sender{
	
	[self toggleButtonState:project7Button];
}

-(void)project8Criterion:(id)sender{
	[self toggleButtonState:project8Button];
}

-(void)project9Criterion:(id)sender{
	[self toggleButtonState:project9Button];
}

-(void)project10Criterion:(id)sender{
	
	[self toggleButtonState:project10Button];
}

-(void)project11Criterion:(id)sender{
	[self toggleButtonState:project11Button];
}

-(void)project12Criterion:(id)sender{
	[self toggleButtonState:project12Button];
}
*/
#pragma mark common methods

- (UIButton *)buttonWithTitle:	(NSString *)title
					   target:(id)target
					 selector:(SEL)selector
						frame:(CGRect)frame
						image:(NSString *)image
				 imagePressed:(NSString *)imagePressed
				darkTextColor:(BOOL)darkTextColor
{	
	//ILOG(@"[SmartViewController buttonWithTitle\n");
	UIButton *button = [[UIButton alloc] initWithFrame:frame];
	// or you can do this:
	//		UIButton *button = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	//		button.frame = frame;
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	[button setTitle:title forState:UIControlStateNormal];	
	
	if (darkTextColor)
	{
		[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	else
	{
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}
	
	if(image !=nil){
		UIImage *newImage = [[UIImage imageNamed:image] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		[button setBackgroundImage:newImage forState:UIControlStateNormal];
	}
	
	if(imagePressed !=nil){
    	UIImage *newPressedImage = [[UIImage imageNamed:imagePressed] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		[button setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
	}
	
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	
    // in case the parent view draws with a custom color or gradient, use a transparent color
	button.backgroundColor = [UIColor clearColor];
	//ILOG(@"SmartViewController buttonWithTitle]\n");
	return button;
}

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
	button.titleLabel.font=[UIFont systemFontOfSize:14];
	
	[button setTitleColor:normalStateTextColor forState:UIControlStateNormal];
	[button setTitleColor:selectedStateTextColor forState:UIControlStateSelected];

	//button.backgroundColor = [UIColor clearColor];
	[button setBackgroundImage:[[UIImage imageNamed:@"no-mash-white.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
	[button setBackgroundImage:[[UIImage imageNamed:@"no-mash-blue.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateSelected];
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	
	return button;
}

-(void)toggleButtonState:(UIButton *)button{ 
	if(button.selected){
		button.selected=NO;
	}else {
		button.selected=YES;
	}	
	[titleView resignFirstResponder];
}



#pragma mark TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return YES;	
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
	/*
	if(textField.text !=nil && ![textField.text isEqualToString:@""]){
		self.titleCriterionClause=[[@"and Task_Name LIKE '%" stringByAppendingString:titleView.text]  stringByAppendingString:@"%' "];
	}else {
		self.titleCriterionClause=@"and Task_Name LIKE '%' ";
	}
	[self resetQueryInfo];	
	 */
}
@end
