//
//  ReminderSync.h
//  SmartTime
//
//  Created by NangLe_MPro on 1/16/13.
//
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@class Task;
@class Projects;
@class SmartViewController;

@interface ReminderSync : NSObject<UIAlertViewDelegate> {
    NSDate *fromDate;
    NSDate *toDate;
    
    NSString *errorTitle;
    BOOL    isError;
    
    SmartViewController *rootViewController;
}

@property(readonly) EKEventStore *eventStore;
@property(nonatomic,retain) NSDate *fromDate;
@property(nonatomic,retain) NSDate *toDate;
@property(nonatomic,retain) NSString *errorTitle;
@property(nonatomic,retain) SmartViewController *rootViewController;


-(void)handleError:(NSError*)error errorMessage:(NSString*)errorMessage;
-(NSMutableArray *)getICalRemindersFromCalendars:(NSArray *)calendars;

#pragma mark update Event infor

-(void)updateLocalReminderInfo:(Task*)localRemdr fromRemoteReminder:(EKReminder*)remoteRemdr;
-(void)updateRemotReminderInfo:(EKReminder *)remoteRemdr fromLocalEvent:(Task *)localRemdr;
-(BOOL)addNewReminderToICal:(Task*)reminder;
-(BOOL)updateRemoteReminder:(EKReminder*)remoteReminder fromLocalEvent:(Task*)localReminder;

#pragma mark Full Sync

-(void)backgroundFullSync;
-(void)syncCalendarsAndTasks;
-(void)syncCalendars;
-(void)fullSyncTasks;

#pragma mark 1-Way add events
-(void)oneWayAddReminderToICal:(Task*)localReminder;
-(void)performAddReminderToICal:(id)sender;

#pragma mark 1-Way update event
-(void)oneWayUpdateReminder:(Task*)localReminder;
-(void)performOneWayUpdate:(Task*)object;

#pragma mark 1-Way delete event
-(void)oneWayDeleteReminders;
-(void)performOneWaySyncDeleteReminders;

#pragma mark one way delete calendar
-(void)oneWayDeleteCalendars;
-(void)performOneWayDeleteCalendars:(id)sender;
-(void)oneWayAddCalendar:(Projects*)cal;
-(void)performOneWayAddCalendars:(id)sender;
-(void)oneWayUpdateCalendar:(Projects*)cal;

@end
