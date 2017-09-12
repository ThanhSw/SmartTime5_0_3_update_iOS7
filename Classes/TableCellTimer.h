//
//  TableCellTimer.h
//  SmartTime
//
//  Created by Nang Le on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableCellTimer : UITableViewCell {
	UILabel *cellValue;
	UIButton *button;
}

@property (nonatomic, retain) UILabel *cellValue;
@property (nonatomic, retain) UIButton *button;

@end
