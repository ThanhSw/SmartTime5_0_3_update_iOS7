//
//  FilterView.h
//  iVoProtoTypes
//
//  Created by Nang Le on 6/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SmartViewController;
@class ProjectViewController;
@interface FilterView : UIView <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
	UITableView		*tableView;
	UITextField		*titleView;

	UIButton		*deskButton;
	UIButton		*homeButton;
	
	/*
	UIButton		*urgentButton;
	UIButton		*privateButton;
	
	
	UIButton		*noneButton;
	UIButton		*projectAButton;
	UIButton		*projectBButton;
	UIButton		*projectCButton;
	
	UIButton		*project7Button;
	UIButton		*project8Button;
	UIButton		*project9Button;
	UIButton		*project10Button;
	UIButton		*project11Button;
	UIButton		*project12Button;
	*/
	UIButton		*eventButton;
	UIButton		*taskButton;
	
	NSString		*queryClauseWithFormat;
	
	SmartViewController *rootView;
	ProjectViewController *projectViewController;
}
@property (nonatomic,retain) SmartViewController	*rootView;

- (UIButton *)buttonWithTitle:	(NSString *)title
					   target:(id)target
					 selector:(SEL)selector
						frame:(CGRect)frame
						image:(NSString *)image
				 imagePressed:(NSString *)imagePressed
				darkTextColor:(BOOL)darkTextColor;

- (UIButton *)getButton:(NSString *)title 
			 buttonType:(UIButtonType)buttonType
				  frame:(CGRect)frame
				 target:(id)target
			   selector:(SEL)selector
   normalStateTextColor:(UIColor *)normalStateTextColor
 selectedStateTextColor:(UIColor *)selectedStateTextColor;


-(void)toggleButtonState:(UIButton *)button;

@end
