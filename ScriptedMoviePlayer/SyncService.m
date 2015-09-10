//
//  SyncService.m
//  ScriptedMoviePlayer
//
//  Created by Greg Maletic on 9/9/15.
//  Copyright © 2015 C3Images. All rights reserved.
//

#import "SyncService.h"

#define SCRIPTED_MOVIE_PLAYER_DOMAIN @"com.c3images.scriptedMoviePlayer"
#define SYNC_SERVICE_ID @"syncService"

@interface SyncService ()
@property NSNetServiceBrowser* serviceBrowser;
@end

@implementation SyncService

+ (instancetype)sharedService
{
	static dispatch_once_t once;
	static id singleton;
	dispatch_once(&once, ^
				  {
					  singleton = [[self alloc] init];
				  });
	
	return singleton;
}

- (void)start
{
	// Look for an existing service.
	self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
	self.serviceBrowser.delegate = self;
	
	[self.serviceBrowser searchForServicesOfType:SYNC_SERVICE_ID inDomain:SCRIPTED_MOVIE_PLAYER_DOMAIN];
	
	// If not found in 10 seconds, start our own
	
}


#pragma mark - NSNetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
	[browser stop];
	
	service.delegate = self;
	[service resolveWithTimeout:10];
	
}

@end
