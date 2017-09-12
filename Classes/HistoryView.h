//
//  HistoryView.h
//  iVo
//
//  Created by Nang Le on 7/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HistoryView : UIView <UITableViewDelegate, UITableViewDataSource>  {
	UITableView			*historyTableView;
	NSMutableArray		*fullCompletedTasksList;
	
	NSArray				*displayList;
	NSArray				*indexLetters;
	BOOL				isSwipe;
}

//@property (nonatomic, retain)	UITableView		*historyTableView;
@property (nonatomic, retain)	NSArray			*displayList;
@property (nonatomic, retain)	NSMutableArray	*fullCompletedTasksList;
@property (nonatomic, retain)	NSArray			*indexLetters;
@property (nonatomic, assign)	BOOL			isSwipe;
- (void)setUpDisplayList;


@end
