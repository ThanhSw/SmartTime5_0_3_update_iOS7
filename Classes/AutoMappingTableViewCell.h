//
//  AutoMappingTableViewCell.h
//  SmartTime
//
//  Created by Huy Le on 8/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AutoMappingTableViewCell : UITableViewCell {
	UILabel *projectLabel;
	UILabel *gcalLabel;

}

@property (nonatomic, retain) 	UILabel *projectLabel;
@property (nonatomic, retain) 	UILabel *gcalLabel;

@end
