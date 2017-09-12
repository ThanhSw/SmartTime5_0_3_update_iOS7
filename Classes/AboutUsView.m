//
//  aboutUsView.m
//  iVo
//
//  Created by Nang Le on 8/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AboutUsView.h"
#import "IvoCommon.h"

//extern NSString *WeekDay[];

@implementation AboutUsView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		// Initialization code
	/*	
		UIImageView *smartTimeLogo=[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
		smartTimeLogo.image=[UIImage imageNamed:@"Icon.png"];
		[self addSubview:smartTimeLogo];
		[smartTimeLogo release];
		
		appName=[[UILabel alloc] initWithFrame:CGRectMake(80, 10, 200, 35)];
		appName.text=@"SmartTime";
		appName.font=[UIFont systemFontOfSize:40];
		appName.backgroundColor=[UIColor clearColor];
		[self addSubview:appName];
		
		appVersion=[[UILabel alloc] initWithFrame:CGRectMake(80, 45, 230, 25)];
		appVersion.text=@"Version 1.1 build 08101502";//yymmdd<rev#>
		appVersion.font=[UIFont systemFontOfSize:16];
		appVersion.backgroundColor=[UIColor clearColor];
		[self addSubview:appVersion];
		
		contactTitle=[[UILabel alloc] initWithFrame:CGRectMake(10, 80, 300, 20)];
		contactTitle.text=@"Contacts";
		contactTitle.font=[UIFont systemFontOfSize:20];
		contactTitle.backgroundColor=[UIColor clearColor];
		[self addSubview:contactTitle];
		
		contactContents=[[UILabel alloc] initWithFrame:CGRectMake(20, 100, 280, 60)];
		contactContents.numberOfLines=0;
		contactContents.text=@"Web-Site	      www.leftcoastlogic.com \nUser Guide   www.leftcoastlogic.com/guide/ \nUser Forum  www.leftcoastlogic.com/forum/";
		contactContents.font=[UIFont systemFontOfSize:14];
		contactContents.backgroundColor=[UIColor clearColor];
		[self addSubview:contactContents];
		
		acknowlegmentTitle=[[UILabel alloc] initWithFrame:CGRectMake(10, 165, 300, 25)];
		acknowlegmentTitle.text=@"Acknowledgements";
		acknowlegmentTitle.font=[UIFont systemFontOfSize:20];
		acknowlegmentTitle.backgroundColor=[UIColor clearColor];
		[self addSubview:acknowlegmentTitle];
		
		acknowlegmentContents=[[UILabel alloc] initWithFrame:CGRectMake(20, 190, 280, 130)];
		acknowlegmentContents.numberOfLines=0;
		acknowlegmentContents.text=@"Huy, Nang, Trung – and Truc the incredible cook.  Leon in Singapore; Michael, Eric and Chris in Cupertino; AZT Design and Arika Law Office in Vietnam; a special friend in Manchester; the Red Team in Seattle.\n\n      - Michael (Seattle) and James (Lucerne)";  
		acknowlegmentContents.font=[UIFont systemFontOfSize:14];
		acknowlegmentContents.textAlignment=NSTextAlignmentLeft;
		acknowlegmentContents.backgroundColor=[UIColor clearColor];
		[self addSubview:acknowlegmentContents];
		
		copyrightContent=[[UILabel alloc] initWithFrame:CGRectMake(10, 325, 300, 40)];
		copyrightContent.numberOfLines=0;
		copyrightContent.text=@"SmartTime and the logo            are copyright\n2008 Left Coast Logic LLC, patents pending.";  
		copyrightContent.font=[UIFont systemFontOfSize:15];
		copyrightContent.textAlignment=NSTextAlignmentCenter;
		copyrightContent.backgroundColor=[UIColor clearColor];
		[self addSubview:copyrightContent];
		
		UIImageView *smartTimeSmallLogo=[[UIImageView alloc] initWithFrame:CGRectMake(185, 320, 25, 25)];
		smartTimeSmallLogo.image=[UIImage imageNamed:@"Icon.png"];
		[self addSubview:smartTimeSmallLogo];
		[smartTimeSmallLogo release];	
	 */
        CGRect frame=[[UIScreen mainScreen] bounds];
        
		self.backgroundColor=[UIColor viewFlipsideBackgroundColor];
		
		UIImageView *aboutUSImgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"STAboutUs.png"]];
		aboutUSImgView.frame=CGRectMake(0, 0, 320, frame.size.height-65);
		[self addSubview:aboutUSImgView];
		[aboutUSImgView release];
		
		UILabel *appNameLb=[[UILabel alloc] initWithFrame:CGRectMake(10+25, 206, 300-25, 20)];
		appNameLb.font=[UIFont systemFontOfSize:16];
		appNameLb.numberOfLines=1;
		appNameLb.backgroundColor=[UIColor clearColor];
		appNameLb.textColor=[UIColor darkGrayColor];

#ifdef FREE_VERSION
		appNameLb.text=[NSString stringWithFormat:@"SmartTime Free"];
#else
#ifdef ST_BASIC
		appNameLb.text=[NSString stringWithFormat:@"SmartTime Tasks"];
#else			
		appNameLb.text=[NSString stringWithFormat:@"SmartTime Pro"];
#endif
#endif
		[appNameLb sizeToFit];
		[self addSubview:appNameLb];
		[appNameLb release];
		
		UILabel *productionInfoLB=[[UILabel alloc] initWithFrame:CGRectMake(10+25, 227, 300-25, 18)];
		productionInfoLB.font=[UIFont systemFontOfSize:16];
		productionInfoLB.backgroundColor=[UIColor clearColor];
		productionInfoLB.textColor=[UIColor darkGrayColor];
		productionInfoLB.text=[NSString stringWithFormat:@"Version %@ build %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
		[self addSubview:productionInfoLB];
		[productionInfoLB release];
		
		UIButton *linkBt=[UIButton buttonWithType:UIButtonTypeCustom];
		linkBt.frame=CGRectMake(10+25, 234, 170, 40);
		linkBt.titleLabel.font=[UIFont systemFontOfSize:16];
		//linkBt.backgroundColor=[UIColor clearColor];
		[linkBt setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
		[linkBt setTitleColor:[UIColor purpleColor] forState:UIControlStateHighlighted];
		[linkBt addTarget:self action:@selector(linkToWeb:) forControlEvents:UIControlEventTouchUpInside];
		[linkBt setTitle:@"www.leftcoastlogic.com" forState:UIControlStateNormal];
		[self addSubview:linkBt];
		
		UILabel *thankTo=[[UILabel alloc] initWithFrame:CGRectMake(10+25, 264, 300-25, 20)];
		thankTo.font=[UIFont italicSystemFontOfSize:16];
		thankTo.numberOfLines=0;
		thankTo.backgroundColor=[UIColor clearColor];
		thankTo.textColor=[UIColor darkGrayColor];
		thankTo.text=[NSString stringWithFormat:@"Patents pending\n\nSpecial thanks to Huy, Nang and Trung, Hanh for testing, Truc for sustenance, Michael, Eric and Chris in Cupertino, and Mischa in Manchester."];
		[thankTo sizeToFit];
		[self addSubview:thankTo];
		[thankTo release];
		
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	// Drawing code
}


- (void)dealloc {
/*	[appName release];
	[appVersion release];
	[contactTitle release];
	[contactContents release];
	[acknowlegmentTitle release];
	[acknowlegmentContents release];
	[copyrightContent release];
*/	[super dealloc];
}

-(void)setTextColor:(UIColor *)color{
/*	appName.textColor=color;
	appVersion.textColor=color;
	contactTitle.textColor=color;
	contactContents.textColor=color;
	acknowlegmentTitle.textColor=color;
	acknowlegmentContents.textColor=color;
	copyrightContent.textColor=color;
*/}

-(void)linkToWeb:(id)sender{
	NSString *bodyStr = [NSString stringWithFormat:@"http://www.leftcoastlogic.com"];
	NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [[NSURL alloc] initWithString:encoded];
	
	[[UIApplication sharedApplication] openURL:url];
	
	[url release];
	
}

@end
