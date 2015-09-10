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

#define TAG_ALL_DEVICES @"*"
#define TAG_MAIN_SCRIPT @"main"
#define TAG_CYCLE @"seconds-to-cycle"
#define TAG_FOUNDATION_IMAGE @"foundation-image"
#define TAG_SCRIPT @"script"
#define TAG_OFFSET @"seconds-offset"
#define TAG_MOVIE @"movie"
#define TAG_BRIGHTNESS @"brightness"
#define TAG_OVERLAY_ALPHA @"overlay-image"

#define NOTIFICATION_NEW_PLAYER @"newPlayer"
#define USERINFO_KEY_PLAYER @"player"

@interface Script : NSObject

@property (readonly) AVPlayer* avPlayer;
@property (readonly) NSDictionary* deviceJson;
@property NSTimeInterval synctime;

- (instancetype)initWithScriptFile:(NSString*)scriptFileName withSyncTime:(NSTimeInterval)synctime;
- (void)process;
- (void)stopTimers;

@end
