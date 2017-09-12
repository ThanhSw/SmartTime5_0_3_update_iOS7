/*
 *  IvoCommon.h
 *  IVo
 *
 *  Created by Left Coast Logic on 4/16/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef __IVOCOMMON_H
#define __IVOCOMMON_H
#endif

#import <UIKit/UIKit.h>

#define BOX_HALF_WIDE 140
#define BOX_FULL_WIDE 300

#define BOX_TEXT_PADDING 4
#define BOX_RIGHT_SHADING 2

#define HASHMARK_WIDTH 16
#define HASHMARK_SPACING 4

#define MOVE_AREA_WIDTH 40
#define MOVE_AREA_HEIGHT 40

#define CONTEXT_SIZE 12

#define ALERT_SIZE 10

#define PROJECT_NUM 100//12

#define ADE_VIEW_HEIGHT 40

#define MONTHVIEW_WIDTH 336

#define LISTVIEW_WIDTH (480 - MONTHVIEW_WIDTH)

#define MONTH_TITLE_HEIGHT 26
#define DAY_TITLE_HEIGHT 16

#define NAVIGATION_IMAGE_WIDTH 40
#define NAVIGATION_IMAGE_HEIGHT 16

#define WEEKVIEW_TITLE_HEIGHT 40
#define WEEKVIEW_ADE_HEIGHT 40
#define WEEKVIEW_CELL_WIDTH 68
#define WEEKVIEW_FREETIME_WIDTH 10
#define MONTHVIEW_FREETIME_WIDTH 10

#define AD_REFRESH_PERIOD 60.0 // display fresh ads once per minute

#define THREE_MONTH_INTERVAL	7776000

#define LOOP_DURATION 0.1

//#define TESTING_MODE

//#define FREE_VERSION
//#define ST_BASIC

//#define __IVO_DEBUG__ 1

//#define FINAL_BETA_TEST

#ifdef __IVO_DEBUG__
#define ILOG(format, ...) CFShow([NSString stringWithFormat:format, ## __VA_ARGS__]);
#else
#define ILOG(format, ...) "";
#endif


typedef enum {
	SO,
	GCAL,
	ICAL,
	TD
} BuiltInType;

typedef enum{
	NONE_TAG,
	TOODLEDO_SYNC_SUCCES_TAG,
	TOODLEDO_ERROR_TAG
}AlertsTags;

typedef enum syncType {
	MERGE_TYPE,
	SO_TOODLEDO,
	TOODLEDO_SO
} syncType;

//EK Sync
typedef enum 
{
	SYNC_2WAY = 0,
	SYNC_IMPORT,
	SYNC_EXPORT
} SyncDirection;

typedef enum {
	SMART_VIEW,
	CALENDAR_VIEW,
	SETTING_VIEW,
	FOCUS_VIEW,
	HISTORY_VIEW,
	WEEK_VIEW,
	MONTH_VIEW,
	DETAIL_VIEW,
	FILTER_VIEW,
	CONTACT_VIEW,
}views;

typedef enum {
	NONE,
	CREATE_TASK,
	COMPLETE_TASK,
	DEFER_TOMORROW,
	DEFER_TOMORROW_AFTER,
	DEFER_NEXTWEEK,
	FILTER_HOME,
	UNFILTER_HOME,	
	FILTER_WORK,
	UNFILTER_WORK,
	FILTER_UNPINCHED,
	UNFILTER_UNPINCHED,
	FILTER_PINCHED,
	UNFILTER_PINCHED,
	SWITCH_VIEW,
	GO_MODE_MOVE,
	STOP_MOVE_MODE,
	VIEW_TASK,
	MAXCOMMAND
} TaskCommand;

typedef enum {
	TASKS_ALL,
	TASKS_WITH_DUE_ALL,
	TASKS_WITH_DUE_2_DAYS
} BadgeType;	

typedef enum {
	START_SUNDAY,
	START_MONDAY
}WeekStartDay;
	
typedef enum {
	PROJECT0,
	PROJECT1,
	PROJECT2,
	PROJECT3,
	PROJECT4,
	PROJECT5,
	PROJECT6,
	PROJECT7,
	PROJECT8,
	PROJECT9,
	PROJECT10,
	PROJECT11,
	PROJECT12,
	PROJECT13,
	PROJECT14,
	PROJECT15,
	PROJECT16,
	PROJECT17,
	PROJECT18,
	PROJECT19,
	PROJECT20,
	PROJECT21,
	OTHER,
	GROUP,
	MAXCATEGORY
} TaskCategory;

typedef enum {
	TYPE_SMART_TASK,
	TYPE_SMART_GROUP,
	TYPE_SMART_DYNAMICLINE,
	TYPE_CALENDAR_TASK,
	TYPE_SMART_EVENT,
	TYPE_CALENDAR_EVENT,
	TYPE_SMART_RE, //[Trung v2.0]
	TYPE_SMART_RE_MORE, //[Trung v2.0]
	TYPE_CALENDAR_RE, //[Trung v2.0]
	TYPE_SMART_RE_EXC,
	TYPE_CALENDAR_RE_EXC,
	TYPE_SMART_ADE,
	MAXTYPE
} TaskTypeEnum;

typedef enum {
	OVERDUE,
	DUE,
	BEDUE,
	NODUE,
	MAXDUE,	
} TaskDue;

typedef enum {
	SMALL,
	MEDIUM,
	LARGE,
	MAXDURATION
} TaskDuration;

typedef enum {
	TOOL_DEFAULT,
	TOOL_GROUP,
	TOOL_PAD,
	TOOL_TEXT
} ToolType;

typedef enum {
	TASK_VIEW,
	TASK_CALENDAR_VIEW
} TaskViewType;
 
typedef enum {
	BORDER_TEXT,
	BOX,
	BOX_GRADIENT
} LookNFeel;

typedef enum MoveAreaStyle{
	IVO_STYLE,
	APPLE_STYLE
} MoveAreaStyle;

typedef enum MoveAreaMarginStyle{
	LEFT_MARGIN,
	RIGHT_MARGIN
} MoveAreaMarginStyle;

typedef struct SyncKeyPair {
	NSInteger key;
	double syncKey;
} SyncKeyPair;

//nang's code

typedef struct taskCheckResult{
	NSInteger	errorNo;
	NSInteger	errorAtTaskIndex;
	NSString	*errorMessage;
	NSDate		*overdueTimeSlotFound;
	NSInteger	taskPrimaryKey;
}taskCheckResult;

typedef struct repeatCountTime {
	NSInteger numberOfInstances;
	NSInteger repeatTimes;
} repeatCountTime;

typedef enum infoEditKey {
	SETTING_HOWLONG,
	SETTING_TIMESREPEAT,
	SETTING_ENDDUEDAYS,
	SETTING_PROJECTDEFAULT,
	SETTING_PROJECTEDIT,
	SETTING_REPEATDEFID,
	SETTING_CONTEXTDEFID,
	SETTING_IVOSTYLEDEFID,
	SETTING_DESKTIME,
	SETTING_HOMETIME,
	SETTING_TASKMOVE,
	SETTING_PASSDUEMOVE,
	SETTING_CLEANOLDDATA,
	SETTING_SETUPGCALACC,
	SETTING_BACKUP,
	SETTING_BADGE,
	SETTING_GCALPROJMAP,
	SETTING_PROGCALEVENTMAP,
	SETTING_PROGCALTASKMAP,
	SETTING_SYNCTYPE,
	SETTING_SYNCGUIDE,
	SETTING_GCALSYNCGUIDE,
	SETTING_SYNCWINDOWSTART,
	SETTING_SYNCWINDOWEND,
	SETTING_WEEK_START_DAY,
	SETTING_WORKDAYS,
	SETTING_SNOOZE_DURATION,
	TASK_EDITTITLE,
	TASK_EDITPROJECT,
	TASK_EDITNOTES,
	TASK_EDITCONTEXT,
	TASK_EDITHOWLONG,
	TASK_EDITTIMERTASK,
	TASK_EDITTIMEREVENT,
	TIMER_EDITREPEATID,
	TIMER_EDITREPEATTIMES,
	TASK_EDITDUE,
	TASK_EDITSTART,
	PROJECT_FILTER,
	PROJECT_SHOW_HIDE,
    TASK_EDIT_REPEAT
} infoEditKey;

typedef enum repeatValueKey {
	REPEAT_NONE,
	REPEAT_DAILY,
	REPEAT_WEEKLY,
	REPEAT_MONTHLY,
	REPEAT_YEARLY
}repeatValueKey;
	
typedef enum {
	VERSION_EXPRESS,
	VERSION_REGULAR,
	VERSION_DAY,
	VERSION_SUITE
} ProductVersion;

typedef enum deadLineType {
	DEADLINE_TODAY,
	DEADLINE_TOMORROW,
	DEADLINE_1_WEEK,
	DEADLINE_2_WEEKS,
	DEADLINE_1_MONTH
} deadLineType;

typedef enum errorType {
	ERR_TASK_WITHOUT_NAME,
	ERR_TASK_WITH_NEGATIVE_DURATION,
	ERR_EVENT_START_TIME_IN_PAST,	
	ERR_START_TIME_LATER_END_TIME,
	ERR_TASK_DUE_IN_PAST,
	ERR_TASK_DUE_RANGE_SHORTER_DURATION,
	ERR_TASK_DURATION_TOO_LONG,
	ERR_EVENT_START_OVERLAPPED,
	ERR_TASK_START_OVERLAPPED,
	ERR_EVENT_END_OVERLAPPED,
	ERR_TASK_END_OVERLAPPED,
	ERR_EVENT_OVERLAPS_OTHERS,
	ERR_TASK_OVERLAPS_OTHERS,
	ERR_TASK_ITSELF_PASS_DUE,
	ERR_TASK_ANOTHER_PASS_DUE,
	ERR_TASK_ITSELF_PASS_DEADLINE,
	ERR_TASK_ANOTHER_PASS_DEADLINE,
	ERR_TASK_MOVE_TO_PAST,
	ERR_TASK_WITH_DEAD_LINE_IN_PAST,
	ERR_TASK_MOVE_PAST_TO_PAST,
	ERR_OVER_MAX_TRIAL_TASK,
	ERR_TASK_NOT_BE_FIT_BY_RE,
	ERR_RE_MAKE_TASK_NOT_BE_FIT
	
}errorType;
	
//--------------

typedef enum Palettes{
	PRIME,
	PASTEL,
	VINTAGE,
	LUXE
}Palettes;

typedef enum Prime {
	PRIME_0,
	PRIME_1,
	PRIME_2,
	PRIME_3,
	PRIME_4,
	PRIME_5,
	PRIME_6,
	PRIME_7
}PrimeColors;

/*
 typedef enum BasicColors {
 //for palette1
 BASIC_0,
 BASIC_1,
 BASIC_2,
 BASIC_3,
 BASIC_4,
 BASIC_5,
 BASIC_6,
 BASIC_7,
 BASIC_8,
 BASIC_9,
 BASIC_10,
 BASIC_11
 }BasicColors;
 */

typedef enum VintageColors {
	VINTAGE_0,
	VINTAGE_1,
	VINTAGE_2,
	VINTAGE_3,
	VINTAGE_4,
	VINTAGE_5,
	VINTAGE_6,
	VINTAGE_7
}VintageColors;

typedef enum PastelColors {
	PASTEL_0,
	PASTEL_1,
	PASTEL_2,
	PASTEL_3,
	PASTEL_4,
	PASTEL_5,
	PASTEL_6,
	PASTEL_7
}PastelColors;

typedef enum LuxeColors {
	LUXE_0,
	LUXE_1,
	LUXE_2,
	LUXE_3,
	LUXE_4,
	LUXE_5,
	LUXE_6,
	LUXE_7
}LuxeColors;

typedef enum recuringChangeType {
	THIS_ONLY,
	ALL_SERIRES,
	ALL_FOLLOWING,
	NO_CHANGE
} recuringChangeType;

typedef enum changeType{
	ADD_NEW,
	EDIT,
	SELECT,
	SHOW_HIDE
}changeType;

typedef enum toodleParseKey {
	TD_FREE_KEY,
	TD_GET_TOKEN,
	TD_GET_FOLDER_KEY,
	TD_GET_TASK_KEY,
	TD_GET_DELETED_TASK_KEY,
	TD_GET_USER_ID,
	TD_GET_SERVER_INFO,
	TD_ADD_FOLDER_KEY,
	TD_ADD_TASK_KEY,
	TD_EDIT_FOLDER,
	TD_EDIT_TASK,
	TD_DELETE_FOLDER,
	TD_DELETE_TASK,
	TD_ERROR_KEY
} toodleParseKey;

//static ProductVersion _app_version = VERSION_SUITE;

//static ProductVersion _app_version = VERSION_REGULAR;
//static ProductVersion _app_version = VERSION_DAY;
//static ProductVersion _app_version = VERSION_EXPRESS;

//static MoveAreaStyle _app_movearea_style = IVO_STYLE;
//static MoveAreaStyle _app_movearea_style = APPLE_STYLE;

//static MoveAreaMarginStyle _app_movearea_margin_style = LEFT_MARGIN;
//static MoveAreaMarginStyle _app_movearea_margin_style = RIGHT_MARGIN;

//static BOOL _greenBadgeTurnOff = YES;


//static LookNFeel _app_looknfeel = BORDER_TEXT;
//static LookNFeel _app_looknfeel = BOX_GRADIENT;
//static LookNFeel _app_looknfeel = BOX;

typedef enum
{
	BG_DEFAULT,
	BG_BLACK
} IvoBackgroundStyle;

typedef enum
{
	CONTEXT_HOME,
	CONTEXT_DESK
} TaskContext;


//extern void addRoundedRectToPath(CGContextRef context, CGRect rect,float ovalWidth,float ovalHeight);
//extern void fillRoundedRect (CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight);
//extern void strokeRoundedRect(CGContextRef context, CGRect rect, float ovalWidth,float ovalHeight);
//extern void gradientRoundedRect(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight, CGFloat components[], CGFloat locations[], size_t num_locations);

void addRoundedRectToPath(CGContextRef context, CGRect rect,float ovalWidth,float ovalHeight);
void fillRoundedRect (CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight);
void strokeRoundedRect(CGContextRef context, CGRect rect, float ovalWidth,float ovalHeight);
void gradientRoundedRect(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight, CGFloat components[], CGFloat locations[], size_t num_locations);

#pragma mark number



#pragma mark Text for Messages
/*
NSString *movingTaskPassItsDeadLineAlertText=@"Moving this task will bump it past its deadline. Change deadline?";
NSString *movingTaskPassOthersDeadLineAlertText=@"This will cause some existing tasks to pass their deadlines. Change those deadlines automatically?";
NSString *movingTaskIntoThePast=@"Sorry, you can't move a task into the past.";
NSString *movingTaskPastToPast=@"You will have to change the deadline of this task before you move it.";
NSString *actionMakesItsPassDeadLineText=@"Your deadline will not fit. Too busy? Change deadline?";
NSString *actionMakesOthersPassDeadlinesText=@"This will cause some existing tasks to pass their deadlines. Change those deadlines automatically?";
NSString *startTimeIsLaterEndTimeText=@"Please choose an End-date that occurs after the Start-date";
NSString *importTaskSuccessText=@"Imported successfully";
NSString *deferTaskPassItsDeadlineText=@"Defering this task will bump it past its deadline. Change deadline?";
NSString *noTaskLocationForLaunchMapText=@"Sorry! This task has no location to launch the Maps";
NSString *noEventLocationForLaunchMapText =@"Sorry! This event has no location to launch the Maps";
NSString *applyNewSettingMakesDtasksPassDeadlineText= @"Apply this will cause some existing tasks to pass their deadlines. Change Auto Bump Deadline to Automatically if you still want to apply!";
NSString *taskEvenWithoutTitleText=@"Please add a title.";
NSString *newDTaskWithDeadlineInThePastText=@"Sorry, your deadline cannot be in the past.";//this nerver happend when we consider actionMakesItsPassDeadlineText first
NSString *durationIsTooLongText=@"Sorry, the maximum allowable duration for a task is 24 hours.";
NSString *overMaxTrialTaskText=@"Sorry, you could not add more than 5 tasks/events with free SmartTime version. For using full features, please download the full SmartTime version.";
NSString *restoringSuccessText=@"Restored backup successfully";
NSString *deleteREText=@"Would you like to delete only this event, all events in the series, or this and future events in the series?";
NSString *deleteREAllAndFollowText=@"Would you like to delete all events in the series, or future events in the series?";
NSString *deleteConfirmText=@"Deleted Task/Event can not be restored! Are you sure?";
NSString *editREInstanceText=@"Would you like to change only this event, all events in the series, or this and future events in the series?";
NSString *wrongChangeREText=@"Sorry, you can not change an instance of Recurring Event to be a Task.";
NSString *RETimesEditText=@"Please enter the number of repeat times. Or select 'Repeat Forever'. Or go back and select an end date.";
NSString *introductionText=@"It is expired for SmartTime Beta testing time. Thanks you very much for your co-operation on testing product. Do you want to upgrade a full version of SmartTime Plus?";

NSString *introductionLiteText=@"Upgrade to ST Tasks for full iPhone and Google integration, plus Google Calender sync.\nUpgrade to ST Pro for full integration, sync, plus advanced day/week/month calendars.\nJust tap the \"upgrade\" icon for more info.";
//@"Create and use as many Tasks and Events as you wish.\nUpgrade to SmartTime Task Manager for full iPhone and Google integration, plus Google Calendar sync.\nUpgrade to SmartTime Pro for full integration plus day/week/month calendars and other features.\nJust tap on the \"upgrade\" icon for more info.\n\nThanks, and enjoy!\nLeft Coast Logic";
//@"Now you can synchronize default Events with Google Calendar! Upgrade to SmartTime Plus for Week and Month views, Full Event and Task sync for all Projects, Data backup & restore, Share Tasks & Events, Google Maps, Instant Dialing, and History Archive.  Just tap the \"upgrade\" icon.\n\nThanks, and enjoy!\nThe Left Coast Logic Team.";
NSString *introductionBasicText=@"Just tap on \"+\" to start adding tasks and events.\nTap on the \"tool\" icon to set up Google Sync and other features.\nVisit our ST Tasks page to learn more about your product.\n\nThanks, and enjoy!\nThe Left Coast Logic Team.";

NSString *REMakeTaskNotFitText=@"Sorry, this will force tasks to no longer fit because their duration conflicts with the length and repeating of this (and possibly other) Events";
NSString *taskNotBeFitByREText=@"Sorry, the duration of this task (or some existing tasks) cannot fit into your schedule because of multiple repeating Events.  Suggest you change the duration of this task (or some existing tasks), or change/move some repeating events";
NSString *cancelText=@"Cancel";
NSString *autoText=@"Auto";
NSString *manualText=@"Manual";
NSString *okText=@"OK";
NSString *manuallyText=@"Manually";
NSString *automaticallyText=@"Automatically";
NSString *dismissText=@"Dismiss";
NSString *promptMeText=@"Prompt Me";
NSString *yesText=@"YES";
NSString *noText=@"NO";

NSString *editRETitleText=@"Edit Recurring Event";
NSString *deleteREtitleText=@"Delete Recurring Event";

NSString *onlyInsText=@"Only this instance";
NSString *allEventsText=@"All events in the series";
NSString *allInsFollowText=@"All following";
NSString *maybeText=@"Maybe";

NSString *expiredBetaTestingText=@"Expired SmartTime Beta Testing!";

NSString *restoreBrokenLinkErrorMessageText=@"Sorry, the backed up data could not be restored because the link is broken inside!";
NSString *errorBackupCanNotLaunchMailAppText=@"Sorry, backing up data could not be completed because SmartTime could not launch mail app!";
NSString *errorSharingCanNotLaunchMailAppText=@"Sorry, sharing data could not be completed because SmartTime could not launch mail app!";
NSString *allWorkDayText=@"All Work Weekday";
NSString *allHomeDayText=@"All Home Weekday";
NSString *allDayText=@"All Day";
NSString *backupButtonText=@"Backup";
NSString *backupCellTileText=@"Backup data into email";
NSString *backupNotesText=@"This feature has been updated with version 2.3 and is no longer backwards compatible.  Thus backups made on versions earlier than 2.3 cannot be restored. However, when you upgrade to 2.3, no changes are made to your existing database so you can then make backups after upgrading.";
NSString *backupNotesLiteText=@"This will allow you to backup your data and settings into an email and migrate it over to SmartTime Plus versions 3.0 and above.   Simply tap on the hyperlink in the email after you have installed SmartTime Plus.";
NSString *doneButtonText=@"Done";
NSString *aText=@"A";
NSString *bText=@"B";
NSString *ccText=@"C";
NSString *dText=@"D";
NSString *eText=@"E";
NSString *fText=@"F";
NSString *gText=@"G";
NSString *hText=@"H";
NSString *iText=@"I";
NSString *jText=@"J";
NSString *kText=@"K";
NSString *lText=@"L";
NSString *mText=@"M";
NSString *nText=@"N";
NSString *oText=@"O";
NSString *pText=@"P";
NSString *qText=@"Q";
NSString *rText=@"R";
NSString *sText=@"S";
NSString *tText=@"T";
NSString *uText=@"U";
NSString *vText=@"V";
NSString *wText=@"W";
NSString *xText=@"X";
NSString *yText=@"Y";
NSString *zText=@"Z";

NSString *janText=@"Jan";
NSString *febText=@"Feb";
NSString *marText=@"Mar";
NSString *aprText=@"Apr";
NSString *mayText=@"May";
NSString *junText=@"Jun";
NSString *julText=@"Jul";
NSString *augText=@"Aug";
NSString *sepText=@"Sep";
NSString *octText=@"Oct";
NSString *novText=@"Nov";
NSString *decText=@"Dec";

#pragma mark ivo_Utilities
NSString *sunText=@"Sun";
NSString *monText=@"Mon";
NSString *tueText=@"Tue";
NSString *wedText=@"Wed";
NSString *thuText=@"Thu";
NSString *friText=@"Fri";
NSString *satText=@"Sat";
NSString *amText=@"AM";
NSString *pmText=@"PM";
NSString *minText=@"min";
NSString *hrsText=@"hrs";

NSString *popupTitleText=@"Pop Up";
NSString *emailTitleText=@"Email";

NSString *contextWDayCellText=@"   Weekday";
NSString *contextWEndCellText=@"   Weekend";

NSString *minutesText=@"minutes";
NSString *hoursText=@"hours";
NSString *daysText=@"days";
NSString *weeksText=@"Weeks";

NSString *worktimeViewTitleText=@"Work Time";
NSString *hometimeViewTitleText=@"Home Time";
NSString *eventtimeViewTitleText=@"Event Time";
NSString *deadlineText=@"Deadline";

NSString *weekdayStartCellText=@"Weekday Starts";
NSString *weekdayEndCellText=@"Weekday Ends";

NSString *weekendStartCellText=@"Weekend Starts";
NSString *weekendEndCellText=@"Weekend Ends";

NSString *todayText=@"Today";
NSString *tomorrowText=@"Tomorrow";
NSString *twoWeeksText=@"2 Weeks";
NSString *specifiedText=@"Specified";
NSString *startsText=@"Starts";
NSString *endsText=@"Ends";
NSString *repeatText=@"Repeat";
NSString *untilText=@"Until";
NSString *foreverText=@"Forever";

NSString *generalSettingSectionText=@"General";
NSString *smarttimeSettingSectionText=@"Smart Time";
NSString *defaultValuesSettingSectionText=@"Settings for New Tasks";
NSString *settingBackgroundStyleText=@"Background Style";
NSString *settingProjectNameText=@"Projects & Calendars";
NSString *settingWorkTimeText=@"Work Time";
NSString *settingHomeTimeText=@"Home Time";

NSString *settingAutoBumpTaskText=@"Auto bump tasks";

NSString *settingAutoBumpTaskONText=@"ON: during app startup, tasks that are not completed will be automatically rescheduled. ";
NSString *settingAutoBumpTaskOFFText=@"OFF: during app startup, tasks that are not completed will not be automatically rescheduled.";

NSString *settingAutoBumpDeadlineText=@"Auto bump deadlines";
NSString *settingAutoBumpDeadlineONText=@"ON: deadlines of tasks may be automatically expanded when creating or modifying tasks.";
NSString *settingAutoBumpDeadlineOFFText=@"OFF: warn user for any passing deadline when creating or modifying tasks.";

NSString *cleanOldDateTitleText=@"Clean data older than";
NSString *neverText=@"Never";

NSString *durationText=@"Duration";
NSString *contextText=@"Context";
NSString *projectText=@"Project";
NSString *editProjectText=@"View And Sync";

NSString *locationText=@"Location";

NSString *sortedByaddressText=@"Sort By Address";
NSString *sortedByContactText=@"Sort By Contact";

NSString *doTodayText=@"Do Today";
NSString *nothingToDoText=@"Nothing to do?";
NSString *nothingDoneText=@"Nothing done today!";
NSString *lclSeverErrorMsg=@"SmartTime tried to connect to the LCL server but was unable to. This may be a temporary server hiccup; try to refresh your Event Alert in a few minutes.  If the problem continues, contact support@leftcoastlogic.com and we'll get it sorted out for you.";

NSString *deleteAlertFailedText=@"Delete Alerts Failed!";
NSString *updateAlertFailedText=@"Update Alerts Failed!";

#pragma mark InfoEditViewController
NSString *dayUnitText=@"( days )";
NSString *titleText=@"Title";
NSString *notesText=@"Notes";
NSString *gcalNameText=@"GCal Name";
NSString *mapGCalToProjectErrorTitleText=@"Couldn't map GCal to Project:";
NSString *mapGCalToProjectErrorMEssageText=@"Sorry! This GCal's name has been used for another Project already. Please chose another for your mapping.";
NSString *untilDueText=@"Until Due";
NSString *repeatTimesText=@"Repeat Times";
NSString *repeatForeverText=@"Repeat Forever";

#pragma mark HistoryViewController
NSString *doneHistoryText= @"Done History";

#pragma mark GeneralListViewController
NSString *repeatOnText=@"Repeat On";
NSString *sunOptText=@"    S";
NSString *monOptText=@"    M";
NSString *tueOptText=@"    T";
NSString *wedOptText=@"    W";
NSString *thuOptText=@"    T";
NSString *friOptText=@"    F";
NSString *satOptText=@"    S";
NSString *repeatByText=@"Repeat By";
NSString *dayOfMonthText=@"Day of the month                  ";
NSString *dayOfWeekText=@"Day of the week                    ";
NSString *repeatEveryText=@"Repeat Every";
NSString *repeatTypeText=@"Repeat Types";
NSString *contextsText=@"Contexts";
NSString *stylesText=@"Styles";
NSString *weekUnitText=@"week(s)";
NSString *monthUnitText=@"month(s)";
NSString *yearUnitText=@"year(s)";

NSString *oneWaySTToGCalMsgText=@"This will store your data from SmartTime into your Google Calendars.";
NSString *twoWaySTAndGCalMsgText=@"This will synchronize your data in SmartTime two-ways with your Google Calendars.";
NSString *oneWayGCalToSTMsgText=@"This will restore data from your Google Calendars to SmartTime. It will keep historical data on GCal.";

NSString *oneWaySTToGCalMsg4LiteText=@"This will store your default SmartTime Events into your default Google Calendar.";
NSString *twoWaySTAndGCalMsg4LiteText=@"This will synchronize your default SmartTime Events two-ways with your default Google Calendar.";
NSString *oneWayGCalToSTMsg4LiteText=@"This will restore recent and future Events from your default Google Calendar to our default SmartTime Events. It will keep historical data on GCal.";
NSString	*weedStartDayNotesMsg=@"*Note: change will be reflected after restarting SmartTime.";

#pragma mark FilterView
NSString *applyFilterText=@"Apply Filter";
NSString *keyWordText=@"Enter key word for searching";
NSString *taskText=@"Task";
NSString *eventText=@"Event";
NSString *workText=@"Work";
NSString *homeText=@"Home";
NSString *typeStrText=@"Type";

#pragma mark ContactViewConroller
NSString *contactsText=@"Contacts"; 

#pragma mark AlertValuesViewController
NSString *alertBeforeText=@"Alert Before";
NSString *alertByText=@"Alert by";
NSString *SMSText=@"SMS";
NSString *smsButtonText=  @"SMS                                                       ";
NSString *popupText=@"  iPhone Calendar alert via Google Sync";
NSString *emailText=@"Email                                                     ";
NSString *specifiedTimeText=@"At specified time";

#pragma mark AlertViewController
NSString *alertText=@"Alerts";
NSString *addText=@"Add...";
NSString *onDateEventText=@"At time of event";
NSString *beforeText=@"before";
NSString *APNSText=@"Push";
NSString *popUpText=@"Pop-up";
NSString *pushInformation=@"Push information" ;
NSString *pushInformationMsg=@"Please note in this version, Push alerts only work with normal Events and Tasks, not Repeating Events.";
NSString *donotShowText=@"DON'T SHOW";
NSString *pushRequireMsg =@"Push (requires internet)                     ";
NSString *localNotificationMsg =@"Pop-up Alert	                                  ";
NSString *alertRequireMsg=@"Via Google... (requires  Google account)";
NSString *taskPushHintMsg=@"Push Alerts for Tasks are based upon the time that you specify above.\n\nTo receive Push Alerts, your device must be either connected to a cell network or turned on and connected to the internet.";
NSString *taskPushHintOS4Msg=@"Pop-up Alert for Tasks are based upon the time that you specify above.";

#pragma mark FocusView
NSString *doneTodayButtonText=@"Done Today";
NSString *hideDoneTodayButonText=@"Hide Done Today";
NSString *showDoneTodayButonText=@"Show Done Today";


#pragma mark SmartViewController
NSString *smartText=@"Smart";
NSString *calendarText=@"Calendar";
NSString *focusText=@"Focus";
NSString *markDoneText=@"MarkDone";
NSString *deferText=@"Defer";
NSString *duplicateText=@"Duplicate";
NSString *exitFilterText=@"Exit Filter";
NSString *historyText= @"History";
NSString *nextdayText=@"Next Day";
NSString *nextweekText=@"Next Week";
NSString *launchMapText=@"Launch Maps";
NSString *phoneContactText=@"Phone Contact";
NSString *sharingTaskText=@"Share Task/Event";
NSString *smartViewText=@"Smart View";
NSString *calendarViewText=@"Calendar View";
NSString *phoneErrText=@"Sorry, could not call the contact because of either no phone number or invalid call number format!" ;
NSString *phoneNumberText=@"Call Number";
NSString *sendSmsText=@"Send SMS";
NSString *smsErrText=@"Sorry, could not SMS to the contact because of either no phone number or invalid call number format!" ;
NSString *selecAtPhoneNumberText=@"Select a phone number";

NSString *aboutUsText=@"About Us";
NSString *settingsText=@"Settings";
NSString *viewsText=@"Views";
NSString *doneEventConfirmationText=@"Done event confirmation";
NSString *doneEventWarningMessage=@"The Event will be removed from the time line and placed into History. Are you sure?";
NSString *noSupportPlatformMsg=@"Sorry! The device does not support this action.";
NSString *backText=@"Back";
NSString *selectActionText=@"Select action:";
NSString *upgradeToSTProText=@"Upgrade to ST Pro";
NSString *upgradeToSTTaskText=@"Upgrade to ST Tasks";
NSString *alsoByLCLText=@"Also By Left Coast Logic";
NSString *alsoByLCLBriefText=@"Also by LCL >>";
NSString *deleteConfirmTitleText=@"Delete Confirmation";
NSString *toodledoSyncingText=@"Toodledo sync'ing...";
NSString *tasksSyncText=@"Tasks sync";

#pragma mark DetailView
NSString *titleGuideText=@"Title                 Tap or Type";
NSString *noneText=@"None";
NSString *oneWeekText=@"1 Week";
NSString *oneMonthText=@"1 Month";
NSString *hometimeText=@"Home Time";
NSString *worktimeText=@"Work Time";
NSString *whenText=@"When";
NSString *suggestedTimeText=@"Suggested Time: ";
NSString *addTaskText=@"Add Task";
NSString *addEventText=@"Add Event";
NSString *editTaskText=@"Edit Task";
NSString *editEventText=@"Edit Event";
NSString *duplicateTaskText=@"Duplicate Task";
NSString *duplicateEventText=@"Duplicate Event";

#pragma mark WhatViewController
NSString *titleLocationText=@"Title/Location";
NSString *titleGuideWWWText=@"Tap a shortcut, or just type";
NSString *whatText=@"What";
NSString *whoText=@"Who";
NSString *whereText=@"Where";
NSString *gotoText=@"Go to ";
NSString *contactText=@"Contact ";
NSString *getText=@"Get ";
NSString *writeToText=@"Write to ";
NSString *meetText=@"Meet " ;
NSString *deleteText=@"Delete";
NSString *cleanText=@"Clean";

#pragma mark SmartTimeAppDelegate
NSString *appleBlueText=@"Apple Blue";
NSString *blackOpaqueText=@"Black Opaque";
NSString *dailyText=@"Daily";
NSString *weeklyText=@"Weekly";
NSString *monthlyText=@"Monthly";
NSString *yearlyText=@"Yearly";
NSString *syncGuideText=@"Sync Guide";
NSString	*syncGuideMessages=@"Upgrading from 2.3?  Please be sure that your first sync is 1-way SmartTime -> GCal.  For more info, please see our online Sync Guide.";
NSString	*forGcalSyncText=@"For GCal syncing";

NSString *onDateText=@"At Time";
NSString *smartSyncGCalText=@"SmartTime <-> GCal";
NSString *smartToGCalText=@"SmartTime --> GCal";
NSString *gCalToSmartText=@"GCal --> SmartTime";
NSString *nonameText=@"No Name";
NSString *STTasksWelcomMsg=@"Welcome to SmartTime Tasks!";
NSString *visitText=@"Visit";
NSString *laterText=@"Later";
NSString *snoozeText=@"Snooze";

#pragma mark SetUpMailAccountViewController
NSString *userNameText=@"User Name:";
NSString *passwordText=@"Password:";

#pragma mark Text Messages for SmartView/CalendarView/Sync
NSString *_autoText = @"Auto";
NSString *_manualText = @"Manual";
NSString *_okText = @"OK";
NSString *_cancelText = @"Cancel";
NSString *_yesText = @"YES";
NSString *_deleteFromGCalText = @"Delete from GCal";
NSString *_insertToSTText = @"Insert to ST";

NSString *_notFitText = @"cannot fit into the schedule";
NSString *_makeNotFitText = @"make others not fit into the schedule";
//NSString *_syncErrText = @"The following tasks/events were failed to sync into SmartTime because";
NSString *_syncErrText = @"The following tasks/events were failed to add/update into SmartTime because";
NSString *_syncFailureText = @"Google server error - Please try again";
NSString *_syncTryLaterText = @"Please re-try the sync later";
NSString *_syncErrTitleText = @"Google Calendar Sync - Error";
NSString *_syncWarningTitleText = @"SmartTime - Warning";
NSString *_syncSuccessText = @"Sync Complete!";
NSString *_syncSuccessTitleText = @"Google Calendar Sync";
NSString *_eventCalendarTitleText = @"SmartTime Events";
NSString *_taskCalendarTitleText = @"SmartTime Tasks";
NSString *_onewayST_GCalText = @"1-way Sync ST->GCal";
NSString *_calendarDeleteConfirmText = @"WARNING! One-way sync will delete ALL historical data and settings on your Google calendars because SmartTime does not keep historical data. Are you sure you want to delete all data in your mapped Google calendars and replace it with the current data in SmartTime?";

NSString *_cancelSyncText = @"Cancel Sync";
NSString *_stDeleteConfirmText = @"Are you sure you want to delete all existing data in SmartTime and replace it with the data from GCal?";
NSString *_onewayGCal_STText = @"1-way Sync GCal->ST";
NSString *_invalidUserNameNPasswordText = @"User name and password are invalid. Please specify valid ones in Settings";
NSString *_gcalAccountErrTitleText = @"Google Calendar Account Error";
NSString *_syncProgressTitleText = @"in progress...";
NSString *_plsWaitText = @"Please wait...";
NSString *_unreconcilableErrText = @"Unreconcilable tasks/events due to last sync:"; 
NSString *_twowayST_GCalText = @"2-way Sync ST<->GCal";

NSString *_noEventCalendar2SyncText = @"There is no corresponding mapped Event Calendar in Google to sync";
NSString *_noTaskCalendar2SyncText = @"There is no corresponding mapped Task Calendar in Google to sync";
NSString *_noCalendar2SyncText = @"There is no mapped Google Calendars to sync. Please specify the mapping in Settings";
NSString *_noDefaultCalendar2SyncText = @"There is default Google Calendar to sync. Please create it in Google";

NSString *_readOnlyGCalText = @"Warning: The shared calendar [%SHARED_CAL%] is read-only. Any changes you make to it in SmartTime will not sync back to GCal";
NSString *_note4ReadOnlyGCalText = @"Note: Some shared calendars are read-only. Any changes you make in SmartTime to those calendars will not sync back to GCal";

NSString *_okAuthText = @"User name and password are correct";
NSString *_koAuthText = @"User name or password is incorrect. Please specify valid ones";
NSString *_checkAccountValidity = @"Check Validity";

NSString *_error_1009Text = @"No Internet connection.";
NSString *_error304Text = @"The resource hasn't changed since the time specified in the request's If-Modified-Since header";
NSString *_error400Text = @"Invalid request URI or header, or unsupported nonstandard parameter";
NSString *_error401Text = @"Authorization required";
NSString *_error403Text = @"Unable to authenticate and authorize.\nPlease check for your valid GCal account.";
NSString *_error404Text = @"Resource (such as a feed or entry) not found";
NSString *_error409Text = @"Specified version number doesn't match resource's latest version number";
NSString *_error500Text = @"Internal error. This is the default code that is used for all unrecognized errors";

NSString *noInternetConnectionText=@"No Internet connection!";
NSString *noInternetConnectionMsg=@"It seems you are not connected to the internet. Please check your connection and try again.";

#pragma mark SettingView
NSString *settingGCalAcountText=@"Google Calendar Acount";
NSString *settingSyncTypeText=@"Direction";

NSString *calToProjectMapText = @"Sync Setup";
NSString	*gcalSyncingText=@"GCal Syncing";
NSString	*restoreFromGalText=@"Restore from GCal";
NSString	*deletingWarningText=@"Warn before Delete";
NSString *quickStartSyncGuideText=@"Quick Start";

NSString *deleteDupTitleText=@"Delete suspected duplicates";
NSString *finishedText=@"Finished!";
NSString *applicationBadgeText=@"Application badge for";
NSString *allTasksText=@"All Tasks";
NSString *tasksWithDueText=@"All tasks with due";
NSString *tasksWithNoDueText=@"Tasks due by tomorrow";
NSString *weekStartDayText=@"Week start day";
NSString *sundayText=@"Sunday";
NSString *mondayText=@"Monday";
NSString *warningText= @"Warning!";
NSString *deleteDupMsg=@"This may remove some items that are not duplicates, and cannot be reversed.  Proceed?";
NSString *workDaysText=@"Work Days";
NSString *snoozeDurationText=@"Snooze duration";

//NSString *upgradeToSTProText

#pragma mark ProjectViewController
NSString *tapToEnterCalNameText=@"Tap here to enter GCal name";
NSString *selectGCalNameInListText=@"Or select Gal name in list";
NSString *mapGCalToProjectForEventText=@"Map GCal name to Project for Event";
NSString *mapGCalToProjectForTaskText=@"Map GCal name to Project for Task";
NSString *unMapGCalText=@"Unmap by \'Clear mapping\'";
NSString *clearGCalMappingText=@"Clear mapping";

#pragma mark GCal2ProjectMapViewController
NSString *gCal_ProjectText = @"Project <-> GCal";

#pragma mark GCal2ProjectMapEditViewController
NSString *editMappingText = @"Edit Mapping";

#pragma mark TimeSettingViewController
NSString *dueStartText=@"Due Start";
NSString *horizonsText=@"Horizons";

#pragma mark GCalSyncGuideViewController

NSString *guideContentText=@"If you do not already have a Google Calendar account, please create one at www.google.com/calendar\n\nThen, in SmartTime:\n\n\
1. Input your account settings\n\
2. Choose your sync type\n\
3. Map your calendars\n\
4. Select your sync start and end time\n\n\
Note: \n\n\
If you are using 1-way sync from ST->GCal and map with non-existing Google Calendars, SmartTime will automatically create those calendars for you the first time you perform a sync.\n\
The sync start time will always begin at 00:00:00 on Sunday of Week, or in day 1 of Month, or in day 1 of Year, \
and the sync end time will always end at 23:59:59 on Saturday of Week, or in day end of Month, or in day end of Year\n\n\
Tips:\n\n\
SmartTime logic combines Tasks and Events into one view then organizes them for you. To synchronize with Google Calendar, you can map to two separate GCal calendars for each SmartTime Project - one for tasks, and one for events. \
For example, your \"Family\" project could map to two GCal calendars called \"Family Tasks\" and \"Family Events.\"  If you already have calendars in GCal, SmartTime will locate those for you and give you the option to map Projects to those. \n\n\
Remember:\n\n\
If you change the name of a calendar in GCal, you will need to manually re-map it to the corresponding SmartTime Project.\n\n\
For more information: visit http://www.leftcoastlogic.com/sync";

NSString *guideContent4LiteText = 
@"If you do not already have a Google Calendar account, please create one at www.google.com/calendar\n\nThen, in SmartTime:\n\n\
1. Input your Account settings\n\
2. Choose Your Sync Type\n\n\
The Basics:\n\n\
SmartTime logic combines Tasks and Events into one view then organizes them for you. In this free version, you can synchronize Events from \
your default Project with the events in your default Google Calendar.  In SmartTime, your default Project is \"SmartTime\".  In Google Calendar, \
your default Calendar is typically \"[UserName]@gmail.com\".  SmartTime will automatically sync the two calendars.\n\n\
Quick Start:\n\n\
1) Tap \"Google Calendar Account\" and input your Google UserName and Password.\n\
2) Tap \"Check validity\" and wait a few seconds for confirmation that the info you entered is correct.\n\
3) That's it!  Sync.  We suggest two-way to combine the Events from the default calendars in SmartTime and Google Calendar.\n\n\
Note:\n\n\
1) To sync both Events and To Do's for all of your SmartTime Projects, upgrade to SmartTime Plus.\n\
2) Importing or syncing large databases from your Google Calendar can adversely affect performance.";

#pragma mark AlertViewController
//NSString *alertNoteMsgText=@" To receive SMS Alerts via GCal, please set up your mobile device in GCal -> Settings -> Mobile Setup.";
NSString *alertNoteMsgText=@"• To receive SMS Alerts via GCal, please set up your mobile device in GCal -> Settings -> Mobile Setup.\n\
• To receive Pop-up alerts via iPhone Calendar, please set use the \"Pop-up\" choice.  You will need to use Google Sync services to connect.  For more information, see http://leftcoastlogic.com/sync";

NSString *alertTimeText=@"Alert time";
NSString *timeText=@"Time";
NSString *dueDateText=@"Due Date";
NSString *alertByDueDateText=@"Alert by Due Date";
NSString *alertBySpecifiedDateText=@"Alert by specified Date";

#pragma mark WeekViewCalController
NSString	*monthText=@"Month";
NSString	*loadingText=@"Loading...";
NSString *goText=@"Go";
NSString *gotoDateText=@"Goto Date";
NSString *filterText=@"Filter";
NSString *quickAddText=@"Quick Add";
NSString *applyText=@"Apply";
NSString *exitText=@"Exit";
NSString *saveText=@"Save";
NSString *nameText=@"Name";
NSString *startText=@"Start";
NSString *newTaskText=@"New Task";
NSString *newEventText=@"New Event";

#pragma mark ProductPageViewController
NSString *STText=@"Finally, an Organizer with a Brain. SmartTime uses advanced logic to organize and prioritize tasks and appointments, and integrate them into one view.\n\nTap to create a task - SmartTime finds time for you. Keyboard optional. Then reorganize on the fly, with your fingertips.\n\nMultiple views: Smart, Day, Week, Month.\n\nIntegrated with your iPhone and syncs with Google Calendar as well.";
NSString *STuText=@"The perfect companion for SmartTime, SmartTunes is the ultimate media console. Listen to over 200 WiFi stations, in crystal clear HiFi. Select by genre, or by location. Use our ClockRadio feature to wake up to music, or our unique \"Sleep\" mode to turn the music off after you nod off...\nChoose from a variety of skins, to suite your personality or mood of the day...or night";
NSString *FFText=@"Take pictures of your friends and turn them into goofy, ghastly, or gorgeous muses with our image library of over 70 items of flair.\n\nThen use our built-in Google Mail plug-in to send directly to your friends. Or save to your Photos folder for showing or forwarding.";
NSString *S2QText=@"The iPhone keyboard can take some practice. Now you can master the keyboard while you also master the universe! \n\nShoot the letters by typing them as they fall from the sky. Move to upper levels and type words to destroy the space ships.\n\nFive challenging levels and two different modes: Beginner and \"Top Gun.\"";

#pragma mark SyncWindow2SettingViewController
NSString	*syncBeginThisWeekText=@"This Week";
NSString	*syncLastWeekText=@"Last Week";
NSString	*syncLastMonthText=@"Last Month";
NSString	*syncLast3MonthText=@"Last 3 Months";
NSString	*syncLastYearText=@"Last Year";
NSString	*syncAllPreviousText=@"All Previous";

NSString	*syncEndThisWeekText=@"This Week";
NSString	*syncNextWeekText=@"Next Week";
NSString	*syncNextMonthText=@"Next Month";
NSString	*syncNext3MonthText=@"Next 3 Months";
NSString	*syncNextYearText=@"Next Year";
NSString	*syncAllForwardText=@"All Forward";

NSString *syncStartText=@"Sync Start";
NSString *syncEndText=@"Sync End";

#pragma mark TaskEventDetailViewController
NSString *dueText=@"Due";
NSString *titleTipText=@"Just fill in the title.\nYou can do the rest later";
NSString *cannotUpdateAlertMsg=@"SmartTime could not up-date your alerts on our server for notification service.  Your device may not receive any Push alerts that you may have created.  Please confirm internet connection and try again.!";	
NSString *noInternetForPushMsg=@"It seems you are not connected to the internet. Your device may not receive any Push alerts that you may have created.  Please check your connection and try again!";	
NSString *syncFromToText=@"   Sync From               Sync To";

#pragma mark GCalMappingViewController
NSString *smartSyncText=@"SmartSync";
NSString *expertSyncText=@"ExpertSync";
NSString *mapText=@"Map";
NSString *unmapText=@"Un-map All";
NSString *inheritGCalText=@"ST Project inherits GCal name?";
NSString *stProjectText=@"SmartTime Project";
NSString *withGCalText=@"with Google Calendar";
NSString *smartSyncHintText = @"Map Events from your SmartTime Projects automatically.\n1) Just tap on \'Map\' button to automatically map to Google Calendars. Uncheck to remove any calendar you don't want to sync.\n2) Choose whether to have your ST Project inherit the name of the GCal Calendar. This is handy if you are bringing in GCal data for the first time.";
NSString *smartSyncTipText = @"SmartSync Tips";
NSString *dontShowText = @"Don't Show";
NSString *expertSyncHintText = @"1) Manually Map both Events and Tasks from each of your Projects to individual Google Calendars.\n2) Beware that SmartTime takes control of all Task calendars. See our sync guide for details.\n3) Remember to name your Calendars first in GCal, then select them from here.";
NSString *expertSyncTipText = @"ExpertSync Tips";
NSString *nothingToMapText = @"There is no Google calendar to map. Please check for your valid GCal account, or back to \'Settings\' and try \'Mapping\' again later if it is valid."; 

#pragma mark SyncMappingTableViewController
NSString *syncWindowText=@"Sync Window";
NSString *syncWindowOption1Text = @"1 M";
NSString *syncWindowOption2Text = @"3 M";
NSString *syncWindowOption3Text = @"6 M";
NSString *autoMapText = @"Auto Map";
NSString *connectText = @"Refresh";
NSString *gcalEventMappingText = @"GCal Event Mapping";
NSString *gcalTaskMappingText = @"GCal Task Mapping";
NSString *mappingHeaderText = @"   ST Project         Google Calendar";
NSString *nothingToRefreshText = @"There is no Google calendar to map. Please check for your valid GCal account, or try 'Refresh' again if it is valid.";
NSString *nothingToAutoMapText = @"There is no Google calendar to map. Please check for your valid GCal account, or try 'Refresh' again then 'AutoMap' if it is valid.";

#pragma mark ProjectEditViewController
NSString *projectNameText=@"Projects & Calendars";
NSString *mappedGCalNameText=@"Mapped GCal Name";
NSString *useGCalNameText=@"Use GCal Name";
NSString *projectEditText=@"Project Edit";
NSString *eventMapHintText = @"New users - Map Events Automatically!\n\
1) Tap \'Auto Map\'.\n\
2) Tap each Project to select or deselect for mapping.\n\
3) Tap the arrow to change your Project names.\n\n\
Expert users - More flexibility!\n\
1) Tap on \'Refresh\' to retrieve calendars.\n\
2) Move calendars to map.\n\
3) Tap on \'Task\' Menu to map tasks also; see our Sync Guide for details:";

NSString *taskMapHintText = @"You can also sync SmartTime Tasks to \
separate \'Task\' calendars in GCal.\n\n\
Be aware that SmartTime will \"take control\" of all \
calendars in GCal that you map to SmartTime Tasks. \
After you sync, SmartTime will treat all items in \
those calendars as tasks and will MOVE them to find \
the most efficient time slot. If you mistakedly map \
a SmartTime Task to one of your Google Event calendars, \
you will lose the specific dates and times of those appointments.\n\
Please visit our Sync Guide:";

NSString *syncNowText=@"Sync Now";

#endif

#pragma mark CalendarView
NSString *quickAddPassDeadlineErrorMgs=@"Sorry! This will causes some tasks to be passed their deadines!";

#pragma mark MonthlyView
NSString *weekText=@"Week";

#pragma mark WeekDaySettingViewController

NSString *workDayStartsText=@"Work Day Starts";
NSString *workDayEndsText=@"Work Day Ends";
NSString *weekendDayNeededMsg=@"Sorry! Has no room for Weekend days. Please select again!";
NSString *nextText=@" next ";

#pragma SyncToodeldo
NSString *toodledoAccountSetupText=@"Toodledo Account setup";
NSString *lUserNameText=@"Username";
NSString *paswordText=@"Password";
NSString *syncTypeText=@"Sync Type";
NSString *checkValidityText=@"Check Validity";
NSString *successText=@"Success!";
NSString *accountValidateMsg=@"Your account is correct!";
NSString *failedText=@"Failed!";
NSString *accountInValidateMsg=@"Your input account is invalid! Please specify again.";
*/

@interface IvoCommon:NSObject{
	
}

@end
