//
//  WeekDaySettingViewController.h
//  SmartTime
//
//  Created by NangLe on 1/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WeekDaySettingViewController : UITableViewController {
	id editedObject;
	NSMutableArray *workDayStartOptionList;
	NSMutableArray *workDayEndOptionList;
}

@property(nonatomic,retain) id editedObject;

@end
