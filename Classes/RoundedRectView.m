//
//  RoundedRectView.m
//  SmartTime
//
//  Created by Huy Le on 10/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RoundedRectView.h"
#import "GuideWebView.h"
#import "ivo_Utilities.h"

//#define kDefaultStrokeColor         [UIColor whiteColor]
#define kDefaultStrokeColor         [UIColor darkGrayColor]
//#define kDefaultRectColor           [UIColor whiteColor]
#define kDefaultRectColor			[ivo_Utilities  colorWithHexString:@"87cefa"]
#define kDefaultStrokeWidth         1.0
#define kDefaultCornerRadius        30.0

@implementation RoundedRectView
@synthesize strokeColor;
@synthesize rectColor;
@synthesize strokeWidth;
@synthesize cornerRadius;

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
        // Initialization code
        self.opaque = NO;
        self.strokeColor = kDefaultStrokeColor;
        self.backgroundColor = [UIColor clearColor];
        self.rectColor = kDefaultRectColor;
        self.strokeWidth = kDefaultStrokeWidth;
        self.cornerRadius = kDefaultCornerRadius;
		
		CGRect frm = frame;
		
		frm.origin.x = 10;
		frm.origin.y = 5;
		
		frm.size.width -= 20;
		frm.size.height -= 20;
		
		webView = [[GuideWebView alloc] initWithFrame:frm];
		
		[self addSubview:webView];
		
		[webView release];
		
		okButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		okButton.frame = CGRectMake((frame.size.width - 2*100)/3, frame.size.height - 40 , 100, 30);
		
		[okButton setTitle:NSLocalizedString(@"okText", @"")/*okText*/ forState:UIControlStateNormal];
		
		[self addSubview:okButton];

		dontShowButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		dontShowButton.frame = CGRectMake((frame.size.width - 2*100)*2/3 + 100, frame.size.height - 40 , 100, 30);
		
		[dontShowButton setTitle:NSLocalizedString(@"dontShowText", @"")/*dontShowText*/ forState:UIControlStateNormal];
		
		[self addSubview:dontShowButton];
    }
    return self;
}

- (void)setActionsWithTarget:(id)target actionOK:(SEL)actionOK actionNotShow:(SEL)actionNotShow
{
	[okButton addTarget:target action:actionOK forControlEvents:UIControlEventTouchUpInside];
	
	[dontShowButton addTarget:target action:actionNotShow forControlEvents:UIControlEventTouchUpInside];	
}

- (void)loadHTMLFile:(NSString *)fileName extension:(NSString *)fileExt
{
	[webView loadHTMLFile:fileName extension:fileExt];
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
    CGContextSetFillColorWithColor(context, self.rectColor.CGColor);
    
    CGRect rrect = self.bounds;
    
    CGFloat radius = cornerRadius;
    CGFloat width = CGRectGetWidth(rrect);
    CGFloat height = CGRectGetHeight(rrect);
    
    // Make sure corner radius isn't larger than half the shorter side
    if (radius > width/2.0)
        radius = width/2.0;
    if (radius > height/2.0)
        radius = height/2.0;    
    
    CGFloat minx = CGRectGetMinX(rrect);
    CGFloat midx = CGRectGetMidX(rrect);
    CGFloat maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect);
    CGFloat midy = CGRectGetMidY(rrect);
    CGFloat maxy = CGRectGetMaxY(rrect);
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)dealloc {
    [strokeColor release];
    [rectColor release];
    [super dealloc];
}

@end
