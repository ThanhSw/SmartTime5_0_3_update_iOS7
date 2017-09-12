//
//  TableCellSettingAutoBump.h
//  SmartTime
//
//  Created by Nang Le on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableCellSettingAutoBump : UITableViewCell {
	UILabel *bumpName;
	UILabel *notes;
	UISwitch *switchControl;
	UIButton *button;	
}

@property (nonatomic,retain) UILabel *bumpName;
@property (nonatomic,retain) UILabel *notes;
@property (nonatomic,retain) UISwitch *switchControl;
@property (nonatomic,retain) UIButton *button;
@end
