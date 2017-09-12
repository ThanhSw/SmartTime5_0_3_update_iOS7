//
//  ProductTableViewCell.m
//  MugShotz
//
//  Created by Nang Le on 5/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ProductTableViewCell.h"


@implementation ProductTableViewCell
/*
@synthesize header;
@synthesize shadowHeader;
@synthesize body;
@synthesize shadowBody;
@synthesize footer;
@synthesize shadowFooter;
@synthesize iconImageView;
@synthesize detailDescription;
@synthesize price;
*/

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		UIView *separator=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.25)];
		separator.backgroundColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
		[self.contentView addSubview:separator];
		[separator release];		

		shadowHeader=[[UILabel alloc] initWithFrame:CGRectMake(77, 10.25, 290-77, 14)];
		shadowHeader.font=[UIFont boldSystemFontOfSize:12];
		shadowHeader.textColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
		shadowHeader.backgroundColor=[UIColor clearColor];
		[self.contentView addSubview:shadowHeader];
		[shadowHeader release];
		
		header=[[UILabel alloc] initWithFrame:CGRectMake(77, 10, 290-77, 14)];
		header.font=[UIFont boldSystemFontOfSize:12];
		header.textColor=[UIColor darkGrayColor];
		header.backgroundColor=[UIColor clearColor];
		header.highlightedTextColor=[UIColor whiteColor];
		[self.contentView addSubview:header];
		[header release];

		shadowBody=[[UILabel alloc] initWithFrame:CGRectMake(77, 24.5, 290-77, 26)];
		shadowBody.font=[UIFont boldSystemFontOfSize:22];
		shadowBody.adjustsFontSizeToFitWidth=YES;
		shadowBody.textColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
		shadowBody.backgroundColor=[UIColor clearColor];
		[self.contentView addSubview:shadowBody];
		[shadowBody release];
		
		body=[[UILabel alloc] initWithFrame:CGRectMake(77, 24, 290-77, 26)];
		body.font=[UIFont boldSystemFontOfSize:22];
		body.textColor=[UIColor blackColor];
		body.adjustsFontSizeToFitWidth=YES;
		body.backgroundColor=[UIColor clearColor];
		body.highlightedTextColor=[UIColor whiteColor];
		[self.contentView addSubview:body];
		[body release];
		
		price=[[UILabel alloc] initWithFrame:CGRectMake(320-80, 24, 70, 26)];
		price.font=[UIFont boldSystemFontOfSize:22];
		price.textColor=[UIColor blackColor];
		price.backgroundColor=[UIColor clearColor];
		price.highlightedTextColor=[UIColor whiteColor];
		price.textAlignment = NSTextAlignmentRight;
		[self.contentView addSubview:price];
		[price release];		

		shadowFooter=[[UILabel alloc] initWithFrame:CGRectMake(77, 50.25, 320-77, 35)];
		shadowFooter.font=[UIFont italicSystemFontOfSize:12];
		shadowFooter.textColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
		shadowFooter.backgroundColor=[UIColor clearColor];
		shadowFooter.numberOfLines=0;
		[self.contentView addSubview:shadowFooter];
		[shadowFooter release];
		
		footer=[[UILabel alloc] initWithFrame:CGRectMake(77, 50, 320-77, 35)];
		footer.font=[UIFont italicSystemFontOfSize:12];
		footer.textColor=[UIColor darkGrayColor];
		footer.highlightedTextColor=[UIColor whiteColor];
		footer.backgroundColor=[UIColor clearColor];
		footer.numberOfLines=0;
		//footer.minimumFontSize=10;
		//footer.adjustsFontSizeToFitWidth=YES;
		[self.contentView addSubview:footer];
		[footer release];
				
		iconImageView=[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 57, 57)];
		[self.contentView addSubview:iconImageView];
		[iconImageView release];
		
		detailDescription=[[UILabel alloc] initWithFrame:CGRectMake(10, 70, 320-20, 300 - 70)];
		detailDescription.font=[UIFont fontWithName:@"Helvetica" size:14];
		detailDescription.textColor=[UIColor blackColor];
		detailDescription.highlightedTextColor=[UIColor whiteColor];
		detailDescription.backgroundColor=[UIColor clearColor];
		detailDescription.numberOfLines = 15;
		[self.contentView addSubview:detailDescription];
		[detailDescription release];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setHeaderText:(NSString *)text
{
	//self.header.text = text;
	//self.shadowHeader.text = text;
	
	header.text = text;
	shadowHeader.text = text;	
}

-(void)setBodyText:(NSString *)text
{
	//self.body.text = text;
	//self.shadowBody.text = text;
	
	body.text = text;
	shadowBody.text = text;
}

-(void)setFooterText:(NSString *)text
{
	//self.footer.text = text;
	//self.shadowFooter.text = text;
	footer.frame= CGRectMake(77, 50, 320-77, 35);
	shadowFooter.frame= CGRectMake(77, 50, 320-77, 35);
	footer.text = text;
	shadowFooter.text = text;
	[shadowFooter sizeToFit];
	[footer sizeToFit];
}

-(void)setDetailDescriptionText: (NSString *)text withHeight:(CGFloat) height
{
	//self.detailDescription.text = text;
	detailDescription.text = text;
	CGRect frm = detailDescription.frame;
	frm.size.height = height - 70;
	
	detailDescription.frame = frm;
}

-(void)setPriceText: (NSString *)text
{
	//self.price.text = text;
	price.text = text;
}

-(void)setImage: (UIImage *)img
{
	iconImageView.image = img;
}

- (void)dealloc {
/*	NSArray *subViews=[self.contentView subviews];
	for(UIView *view in subViews){
		[view removeFromSuperview];
	}
*/	
	iconImageView=nil;
    [super dealloc];
}


@end
