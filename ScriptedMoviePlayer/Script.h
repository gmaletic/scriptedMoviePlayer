//
//  ScriptProcessor.h
//  ScriptedMoviePlayer
//
//  Created by Greg Maletic on 9/1/15.
//  Copyright (c) 2015 C3Images. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define TAG_CYCLE @"secondsToCycle"
#define TAG_FOUNDATION_IMAGE @"foundationImage"
#define TAG_SCRIPT @"script"
#define TAG_OFFSET @"secondsOffset"
#define TAG_MOVIE @"movie"
#define TAG_BRIGHTNESS @"brightness"
#define TAG_OVERLAY_ALPHA @"overlay-alpha"

#define NOTIFICATION_NEW_PLAYER @"newPlayer"
#define USERINFO_KEY_PLAYER @"player"

@interface Script : NSObject

@property UIImage* foundationImage;
@property (readonly) AVPlayer* avPlayer;
@property (readonly) NSDictionary* scriptJson;
@property NSTimeInterval synctime;

- (instancetype)initWithScriptFile:(NSString*)scriptFileName withSyncTime:(NSTimeInterval)synctime;
- (void)process;
- (void)stopTimers;

@end
