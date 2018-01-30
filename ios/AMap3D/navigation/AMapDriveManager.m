#import <React/RCTUIManager.h>
#import <AMapNaviKit/AMapNaviDriveManager.h>
#import "AMapNavigationManager.h"
#import "AMapDrive.h"
#import "SpeechSynthesizer.h"

@interface AMapDriveManager : RCTViewManager <AMapNaviDriveManagerDelegate>
+ (AMapDrive *)navigationView;
+ (AMapNaviDriveManager *)navigationManager;
@end

@implementation AMapDriveManager {
    AMapDrive *_navigationView;
    AMapNaviDriveManager *_navigationManager;
}

INIT(AMapDriveManager)
NAVIGATION_VIEW(AMapDrive)
NAVIGATION_MANAGER(AMapDriveManager, AMapNaviDriveManager)

RCT_EXPORT_METHOD(calculateRoute:(nonnull NSNumber *)reactTag
                           start:(AMapNaviPoint *)start
                             end:(AMapNaviPoint *)end
                             way:(NSArray<AMapNaviPoint *> *)way) {
    [_navigationManager calculateDriveRouteWithStartPoints:@[start]
                                                 endPoints:@[end]
                                                 wayPoints:way
                                           drivingStrategy:AMapNaviDrivingStrategySingleDefault];
}

- (void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager {
    if (_navigationView.onCalculateRouteSuccess) {
        _navigationView.onCalculateRouteSuccess(nil);
    }
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteFailure:(NSError *)error {
    if (_navigationView.onCalculateRouteFailure) {
        _navigationView.onCalculateRouteFailure(@{
                @"code": @(error.code),
        });
    }
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{
    
    NSLog(@"playNaviSoundString:{%ld:%@}", (long)soundStringType, soundString);

    [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:soundString];
}

@end
