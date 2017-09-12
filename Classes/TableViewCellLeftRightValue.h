//
//  TableViewCellLeftRightValue.h
//  SmartTime
//
//  Created by NangLe on 10/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableViewCellLeftRightValue : UITableViewCell {
	UILabel	*leftLabel;
	UILabel	*rightLabel;
}

@property (nonatomic,retain) UILabel	*leftLabel;
@property (nonatomic,retain) UILabel	*rightLabel;

@end
