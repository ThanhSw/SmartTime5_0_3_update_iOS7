//
//  TableCellSettingContext.h
//  SmartTime
//
//  Created by Nang Le on 10/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableCellSettingContext : UITableViewCell {
	UILabel	*contextName;
	UILabel	*weekDayValue;
	UILabel	*weekEndValue;
	UIImageView *imageView;
	UILabel *weekDayName;
	UILabel *weekEndName;
}

@property (nonatomic,retain) UILabel		*contextName;
@property (nonatomic,retain) UILabel		*weekDayValue;
@property (nonatomic,retain) UILabel		*weekEndValue;
@property (nonatomic,retain) UIImageView	*imageView;

@end
