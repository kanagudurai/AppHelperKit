//
//  UIUtils.h
//  AppHelperKit
//
//  Created by Kan . on 19/04/17.
//  Copyright (c) 2017 KD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
@interface UIUtils : NSObject {
    
}

@property (strong, nonatomic) UIBarButtonItem *barButton;

-(void) setBackButton : (UINavigationItem *) navigationItem;

+(UIAlertView *) alertWithTitle: (NSString *)title message:(NSString *) message :(NSString *) cancelBtnText :(NSString *) okBtnText delegate: (id) delegate;

+(NSString*)getCurrentTimeStamp;

+(NSString*)getCurrentDateAndTime;

+(NSString*)getSentTimeStamp;

+(NSString*)getTimeStampFromDate : (NSDate*)date;

+ (NSData *)compressImage:(UIImage *)image withCompressionQuality:(float)compQuality;

+ (void)compressVideoToQuality:(NSString *)videoQuality inputURL:(NSURL *)inputURL outputURL:(NSURL *)outputURL completionHandler:(void (^)(AVAssetExportSession*))handler;

+ (UIImage *)getVideoAssetImage:(NSString *)filePath forSize:(CGSize)size;

+ (UIImage *)getThumbnailImage:(NSString *)filePath withSize:(CGSize)size;

+(NSString*) timeStampWithFormat:timeFormat;

+(NSString *)getDateTimeAfterTimeIntervalOf:(NSInteger)day;

+(uint64_t)getFreeDiskspace;

+ (NSNumber *) totalDiskSpace;

+ (NSNumber *) freeDiskSpace;

+ (NSMutableArray *)stringContainsEmoji:(NSString *)string;

@end
