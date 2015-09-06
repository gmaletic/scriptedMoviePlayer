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
@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.avpvc = [[AVPlayerViewController alloc] init];
	self.avpvc.showsPlaybackControls = NO;
	
	self.avpvc.view.frame = self.view.bounds;
	[self.view addSubview:self.avpvc.view];

	[self startScript];

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
	restartScriptGestureRecognizer.numberOfTouchesRequired = 1;
	restartScriptGestureRecognizer.minimumPressDuration = 3;
	[self.avpvc.view addGestureRecognizer:restartScriptGestureRecognizer];
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
	
	[self flashScreen];
}

- (void)flashScreen
{
	self.avpvc.contentOverlayView.backgroundColor = [UIColor greenColor];
	[UIView animateWithDuration:1 animations:^
	 {
		 self.avpvc.contentOverlayView.backgroundColor = [UIColor clearColor];
	 }];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
