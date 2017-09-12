//
//  ProductTableViewCell.h
//  MugShotz
//
//  Created by Nang Le on 5/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProductTableViewCell : UITableViewCell {
	UILabel	*header;
	UILabel	*shadowHeader;
	
	UILabel	*body;
	UILabel	*shadowBody;
	
	UILabel	*footer;
	UILabel	*shadowFooter;
	
	UIImageView	*iconImageView;

	UILabel *detailDescription;
	UILabel *price;
}

/*
@property(nonatomic,retain) UILabel	*header;
@property(nonatomic,retain) UILabel	*shadowHeader;
@property(nonatomic,retain) UILabel	*body;
@property(nonatomic,retain) UILabel	*shadowBody;
@property(nonatomic,retain) UILabel	*footer;
@property(nonatomic,retain) UILabel	*shadowFooter;

@property(nonatomic,retain) UIImageView	*iconImageView;
@property(nonatomic,retain)	UILabel *detailDescription;
@property(nonatomic,retain)	UILabel *price;
*/

-(void)setHeaderText:(NSString *)text;
-(void)setBodyText:(NSString *)text;
-(void)setFooterText:(NSString *)text;
-(void)setDetailDescriptionText: (NSString *)text withHeight:(CGFloat) height;
-(void)setPriceText: (NSString *)text;
-(void)setImage: (UIImage *)img;

@end
