//
//  LCLAdsView.m
//  SmartTime
//
//  Created by Nang Le on 6/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LCLAdsView.h"
#import "Setting.h"
#import "TaskManager.h"
#import "IvoCommon.h"
#import "ProductPageViewController.h"

extern TaskManager *taskmanager;

@implementation LCLAdsView
@synthesize icon;
@synthesize introLb;
@synthesize keyDisplay;
@synthesize descriptLb;
@synthesize backgroundImg;
@synthesize rootViewController;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		backgroundImg=[[UIButton buttonWithType:UIButtonTypeCustom] retain]; 
		backgroundImg.frame=CGRectMake(0, 0, frame.size.width, frame.size.height); 
		
		[backgroundImg addTarget:self 
						  action:@selector(showProduct:) 
				forControlEvents:UIControlEventTouchUpInside];
		
		if(taskmanager.currentSetting.iVoStyleID==0){//blue
			[backgroundImg setBackgroundImage:[UIImage imageNamed:@"LCLAdsBlue.png"] forState:UIControlStateNormal];
		}else {//black
			[backgroundImg setBackgroundImage:[UIImage imageNamed:@"LCLAdsBlack.png"] forState:UIControlStateNormal];
		}
		
		[self addSubview:backgroundImg];
		[backgroundImg release];
		
		icon=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 38, 38)];
		icon.image=[UIImage imageNamed:@"STIcon.png"];
		[self addSubview:icon];
		[icon release];
		
		introLb=[[UILabel alloc] initWithFrame:CGRectMake(48, 5, frame.size.width-48-10, frame.size.height/2)];
		introLb.font=[UIFont boldSystemFontOfSize:15];
		introLb.backgroundColor=[UIColor clearColor];
		introLb.textColor=[UIColor whiteColor];
		introLb.text=@"SmartTime+";
		[self addSubview:introLb];
		[introLb release];
		
		descriptLb=[[UILabel alloc] initWithFrame:CGRectMake(48, frame.size.height/2, frame.size.width-48-10, frame.size.height/2)];
		descriptLb.backgroundColor=[UIColor clearColor];
		descriptLb.font=[UIFont italicSystemFontOfSize:13];
		descriptLb.textAlignment=UITextAlignmentRight;
		descriptLb.textColor=[UIColor whiteColor];
		descriptLb.text=@"\"Finally, an organizer with a brain\"";

		[self addSubview:descriptLb];
		[descriptLb release];
		
		keyDisplay=1;
		changeAdvertTmr=[NSTimer scheduledTimerWithTimeInterval:AD_REFRESH_PERIOD target:self
													   selector:@selector(flipAdvert:)
													   userInfo:nil
														repeats:YES];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	// Drawing code	
}


- (void)dealloc {
	if([changeAdvertTmr isValid]){
		[changeAdvertTmr invalidate];
		changeAdvertTmr=nil;
	}
    [super dealloc];
}

-(void)flipAdvert:(id)sender{
	
	//if(taskmanager.currentSetting.iVoStyleID==0){//blue
	//	backgroundImg.image=[UIImage imageNamed:@"LCLAdsBlue.png"];
	//}else {//black
	//	backgroundImg.image=[UIImage imageNamed:@"LCLAdsBlack.png"];
	//}
	
	if(taskmanager.currentSetting.iVoStyleID==0){//blue
		[backgroundImg setBackgroundImage:[UIImage imageNamed:@"LCLAdsBlue.png"] forState:UIControlStateNormal];
	}else {//black
		[backgroundImg setBackgroundImage:[UIImage imageNamed:@"LCLAdsBlack.png"] forState:UIControlStateNormal];
	}
	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:animationIDfinished:finished:context:)];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.75];
	
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self cache:NO];

	switch (keyDisplay) {
		case 0://SmartTime
		{
			introLb.text=@"SmartTime+";
			descriptLb.text=@"\"Finally, an organizer with a brain\"";
			icon.image=[UIImage imageNamed:@"STIcon.png"];
		}
			break;
		case 1://SmartTunes
		{
			introLb.text=@"SmartTunes";
			descriptLb.text=@"\"Over 100 stations to wake up or sleep to...\"";
			icon.image=[UIImage imageNamed:@"WT_icon.png"];
		}
			
			break;
		case 2://S2Q
		{
			introLb.text=@"Shoot2Quill";
			descriptLb.text=@"\"Improve your texting, save the World\"";
			icon.image=[UIImage imageNamed:@"S2Qicon.png"];
		}
			
			break;
		case 3://FF
		{
			introLb.text=@"FunnyFace";
			descriptLb.text=@"\"Fotographic Fun\"";
			icon.image=[UIImage imageNamed:@"FFicon.png"];
		}
			
			break;
		case 4://Qamera
		{
			introLb.text=@"Qamera";
			descriptLb.text=@"\"See the world\"";
			icon.image=[UIImage imageNamed:@"Qicon.png"];
		}
			
			break;
		default:
		{
			introLb.text=@"SmartTime+";
			descriptLb.text=@"\"Finally, an organizer with a brain\"";
			icon.image=[UIImage imageNamed:@"STIcon.png"];
		}
			break;
	}
	
	if(keyDisplay==3){
		keyDisplay=0;
	}else {
		keyDisplay+=1;
	}

	
	[UIView commitAnimations];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	
}

-(void)showProduct:(id)sender{
	ProductPageViewController *viewController=[[ProductPageViewController alloc] init];
	if(keyDisplay==0){
		viewController.keyDisplay=3;
	}else {
		viewController.keyDisplay=keyDisplay-1;
	}
	
	[[self.rootViewController navigationController] pushViewController:viewController animated:YES];
	[viewController release];
}

/*
- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event{
	for(UITouch *touch in touches){
		CGPoint loc=[touch locationInView:self];
		if(CGRectContainsPoint(self.frame, loc)){
			switch (keyDisplay) {
				case 0://ST
				{
					NSString *bodyStr = [NSString stringWithFormat:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=295845767&mt=8"];
					NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
					NSURL *url = [[NSURL alloc] initWithString:encoded];
					
					[[UIApplication sharedApplication] openURL:url];
					
					[url release];
				}
					break;
				case 1://CR
				{
					NSString *bodyStr = [NSString stringWithFormat:@"http://www.leftcoastlogic.com/products/"];
					NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
					NSURL *url = [[NSURL alloc] initWithString:encoded];
					
					[[UIApplication sharedApplication] openURL:url];
					
					[url release];
				}
					break;
				case 2://S2Q
				{
					NSString *bodyStr = [NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=317937073&mt=8"];
					NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
					NSURL *url = [[NSURL alloc] initWithString:encoded];
					
					[[UIApplication sharedApplication] openURL:url];
					
					[url release];
					
				}
					break;
				case 3://FF
				{
					NSString *bodyStr = [NSString stringWithFormat:@"http://www.leftcoastlogic.com/products/"];
					NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
					NSURL *url = [[NSURL alloc] initWithString:encoded];
					
					[[UIApplication sharedApplication] openURL:url];
					
					[url release];
				}
					break;
				case 4://iQ
				{
					NSString *bodyStr = [NSString stringWithFormat:@"http://www.leftcoastlogic.com/products/"];
					NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
					NSURL *url = [[NSURL alloc] initWithString:encoded];
					
					[[UIApplication sharedApplication] openURL:url];
					
					[url release];
				}
					break;
			}
			
		}
	}
}
*/
@end
