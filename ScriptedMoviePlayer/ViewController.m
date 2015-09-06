//
//  ViewController.m
//  ScriptedMoviePlayer
//
//  Created by Greg Maletic on 9/1/15.
//  Copyright (c) 2015 C3Images. All rights reserved.
//

#import "ViewController.h"
#import "Script.h"

@interface ViewController ()
@property AVPlayerViewController* avpvc;
@property Script* currentScript;
@property UIColor* desiredOverlayColor;
@end

@implementation ViewController

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.avpvc = [[AVPlayerViewController alloc] init];
	self.avpvc.showsPlaybackControls = NO;
	
	self.avpvc.view.frame = self.view.bounds;
	[self.view addSubview:self.avpvc.view];

	[[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_NEW_PLAYER object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification)
	{
		AVPlayer* player = notification.userInfo[USERINFO_KEY_PLAYER];
		NSAssert(player, @"No player");
		self.avpvc.player = player;
		[self.avpvc.player play];
		NSLog(@"PLAY");
	}];
	
	// Allow user to restart the script if things seem out of sync.
	UILongPressGestureRecognizer* restartScriptGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeRestartGesture:)];
	restartScriptGestureRecognizer.numberOfTouchesRequired = 2;
	restartScriptGestureRecognizer.minimumPressDuration = 3;
	[self.avpvc.view addGestureRecognizer:restartScriptGestureRecognizer];
	
	// Get notified in case the brightness changes, so we can change it ourselves.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(affectScreenBrightness) name:UIScreenBrightnessDidChangeNotification object:nil];

	// Kick everyting off.
	[self startScript];
}

- (void)recognizeRestartGesture:(UIGestureRecognizer*)gr
{
	if (gr.state == UIGestureRecognizerStateBegan)
	{
		[self startScript];
	}
}

- (void)startScript
{
	NSLog(@"STARTING…");
	
	[self.avpvc.player pause];
	self.avpvc.player = nil;
	
	self.currentScript = [[Script alloc] initWithScriptFile:@"script"];
	[self.currentScript process];
	
	// Take some actions based on the script.
	// Load brightness.
	[self affectScreenBrightness];

	// Do we need to enable the overlay?
	[self enableOverlay];
	
	// Show the user we're starting.
	[self flashScreen];
}

- (void)affectScreenBrightness
{
	NSNumber* brightnessNumber = self.currentScript.scriptJson[TAG_BRIGHTNESS];
	if (brightnessNumber)
	{
		CGFloat brightness = [brightnessNumber floatValue];
		[[UIScreen mainScreen] setWantsSoftwareDimming:YES];
		[[UIScreen mainScreen] setBrightness:brightness];
	}
	else
	{
		[[UIScreen mainScreen] setWantsSoftwareDimming:NO];
	}
}

- (void)enableOverlay
{
	NSNumber* overlayNumber = self.currentScript.scriptJson[TAG_OVERLAY_ALPHA];
	if (overlayNumber)
	{
		CGFloat overlayAlpha = [overlayNumber floatValue];
		if (overlayAlpha > 0)
		{
			self.desiredOverlayColor = [UIColor colorWithWhite:0 alpha:overlayAlpha];
		}
		else
		{
			self.desiredOverlayColor = nil;
		}
	}
	else
	{
		self.desiredOverlayColor = nil;
	}
	self.avpvc.contentOverlayView.backgroundColor = self.desiredOverlayColor;
}

- (void)flashScreen
{
	self.avpvc.contentOverlayView.backgroundColor = [UIColor greenColor];
	[UIView animateWithDuration:1 animations:^
	 {
		 self.avpvc.contentOverlayView.backgroundColor = self.desiredOverlayColor;
	 }];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
