//
//  CalendarIconView.m
//  SmartOrganizer
//
//  Created by Nang Le Van on 8/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CalendarIconView.h"
#import "Projects.h"
#import "ivo_Utilities.h"
#import "ColorObject.h"
#import "TaskManager.h"
#import "IvoCommon.h"
#import "SmartTimeAppDelegate.h"


extern SmartTimeAppDelegate *App_Delegate;
extern TaskManager *taskmanager;

extern ivo_Utilities *ivoUtility;
/*
extern void addRoundedRectToPath(CGContextRef context, CGRect rect,
								 float ovalWidth,float ovalHeight);
extern void strokeRoundedRect(CGContextRef context, CGRect rect, float ovalWidth,
                       float ovalHeight);
extern void gradientRoundedRect(CGContextRef context, CGRect rect, float ovalWidth,
								float ovalHeight, CGFloat components[], CGFloat locations[], size_t num_locations,BOOL needSqareBox);
extern void fillRoundedRect (CGContextRef context, CGRect rect,
							 float ovalWidth, float ovalHeight);
*/
void addRoundedRectToPathLocal(CGContextRef context, CGRect rect,
						  float ovalWidth,float ovalHeight)

{
    float fw, fh;
	
    if (ovalWidth == 0 || ovalHeight == 0) {// 1
        CGContextAddRect(context, rect);
        return;
    }
	
    CGContextSaveGState(context);// 2
	//1.2    CGContextBeginPath(context);
	
    CGContextTranslateCTM (context, CGRectGetMinX(rect),// 3
						   CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);// 4
    fw = CGRectGetWidth (rect) / ovalWidth;// 5
    fh = CGRectGetHeight (rect) / ovalHeight;// 6
	
    CGContextMoveToPoint(context, fw, fh/2); // 7
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1.2);// 8
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1.2);// 9
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1.2);// 10
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1.2); // 11
    CGContextClosePath(context);// 12
	
    CGContextRestoreGState(context);// 13
}

void strokeRoundedRectLocal(CGContextRef context, CGRect rect, float ovalWidth,
                       float ovalHeight)
{
	//    CGContextBeginPath(context);
    addRoundedRectToPathLocal(context, rect, ovalWidth, ovalHeight);
    CGContextStrokePath(context);
}


void gradientRoundedRectLocal(CGContextRef context, CGRect rect, float ovalWidth,
						 float ovalHeight, CGFloat components[], CGFloat locations[], size_t num_locations,BOOL needSqareBox)
{
    CGContextSaveGState(context);// 2
	//n1.1	
	//	CGContextClearRect(context, rect);
	
	if (!needSqareBox) {
		addRoundedRectToPathLocal(context, rect, ovalWidth, ovalHeight);
		CGContextClip(context);
	}else {
		//if would like to customize square rect, add lines here and then clip it
		
	}
	
	
	CGGradientRef myGradient;
	CGColorSpaceRef myColorspace;
	
	//myColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	myColorspace = CGColorSpaceCreateWithName(CFSTR("kCGColorSpaceGenericRGB"));
	myGradient = CGGradientCreateWithColorComponents (myColorspace, components,locations, num_locations);
	
	CGPoint myStartPoint, myEndPoint;
	myStartPoint.x = rect.origin.x;
	myStartPoint.y = rect.origin.y;
	myEndPoint.x = rect.origin.x;
	myEndPoint.y = rect.origin.y + rect.size.height;
	
	CGContextDrawLinearGradient(context, myGradient, myStartPoint, myEndPoint, 0);	
	
    CGContextRestoreGState(context);// 13
	CGGradientRelease(myGradient);
}

void fillRoundedRectLocal (CGContextRef context, CGRect rect,
					  float ovalWidth, float ovalHeight)

{
	//    CGContextBeginPath(context);
    addRoundedRectToPathLocal(context, rect, ovalWidth, ovalHeight);
    CGContextFillPath(context);
}

@implementation CalendarIconView
@synthesize calendarId;
@synthesize isSquareBox;
@synthesize isIndicator;
@synthesize isCircle;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)drawRect:(CGRect)rect {
    // Drawing code
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, rect);
	[self drawInContext:context];
}

-(void)drawInContext:(CGContextRef)context
{
	CGRect bounds=self.bounds;
	
/*	bounds.origin.x += borderSize/2;
	bounds.origin.y += borderSize/2;
	bounds.size.width -= borderSize;
	bounds.size.height -= borderSize;
*/	
	//CGFloat r1,g1,b1,r2,g2,b2;
	
    if (isCircle) {
        Projects *cal=[App_Delegate calendarWithPrimaryKey:self.calendarId];
        ColorObject *color=[ivoUtility colorForColorNameNo:cal.colorId inPalette:cal.groupId];

        // Drawing with a white stroke color
        CGContextSetRGBStrokeColor(context,color.R1, color.G1, color.B1, 1.0);
        // And draw with a blue fill color
        CGContextSetLineWidth(context, 2.0);
        
        // Add an ellipse circumscribed in the given rect to the current path, then stroke it
        CGContextAddEllipseInRect(context, CGRectMake(1, 1, bounds.size.width-2, bounds.size.height-2));
        CGContextStrokePath(context);

    }else{
        if (!isIndicator) {
            Projects *cal=[App_Delegate calendarWithPrimaryKey:self.calendarId];
            ColorObject *color=[ivoUtility colorForColorNameNo:cal.colorId inPalette:cal.groupId];
            
            size_t num_locations = 3;
            CGFloat locations[3] = { 0.0, 0.4, 1.0 };
            //CGFloat locations[3] = { 1.0, 1.0, 1.0 };
            
            CGFloat components[12] = { 
                color.R3, color.G3, color.B3, 1.0, 
                color.R2, color.G2, color.B2, 1.0, 
                color.R1, color.G1, color.B1, 1.0 
            };
            
            gradientRoundedRectLocal(context, bounds, 3, 4, components, locations, num_locations, self.isSquareBox);
        }else {
            size_t num_locations = 3;
            CGFloat locations[3] = { 0.0, 0.4, 1.0 };
            
            CGFloat components[12] = { 
                160.0/255, 160.0/255, 160.0/255, 1.0, 
                120.0/255, 120.0/255, 120.0/255, 1.0, 
                80.0/255, 80.0/255, 80.0/255, 1.0 
            };
            
            gradientRoundedRectLocal(context, bounds, 3.2, 3.2, components, locations, num_locations, self.isSquareBox);
        }
    }
}

- (void)dealloc {
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	[self.nextResponder touchesBegan: touches withEvent:event]; 
	
	//self.backgroundColor=[RGBColor steelBlue4];
	//self.titleLabel.highlighted=YES;
}

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event {
	[self.nextResponder touchesEnded: touches withEvent:event]; 
	
	//self.backgroundColor=[UIColor clearColor];
	//self.titleLabel.highlighted=NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	[self.nextResponder touchesMoved: touches withEvent:event]; 
}

-(void)setCalendarId:(NSInteger)calId{
	calendarId=calId;
	[self setNeedsDisplay];
}

-(void)setIsSquareBox:(BOOL)bl{
	if (isSquareBox!=bl) {
		isSquareBox=bl;
		[self setNeedsDisplay];
	}
}

-(void)setIsIndicator:(BOOL)bl{
	if (isIndicator==bl) {
		return;
	}
	
	isIndicator=bl;
	
	if (bl) {
		[self setNeedsDisplay];
	}
}

@end
