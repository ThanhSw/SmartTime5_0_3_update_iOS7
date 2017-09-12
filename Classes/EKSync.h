//
//  EKSync.h
//  SmartOrganizer
//
//  Created by Nang Le Van on 10/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
 
@class Common;
@class Task;
@class SmartViewController;
@class Projects;
@interface EKSync : NSObject<UIAlertViewDelegate> {
	NSMutableArray *iCalCalendarsList;
	SmartViewController *rootViewController;
	UIAlertView *alertview;
	BOOL needSkipDelete;
}

@property(nonatomic,retain) NSMutableArray *iCalCalendarsList;
@property(nonatomic,retain) SmartViewController *rootViewController;
@property(readonly) EKEventStore *eventsStore;

- (NSMutableArray *)getICalCalendarsName;
- (NSMutableArray *)getICalCalendars;
- (NSArray *)getICalEventsWithCalendars:(NSArray *)calendars;

- (BOOL)createNewEventToICal:(Task*)event updateREType:(NSInteger)updateREType eventStore:(EKEventStore*)eventStore;
- (BOOL)deleteEventOnICal:(NSString*)eventIdentifier deleteREType:(NSInteger)deleteREType eventStore:(EKEventStore*)eventStore;

- (EKRecurrenceRule *)getICalRERuleFromLocalEvent:(Task*)event;
//- (void)updateRETypeForEvent:(Task*)event fromICalRERule:(EKRecurrenceRule*)iCalReRule;
-(void)updateRETypeForEvent:(Task*)event fromICalRERule:(EKEvent*)icalEvent;

- (NSInteger) getSyncWindowUnit:(BOOL) isForStart;
- (NSDate *) getSyncWindowDate:(BOOL) isStart;
//- (void) updateICaEvent:(EKEvent *)iEvent fromLocalEvent:(Task *)event;
-(void) updateICaEvent:(EKEvent *)iE fromLocalEvent:(Task *)event updateType:(NSInteger)updateType eventStore:(EKEventStore*)eventStore;


//- (void)sync;
- (void)syncCalendarAndEvents;
- (void)oneWayUpdateEvent:(Task*)event originalCalendarId:(NSInteger)originalCalendarId updateType:(NSInteger)updateType;
- (void)oneWayDeleteEvent:(Task *)event withType:(NSInteger)deleteType;
-(void)backgroundFullSync;

-(void)oneWayUpdateiCal:(Projects*)calendar;
-(void)oneWayDeleteICals;
-(BOOL)deleteIEventOnICal:(EKEvent*)iEvent deleteREType:(NSInteger)deleteREType eventStore:(EKEventStore*)eventStore;

@end
