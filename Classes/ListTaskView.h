//
//  QuickTaskView.h
//  IVo
//
//  Created by Nang Le on 6/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SmartViewController;

@interface ListTaskView : UIView <UITableViewDelegate, UITableViewDataSource> {
	UITableView *tableViewDo;
	UITableView *tableViewDone;
	
	UILabel		*doToday;
	UILabel		*doneToday;
	UIView		*doneView;
	UIView		*doView;
	
	UIButton	*doneButton;
	
	NSInteger pathIndex;
	BOOL isSwipe;
	BOOL isDoViewSelected;
	
	SmartViewController *rootViewController;
	UIButton *editButon;
	UIButton *showHideDoneTodayButton;
	UILabel *cellTextVal;
	
	NSString *filterCaluse;
	NSInteger restoreIndex;
}
@property (nonatomic, retain) SmartViewController *rootViewController;
@property (nonatomic, assign) NSInteger pathIndex;
@property (nonatomic, assign) BOOL isSwipe;
@property (nonatomic, assign) BOOL isDoViewSelected;
@property (nonatomic, retain) UILabel *cellTextVal;
@property (nonatomic, assign) NSInteger restoreIndex;
@property (nonatomic, copy) NSString *filterCaluse;

-(void)showHideDoneTodayAct:(BOOL)isShowDone;
-(void) refreshData;
-(void)deselectedCell;

@end
