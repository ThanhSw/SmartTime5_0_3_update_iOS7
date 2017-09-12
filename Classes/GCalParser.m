//
//  ICalParser.m
//  SmartTime
//
//  Created by Left Coast Logic on 11/14/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GCalParser.h"
//#import "GData.h"
#import "Task.h"
#import "IvoCommon.h"
#import "ivo_Utilities.h"

extern ivo_Utilities *ivoUtility;

@implementation GCalParser

@synthesize startDate;
@synthesize endDate;
@synthesize rruleDict;
@synthesize components;
@synthesize isADE;

-(void) reset
{
	self.startDate = nil;
	self.endDate = nil;
	self.rruleDict = nil;
	self.components = [NSMutableArray arrayWithCapacity:3];
	self.isADE = NO;
	adeCheck = NO;
}

-(void)print
{
/*
	printf("--- RE info ---\n");
	NSEnumerator *enumerator = [self.rruleDict keyEnumerator];
	NSString *key;
	
	while ((key = [enumerator nextObject])) {
		
		printf("*key: %s\n", [key UTF8String]);
		
		if ([key isEqualToString:@"COUNT"] || [key isEqualToString:@"INTERVAL"])
		{
			//NSInteger val = [self.rruleDict objectForKey:key];
			NSString *val = [self.rruleDict objectForKey:key];
			printf("value: %s\n", [val UTF8String]);
		}
		else if ([key isEqualToString:@"BYMONTH"] || 
				 [key isEqualToString:@"BYHOUR"] || 
				 [key isEqualToString:@"BYMINUTE"] || 
				 [key isEqualToString:@"BYSECOND"] ||
				 [key isEqualToString:@"BYYEARDAY"] ||
				 [key isEqualToString:@"BYMONTHDAY"] ||
				 [key isEqualToString:@"BYWEEKNO"] ||
				 [key isEqualToString:@"BYSETPOS"])
			
		{
			NSArray *isVals = [self.rruleDict objectForKey:key];
			
			NSString *s = @"";
			
			for (NSString *val in isVals)
			{
				s = [s stringByAppendingFormat:@"%@,", val];
			}			
			printf("value: %s\n", [s UTF8String]);			
			
		} 
		else if ([key isEqualToString:@"BYDAY"])
		{
			NSArray *sVals = [self.rruleDict objectForKey:key];
			
			NSString *s = @"";
			
			for (NSString *val in sVals)
			{
				s = [s stringByAppendingFormat:@"%@,", val];
			}
			
			printf("value: %s\n", [s UTF8String]);	
		}
		else if ([key isEqualToString:@"WKST"])
		{
			NSString *s = [self.rruleDict objectForKey:key];
			printf("value: %s\n", [s UTF8String]);
		}
		else if ([key isEqualToString:@"UNTIL"])
		{
			NSDate *dt = [self.rruleDict objectForKey:key];
			printf("value: %s\n", [[dt description] UTF8String]);			
		}
		else
		{
			NSString *val = [self.rruleDict objectForKey:key];
			if ([val isEqualToString:@""])
			{
				val = @"None";
			}
			printf("value: %s\n", [[val description] UTF8String]);
		}
	}
	
	printf("--- End RE info ---\n");
*/
}
/*
- (id) init
{
	if (self = [super init])
	{
		[self reset];
	}
	
	return self;
}

-(void) updateRE:(Task *)re
{	
	printf("*** Update RE from Parser: %s\n", [re.taskName UTF8String]);
	
	re.taskPinned = YES;
	
	re.taskStartTime = self.startDate;
	
	printf("start time: %s\n", [[re.taskStartTime description] UTF8String]);  
	
	re.taskREStartTime = self.startDate;
	
	re.taskHowLong = [self.endDate timeIntervalSinceDate:self.startDate];
	
	re.taskEndTime = self.endDate;
	
	printf("end time: %s\n", [[re.taskEndTime description] UTF8String]);
	
	re.isAllDayEvent = self.isADE;
	
	re.parentRepeatInstance = -1;
	
	//NSString *repeatEvery = nil;
	NSString *repeatOn = @"";
	NSString *repeatBy = @"";
	
	NSString *repeatEvery = [self.rruleDict objectForKey:@"INTERVAL"];
	
	if (repeatEvery == nil)
	{
		repeatEvery = @"1";
	}
	
	NSString *val = [rruleDict objectForKey:@"DAILY"];
	
	if (val != nil)
	{
		//printf("#####Daily\n");
		re.taskRepeatID = REPEAT_DAILY;		
	}
	else
	{
		val = [rruleDict objectForKey:@"WEEKLY"];
		
		if (val != nil)
		{
			re.taskRepeatID = REPEAT_WEEKLY;
			
			NSArray *vals = [rruleDict objectForKey:@"BYDAY"];
			
			if (vals != nil)
			{
				for (int i=0; i<[vals count];i++)
				{
					NSString *s = [[vals objectAtIndex:i] uppercaseString];
					
					if ([s isEqualToString:@"SU"])
					{
						s = @"1";
					} 
					else if ([s isEqualToString:@"MO"])
					{
						s = @"2";
					}
					else if ([s isEqualToString:@"TU"])
					{
						s = @"3";
					}
					else if ([s isEqualToString:@"WE"])
					{
						s = @"4";
					}
					else if ([s isEqualToString:@"TH"])
					{
						s = @"5";
					}
					else if ([s isEqualToString:@"FR"])
					{
						s = @"6";
					}
					else if ([s isEqualToString:@"SA"])
					{
						s = @"7";
					}
					
					if (i==[vals count]-1)
					{
						repeatOn = [repeatOn stringByAppendingString:s];
					}
					else
					{
						repeatOn = [repeatOn stringByAppendingFormat:@"%@|", s];
					}
				}
			}
		}
		else
		{
			val = [self.rruleDict objectForKey:@"MONTHLY"];
			
			if (val != nil)
			{
				re.taskRepeatID = REPEAT_MONTHLY;
				
				NSArray *vals = [self.rruleDict objectForKey:@"BYMONTHDAY"];
				
				if (vals != nil)
				{
					repeatBy = @"0";
				}
				else
				{
					vals = [self.rruleDict objectForKey:@"BYDAY"];
					
					if (vals != nil)
					{
						repeatBy = @"1";
					}
				}
			}
			else
			{
				val = [self.rruleDict objectForKey:@"YEARLY"];
				
				if (val != nil)
				{
					re.taskRepeatID = REPEAT_YEARLY;
				}
			}
		}		
	}
	
	re.taskRepeatOptions = [NSString stringWithFormat:@"%@/%@/%@", repeatEvery, repeatOn, [repeatBy isEqualToString:@""]?@"0":repeatBy];
	
	NSDate *until = [self.rruleDict objectForKey:@"UNTIL"];
	
	if (until != nil)
	{
		printf("RE until :%s\n", [[until description] UTF8String]);
		
		re.taskEndRepeatDate = until;
		
		repeatCountTime repeatCount = [ivoUtility createRepeatCountFromEndDate:re.taskREStartTime
																	typeRepeat:re.taskRepeatID 
																		toDate:until 
															  repeatOptionsStr:re.taskRepeatOptions
																   reStartDate:re.taskREStartTime];
		
		re.taskRepeatTimes = repeatCount.repeatTimes;
		re.taskNumberInstances = repeatCount.numberOfInstances;
	}
	else
	{
		printf("RE until: forever\n");		
		re.taskRepeatTimes = 0;
		re.taskNumberInstances = 0;
	}
	
	printf("Update RE from Parser *** \n");	
}

- (void) parseRRule:(NSString *)rruleStr
{
	//printf("parse RRule: %s\n", [rruleStr UTF8String]);
	rruleStr = [rruleStr stringByReplacingOccurrencesOfString:@"FREQ=" withString:@""];
	
	NSArray *parts = [rruleStr componentsSeparatedByString:@";"];
	
	NSMutableArray *keys = [NSMutableArray arrayWithCapacity:[parts count]];
	NSMutableArray *vals = [NSMutableArray arrayWithCapacity:[parts count]];
	
	for (int i=0; i<[parts count]; i++)
	{
		NSString *part = [parts objectAtIndex:i];
		
		if (i == 0)
		{
			//printf("parse RRule - part: %s\n", [part UTF8String]);
			[keys addObject:part];
			[vals addObject:part];
		}
		else
		{
			NSRange range = [part rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
			
			if (range.location != NSNotFound)
			{
				NSString *param = [part substringToIndex:range.location];
				NSString *paramVal = [part substringFromIndex:range.location + 1];
				
				if ([param isEqualToString:@"COUNT"] || 
					[param isEqualToString:@"INTERVAL"])
				{
					[keys addObject:param];
					[vals addObject:paramVal]; //integer string value
				}
				else if ([param isEqualToString:@"BYMONTH"] ||
						 [param isEqualToString:@"BYHOUR"] || 
						 [param isEqualToString:@"BYMINUTE"] || 
						 [param isEqualToString:@"BYSECOND"] ||
						 [param isEqualToString:@"BYYEARDAY"] ||
						 [param isEqualToString:@"BYMONTHDAY"] ||
						 [param isEqualToString:@"BYWEEKNO"] ||
						 [param isEqualToString:@"BYSETPOS"])
				{
					NSArray *isVals = [paramVal componentsSeparatedByString:@","];

					[keys addObject:param];
					[vals addObject:isVals]; //integer string series
				}
				else if ([param isEqualToString:@"BYDAY"])
				{
					NSArray *sVals = [paramVal componentsSeparatedByString:@","];
					[keys addObject:param];
					[vals addObject:sVals]; //string series
				}
				else if ([param isEqualToString:@"WKST"])
				{
					[keys addObject:param];
					[vals addObject:paramVal]; //string value
				}
				else if ([param isEqualToString:@"UNTIL"])
				{
					NSRange yearRange;
					yearRange.location = 0;
					yearRange.length = 4;
					
					NSRange monthRange;
					monthRange.location = 4;
					monthRange.length = 2;
					
					NSRange dayRange;
					dayRange.location = 6;
					dayRange.length = 2;
					
					NSRange hourRange;
					hourRange.location = 9;
					hourRange.length = 2;
					
					NSRange minRange;
					minRange.location = 11;
					minRange.length = 2;
					
					NSRange secRange;
					secRange.location = 13;
					secRange.length = 2;
					
					NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];					
					unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
					
					NSDateComponents *comps = nil;
					
					NSDate *dateVal = nil;
					
					if ([paramVal length] == 8) //date
					{
						[gregorian setTimeZone:[NSTimeZone systemTimeZone]];
						
						comps = [gregorian components:unitFlags fromDate:[NSDate date]];
						
						[comps setYear: [[paramVal substringWithRange:yearRange] integerValue]];
						[comps setMonth: [[paramVal substringWithRange:monthRange] integerValue]];
						[comps setDay: [[paramVal substringWithRange:dayRange] integerValue]];	
						
						[comps setHour: 0];
						[comps setMinute: 0];
						[comps setSecond: 0];
						
					}
					else //date-time
					{
						[gregorian setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
						
						comps = [gregorian components:unitFlags fromDate:[NSDate date]];
						
						[comps setYear: [[paramVal substringWithRange:yearRange] integerValue]];
						[comps setMonth: [[paramVal substringWithRange:monthRange] integerValue]];
						[comps setDay: [[paramVal substringWithRange:dayRange] integerValue]];	
						
						[comps setHour: [[paramVal substringWithRange:hourRange] integerValue]];
						[comps setMinute: [[paramVal substringWithRange:minRange] integerValue]];
						[comps setSecond: [[paramVal substringWithRange:secRange] integerValue]];						
					}
					
					if (comps != nil)
					{
						dateVal = [gregorian dateFromComponents:comps];
					}
					
					[keys addObject:param];
					[vals addObject:dateVal];
					
					[gregorian release];
				}
			}
		}
	}
	
	self.rruleDict = [NSDictionary dictionaryWithObjects:vals forKeys:keys];
}

/*
- (NSDate *) parseDate:(NSString *)datestr
{
	NSRange range = [datestr rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
	NSRange valRange = [datestr rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
	
	if (range.location == NSNotFound || valRange.location == NSNotFound)
	{
		return nil;
	}
	
	NSString *param = [datestr substringToIndex:range.location];
	//NSString *rest = [line substringFromIndex:range.location + 1];
	
	NSRange paramValRange;
	
	paramValRange.location = range.location + 1;
	paramValRange.length = valRange.location - range.location - 1; 
	
	NSString *paramVal = [datestr substringWithRange:paramValRange];
	
	//printf("param value: %s\n", [paramVal UTF8String]);
	
	NSString *dateVal = [datestr substringFromIndex:valRange.location + 1];	
	
	NSTimeZone *tz = [NSTimeZone systemTimeZone];
	
	if ([param isEqualToString:@"VALUE"])
	{
		//printf("param: VALUE\n");
		
		if ([paramVal isEqualToString:@"DATE"])
		{
			adeCheck = YES;
			dateVal = [dateVal stringByAppendingString:@"T000000"];
		}
	}
	else if ([param isEqualToString:@"TZID"])
	{
		//printf("param: TZID\n");
		
		tz = [NSTimeZone timeZoneWithName:paramVal];
	}

	printf("dateVal: %s\n", [dateVal UTF8String]);
	
	NSRange dtRange = [dateVal rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"T"]];

	if (dtRange.location == NSNotFound  || [dateVal length] != 15 )
	{
		return nil;
	}
	
	NSRange yearRange;
	yearRange.location = 0;
	yearRange.length = 4;

	NSRange monthRange;
	monthRange.location = 4;
	monthRange.length = 2;

	NSRange dayRange;
	dayRange.location = 6;
	dayRange.length = 2;

	NSRange hourRange;
	hourRange.location = 9;
	hourRange.length = 2;

	NSRange minRange;
	minRange.location = 11;
	minRange.length = 2;

	NSRange secRange;
	secRange.location = 13;
	secRange.length = 2;
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[gregorian setTimeZone:tz];
	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:[NSDate date]];
	
	//printf("day: %s\n", [[dateVal substringWithRange:dayRange] UTF8String]);
	
	[comps setYear: [[dateVal substringWithRange:yearRange] integerValue]];
	[comps setMonth: [[dateVal substringWithRange:monthRange] integerValue]];
	[comps setDay: [[dateVal substringWithRange:dayRange] integerValue]];	

	[comps setHour: [[dateVal substringWithRange:hourRange] integerValue]];
	[comps setMinute: [[dateVal substringWithRange:minRange] integerValue]];
	[comps setSecond: [[dateVal substringWithRange:secRange] integerValue]];
	
	NSDate *ret = [[gregorian dateFromComponents:comps] retain]; 
	
	[gregorian release];
	
	return ret;
}
*/

/*
- (NSDate *) parseDate:(NSString *)datestr
{
	NSRange range = [datestr rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
	NSRange valRange = [datestr rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
	
	NSString *dateVal = datestr;
	
	NSTimeZone *tz = [NSTimeZone systemTimeZone];
	
	if (range.location != NSNotFound && valRange.location != NSNotFound)
	{
		NSString *param = [datestr substringToIndex:range.location];
		
		NSRange paramValRange;
		
		paramValRange.location = range.location + 1;
		paramValRange.length = valRange.location - range.location - 1; 
		
		NSString *paramVal = [datestr substringWithRange:paramValRange];
		
		//printf("param value: %s\n", [paramVal UTF8String]);
		dateVal = [datestr substringFromIndex:valRange.location + 1];
		
		if ([param isEqualToString:@"VALUE"])
		{
			//printf("param: VALUE\n");
			
			if ([paramVal isEqualToString:@"DATE"])
			{
				adeCheck = YES;
				dateVal = [dateVal stringByAppendingString:@"T000000"];
			}
		}
		else if ([param isEqualToString:@"TZID"])
		{			
			tz = [NSTimeZone timeZoneWithName:paramVal];
		}		
	}

	//printf("dateVal: %s\n", [dateVal UTF8String]);
	
	NSRange dtRange = [dateVal rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"T"]];
	
	NSRange zRange = [dateVal rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"Z"]];
	
	if (zRange.location != NSNotFound)
	{
		tz = [NSTimeZone timeZoneWithName:@"UTC"];
	}
	
	if (dtRange.location == NSNotFound  || [dateVal length] < 15 )
	{
		return [[NSDate date] retain];
	}
	
	NSRange yearRange;
	yearRange.location = 0;
	yearRange.length = 4;
	
	NSRange monthRange;
	monthRange.location = 4;
	monthRange.length = 2;
	
	NSRange dayRange;
	dayRange.location = 6;
	dayRange.length = 2;
	
	NSRange hourRange;
	hourRange.location = 9;
	hourRange.length = 2;
	
	NSRange minRange;
	minRange.location = 11;
	minRange.length = 2;
	
	NSRange secRange;
	secRange.location = 13;
	secRange.length = 2;
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[gregorian setTimeZone:tz];
	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:[NSDate date]];
	
	//printf("day: %s\n", [[dateVal substringWithRange:dayRange] UTF8String]);
	
	[comps setYear: [[dateVal substringWithRange:yearRange] integerValue]];
	[comps setMonth: [[dateVal substringWithRange:monthRange] integerValue]];
	[comps setDay: [[dateVal substringWithRange:dayRange] integerValue]];	
	
	[comps setHour: [[dateVal substringWithRange:hourRange] integerValue]];
	[comps setMinute: [[dateVal substringWithRange:minRange] integerValue]];
	[comps setSecond: [[dateVal substringWithRange:secRange] integerValue]];
	
	NSDate *ret = [[gregorian dateFromComponents:comps] retain]; 
	
	[gregorian release];
	
	return ret;
}

-(void) parseLine:(NSString *)line
{
	//printf("parse Line:%s\n", [line UTF8String]);
	
	NSRange range = [line rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@";:"]];

	if (range.location == NSNotFound)
	{
		return;
	}
	
	//printf("loc: %d - len: %d\n", range.location, range.length);
	
	NSString *propertyName = [line substringToIndex:range.location];
	
	//printf("property: %s\n", [propertyName UTF8String]);
	
	NSString *rest = [line substringFromIndex:range.location + 1];

	//printf("rest: %s\n", [rest UTF8String]);

	if ([propertyName isEqualToString:@"BEGIN"])
	{
		[self.components addObject:rest];
	}
	else if ([propertyName isEqualToString:@"END"])
	{
		[self.components removeLastObject];		
	}	
	else if ([propertyName isEqualToString:@"DTSTART"] && [self.components count] == 0)
	{
		//printf("parse DTSTART\n");
		NSDate *date = [self parseDate:rest];
		
		self.isADE = adeCheck;
		
		//printf("start date: %s\n", [[date description] UTF8String]);
		
		if (date != nil)
		{
			self.startDate = date;
				
			[date release];
		}
	}
	else if ([propertyName isEqualToString:@"DTEND"] && [self.components count] == 0)
	{
		NSDate *date = [self parseDate:rest];
		
		//printf("end date: %s\n", [[date description] UTF8String]);
		
		if (date != nil)
		{
			self.endDate = date;
			[date release];
		}
		
	}
	else if ([propertyName isEqualToString:@"RRULE"] && ([self.components count] == 0))
	{
		[self parseRRule:rest];
	}
}

-(void) parse:(NSString *)data
{
	if (data == nil || [data isEqualToString:@""])
	{
		return;
	}
	
	[self reset];
	
	NSArray *lines = [data componentsSeparatedByString:@"\n"];
	
	for (NSString *line in lines)
	{
		[self parseLine:line];
	}
	
	//GDataDateTime *dt = [GDataDateTime dateTimeWithDate:[NSDate date] timeZone:[NSTimeZone systemTimeZone]];
	
	//printf("test date: %s\n", [[dt RFC3339String] UTF8String]);
}

-(void)dealloc
{
	[startDate release];
	[endDate release];
	[rruleDict release];
	[components release];
	[super dealloc];
}
*/
@end
