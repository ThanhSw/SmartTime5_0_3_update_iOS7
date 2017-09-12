//
//  TableCellTaskDetailButton.h
//  SmartTime
//
//  Created by Nang Le on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableCellTaskDetailButton : UITableViewCell {
	UILabel *cellName;
	UILabel *cellValue;
	UILabel *cellValue2;
	UIView  *buttonView;
	UIButton *editButton;
	UILabel *cellName2;
}

@property (nonatomic,retain) UILabel *cellName;
@property (nonatomic,retain) UILabel *cellName2;
@property (nonatomic,retain) UILabel *cellValue;
@property (nonatomic,retain) UIView  *buttonView;
@property (nonatomic,retain) UIButton *editButton;
@property (nonatomic,retain) UILabel *cellValue2;

@end
