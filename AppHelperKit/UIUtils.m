
//
//  UIUtils.m
//  AppHelperKit
//
//  Created by Kan . on 19/04/17.
//  Copyright (c) 2017 KD. All rights reserved.
//

#import "UIUtils.h"
#include <sys/param.h>
#include <sys/mount.h>
#import "UIImageEffects.h"


@implementation UIUtils

@synthesize barButton;

-(void) setBackButton : (UINavigationItem *) navigationItem {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.image = [UIImage imageNamed:@"back-24.png"];
    backButton.style = UIBarButtonItemStylePlain;
    navigationItem.leftBarButtonItem = backButton;
    self.barButton = backButton;
}

+(UIAlertView *) alertWithTitle: (NSString *)title message:(NSString *) message :(NSString *) cancelBtnText :(NSString *) okBtnText delegate: (id) delegate;{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelBtnText otherButtonTitles:okBtnText, nil];
    [alert show];
    return alert;
}

+(NSString*)getCurrentTimeStamp
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    NSInteger hour = [dateComponents hour];
    NSInteger mintue = [dateComponents minute];
    NSString *currentTime = [NSString stringWithFormat:@"%02ld:%02ld",(long)hour,(long)mintue];
    return currentTime;
}

+(NSString*)getTimeStampFromDate : (NSDate*)date
{
    NSCalendar* localCalendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [localCalendar components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
    NSInteger hour = [dateComponents hour];
    NSInteger mintue = [dateComponents minute];
    NSString *currentTime = [NSString stringWithFormat:@"%02ld:%02ld",(long)hour,(long)mintue];
    return currentTime;
}

+(NSString*)getSentTimeStamp
{
    NSTimeZone *utcTimeZone = [[NSTimeZone alloc]initWithName:@"UTC"];
    NSDateFormatter* sTimeDateFormat = [[NSDateFormatter alloc] init];
    [sTimeDateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [sTimeDateFormat setTimeZone:utcTimeZone];
    NSString * timeStamp = [sTimeDateFormat stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    return timeStamp;
}

+(NSString*)getCurrentDateAndTime
{
    NSDate *myDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *GMTDateString = [dateFormatter stringFromDate: myDate];   
    return GMTDateString;
}

+ (NSData *)compressImage:(UIImage *)image withCompressionQuality:(float)compQuality
{
//    float actualHeight = image.size.height;
//    float actualWidth = image.size.width;
//    float maxHeight = 600.0;
//    float maxWidth = 800.0;
//    float imgRatio = actualWidth/actualHeight;
//    float maxRatio = maxWidth/maxHeight;
//    
//    if (actualHeight > maxHeight || actualWidth > maxWidth) {
//        if(imgRatio < maxRatio){
//            //adjust width according to maxHeight
//            imgRatio = maxHeight / actualHeight;
//            actualWidth = imgRatio * actualWidth;
//            actualHeight = maxHeight;
//        } else if (imgRatio > maxRatio) {
//            //adjust height according to maxWidth
//            imgRatio = maxWidth / actualWidth;
//            actualHeight = imgRatio * actualHeight;
//            actualWidth = maxWidth;
//        } else {
//            actualHeight = maxHeight;
//            actualWidth = maxWidth;
//        }
//    }
//    
//    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
//    UIGraphicsBeginImageContext(rect.size);
//    [image drawInRect:rect];
//    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(image, compQuality);
//    UIGraphicsEndImageContext();
    
    return imageData;
}

+ (void)compressVideoToQuality:(NSString *)videoQuality inputURL:(NSURL *)inputURL outputURL:(NSURL *)outputURL completionHandler:(void (^)(AVAssetExportSession*))handler
{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:videoQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(exportSession);
     }];
}

+ (UIImage *)getVideoAssetImage:(NSString *)filePath forSize:(CGSize)size
{
    
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:filePath] options:nil];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = TRUE;
    //Below line of code added by RAJEEV.
    imageGenerator.maximumSize = size;
    CMTime duration = [asset duration];
    CMTime thumbTime = CMTimeMake(duration.value / 2, duration.timescale);
    //CMTime thumbTime = CMTimeMakeWithSeconds(0,3);
    
    NSError *error = nil;
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:thumbTime actualTime:NULL error:&error];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    if (cgImage)
        CFRelease(cgImage);
    //Below code commented by RAJEEV, Here maximumSize value setting should be,
    //While creation of Image generator & maximumSize suppose to be equal to incoming Size.
    //imageGenerator.maximumSize = image.size;

    if (error) {
        return nil;
    }
    
    return image;
}

+ (UIImage *)getThumbnailImage:(NSString *)filePath withSize:(CGSize)size
{
    
    UIImage *originalImage = [UIImage imageWithContentsOfFile:filePath];
    
    float oldWidth = originalImage.size.width;
    float scaleFactor = size.width / oldWidth;
    
    float newHeight = originalImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [originalImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    newImage = [UIImageEffects imageByApplyingDarkEffectToImage:newImage];
    UIGraphicsEndImageContext();
    
    return newImage;
}


+ (NSNumber *) totalDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
}

+ (NSNumber *) freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

+(uint64_t)getFreeDiskspace {
    
    
    uint64_t totalFreeSpace = 0;
    
    __autoreleasing NSError *error = nil;
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:path error: &error];
    
    if (dictionary) {
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
#ifndef NDEBUG
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        uint64_t totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
#endif
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %@", [error domain], [error code]);
    }  
    
    return totalFreeSpace;

//    uint64_t totalSpace = 0;
//    uint64_t totalFreeSpace = 0;
//    NSError *error = nil;
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
//    
//    if (dictionary) {
//        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
//        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
//        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
//        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
//        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
//    } else {
//        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
//    }
//    
//    return totalFreeSpace;
    
//    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    struct statfs tStats;
//    statfs([[paths lastObject] UTF8String], &tStats);
//    float total_space = (float)(tStats.f_bavail * tStats.f_bsize);
//    
//    return total_space;

}


+(NSString*) timeStampWithFormat:timeFormat
{
    static NSDateFormatter* sTimeDateFormat = nil;
    if(!sTimeDateFormat){
        sTimeDateFormat = [[NSDateFormatter alloc] init];
        // [sChatDate setDateFormat:@"MMMM dd, yyyy HH:mm"];
        //NgnNSLog(TAG,@"timeFormat is %@",timeFormat);
        //        [sTimeDateFormat setDateFormat:timeFormat];
    }
    [sTimeDateFormat setDateFormat:timeFormat];;
    NSTimeZone *utcTimeZone = [[NSTimeZone alloc] initWithName:@"UTC"];
    [sTimeDateFormat setTimeZone:utcTimeZone];
    
    NSString * timeStamp = [sTimeDateFormat stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    //NgnNSLog(TAG,@"timeStampWithFormat: %@",timeStamp);
    
    return timeStamp;
}




+(NSString *)getDateTimeAfterTimeIntervalOf:(NSInteger)day
{
    if (day)
    {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *comps = [NSDateComponents new];
        comps.day = day;
        NSDate *days = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
        NSString *dateString = [dateFormatter stringFromDate:days];

        return dateString;
    }
    return nil;
}


+ (NSMutableArray *)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    __block NSMutableArray *emojArray = [NSMutableArray new];
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 [emojArray addObject:substring];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             [emojArray addObject:substring];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return emojArray;
}

@end
