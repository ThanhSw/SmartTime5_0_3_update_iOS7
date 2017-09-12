//
//  TableCellFocus.h
//  SmartTime
//
//  Created by Nang Le on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableCellFocus : UITableViewCell {
	UILabel *taskName;
	UILabel *startTime;
	UIImageView *leftImgView;
	UIButton *rightButton;
}

@property (nonatomic,retain) UILabel *taskName;
@property (nonatomic,retain) UILabel *startTime;
@property (nonatomic,retain) UIImageView *leftImgView;
@property (nonatomic,retain) UIButton *rightButton;
@end
