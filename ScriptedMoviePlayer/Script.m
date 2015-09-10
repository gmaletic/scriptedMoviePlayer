//
//  ScriptProcessor.m
//  ScriptedMoviePlayer
//
//  Created by Greg Maletic on 9/1/15.
//  Copyright (c) 2015 C3Images. All rights reserved.
//

#import "Script.h"

@interface Script ()
@property (readwrite) AVPlayer* avPlayer;
@property NSString* scriptFileName;
@property NSMutableArray* timers;
@property (readwrite) NSDictionary* scriptJson;
@end

#define TIME_INTERVAL_START_AFTER_SYNC 2

@implementation Script

- (instancetype)initWithScriptFile:(NSString *)scriptFileName withSyncTime:(NSTimeInterval)synctime
{
	if ((self = [super init]))
	{
		_timers = [NSMutableArray array];
		_scriptFileName = scriptFileName;
		_synctime = synctime;
	}
	
	return self;
}

- (instancetype)init
{
	NSAssert(NO, @"Use initWithScriptFile:");
	return nil;
}

- (void)dealloc
{
	[self stopTimers];
}

- (void)stopTimers
{
	// Stop all timers.
	for (NSTimer* timer in self.timers)
	{
		[timer invalidate];
	}
}

- (void)process
{
	[self processScriptFile:self.scriptFileName];
}

- (void)processScriptFile:(NSString *)scriptFileName
{
	NSString* scriptPath = [[NSBundle mainBundle] pathForResource:scriptFileName ofType:@"json"];
	NSAssert(scriptPath, @"Script not found");
	
	// Load script JSON
	NSData* scriptData = [NSData dataWithContentsOfFile:scriptPath];
	NSAssert(scriptData, @"No script loaded from %@", scriptPath);
	
	NSError* jsonError;
	NSDictionary* scriptJson = [NSJSONSerialization JSONObjectWithData:scriptData options:0 error:&jsonError];
	NSAssert(scriptJson, @"No scriptJson loaded.");
	
	// Load cycle time.
	NSNumber* jsonCycleTime = scriptJson[TAG_CYCLE];
	NSAssert(jsonCycleTime, @"Need to specify '%@' attribute at top level of script file named %@.", TAG_CYCLE, scriptFileName);
	NSTimeInterval cycleTime = [jsonCycleTime doubleValue];
	
	// Load foundation image.
	NSString* foundationImageName = scriptJson[TAG_FOUNDATION_IMAGE];
	if (foundationImageName.length > 0)
	{
		self.foundationImage = [UIImage imageNamed:foundationImageName];
		NSAssert(self.foundationImage, @"Couldn't find foundation image at %@", foundationImageName);
	}
	
	// Create timers
	NSArray* scriptElements = scriptJson[TAG_SCRIPT];
	for (NSDictionary* scriptElement in scriptElements)
	{
		NSNumber* offsetNumber = scriptElement[TAG_OFFSET];
		NSAssert(offsetNumber, @"Need an '%@' tag in each script element.", TAG_OFFSET);
		NSTimeInterval offset = [offsetNumber doubleValue];
		
		NSString* movieFileName = scriptElement[TAG_MOVIE];
		NSAssert(movieFileName, @"Need a '%@' tag in each script element.", TAG_MOVIE);
		
		// Start the repeating timer that kicks off the movie.
		NSTimeInterval delay = [self intervalUntilCycleTime:cycleTime baseTime:self.synctime] + offset;
		NSLog(@"Play %@ every %g seconds after %g delay.", movieFileName, cycleTime, delay);
		
		__weak Script* weakSelf = self;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
		{
			NSDictionary* userInfo = @{ TAG_MOVIE : movieFileName };
			__weak NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:cycleTime target:weakSelf selector:@selector(startMovie:) userInfo:userInfo repeats:YES];
			[timer fire];
			
			[weakSelf.timers addObject:timer];
		});
	}
	
	self.scriptJson = scriptJson;
}

- (NSTimeInterval)intervalUntilCycleTime:(NSTimeInterval)cycleTime baseTime:(NSTimeInterval)baseTime
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	NSTimeInterval timeUntil = cycleTime - fmod(now - baseTime + (cycleTime - TIME_INTERVAL_START_AFTER_SYNC), cycleTime);
	return timeUntil;
}

- (void)startMovie:(NSTimer*)timer
{
	// Play movie.
	NSString* moviePath = [[NSBundle mainBundle] pathForResource:timer.userInfo[TAG_MOVIE] ofType:@"mov"];
	NSLog(@"Kicking off movie %@…", moviePath);
	BOOL movieExists = [[NSFileManager defaultManager] fileExistsAtPath:moviePath];
	NSAssert(movieExists, @"Movie at %@ doesn't exist!", moviePath);
	NSURL* movieURL = [NSURL fileURLWithPath:moviePath];
	self.avPlayer = [AVPlayer playerWithURL:movieURL];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NEW_PLAYER object:nil userInfo:@{ USERINFO_KEY_PLAYER : self.avPlayer} ];
}

@end
