//
//  TableCellWhatTextTap.h
//  SmartTime
//
//  Created by Nang Le on 10/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableCellWhatTextTap : UITableViewCell {
	UILabel *instruction;
	UIView  *buttonView;
	UITextField *editText;
}

@property (nonatomic,retain) UILabel *instruction;
@property (nonatomic,retain) UIView  *buttonView;
@property (nonatomic,retain) UITextField *editText;

@end
