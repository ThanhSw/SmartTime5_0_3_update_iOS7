//
//  ProductPageViewController.m
//  SmartTime
//
//  Created by Nang Le on 6/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ProductPageViewController.h"
#import "IvoCommon.h"

@implementation ProductPageViewController
@synthesize backgroundImgView;
@synthesize introductionLb;
@synthesize keyDisplay;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	self.navigationItem.title=@"Products by LCL";
	backgroundImgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 462)];
	
	introductionLb=[[UILabel alloc] initWithFrame:CGRectMake(10, 200, 300, 250)];
	introductionLb.backgroundColor=[UIColor clearColor];
	introductionLb.font=[UIFont systemFontOfSize:15];
	introductionLb.textAlignment=UITextAlignmentCenter;
	introductionLb.numberOfLines=0;
	
	[backgroundImgView addSubview:introductionLb];
	[introductionLb release];
	
	self.view=backgroundImgView;
	[backgroundImgView release];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(void)viewWillAppear:(BOOL)animated{
	introductionLb.textColor=[UIColor whiteColor];
	
	switch (keyDisplay) {
		case 0://ST
			introductionLb.frame=CGRectMake(10, 170, 300, 250);
			backgroundImgView.image=[UIImage imageNamed:@"ST_iphonepage_blank.png"];
			introductionLb.text=NSLocalizedString(@"STText", @"")/*STText*/;
			introductionLb.textColor=[UIColor darkGrayColor];
			break;
		case 1://STu
			introductionLb.frame=CGRectMake(10, 235, 300, 250);
			backgroundImgView.image=[UIImage imageNamed:@"STu_iphonepage_blank.png"];
			introductionLb.text=NSLocalizedString(@"STuText", @"")/*STuText*/;
			break;
		case 2://S2Q
			introductionLb.frame=CGRectMake(10, 200, 300, 250);
			backgroundImgView.image=[UIImage imageNamed:@"shoot2quill_iphonepage_blank.png"];
			introductionLb.text=NSLocalizedString(@"S2QText", @"")/*S2QText*/;
			break;
		case 3://FF
			introductionLb.frame=CGRectMake(10, 250, 300, 250);
			backgroundImgView.image=[UIImage imageNamed:@"FF-iphonepage_blank.png"];
			introductionLb.text=NSLocalizedString(@"FFText", @"")/*FFText*/;
			break;
		default:
			break;
	}
	
	[introductionLb sizeToFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
