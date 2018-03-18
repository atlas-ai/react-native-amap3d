#import <React/RCTUIManager.h>
#import <AMapNaviKit/AMapNaviDriveManager.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import "AMapNavigationManager.h"
#import "AMapDrive.h"
#import "SpeechSynthesizer.h"
#import <UIKit/UIKit.h>


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

RCT_EXPORT_METHOD(stop:(nonnull NSNumber *)reactTag) {                        \
    [_navigationManager stopNavi];
    [[SpeechSynthesizer sharedSpeechSynthesizer] stopSpeak];                                         \
}

- (void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager {
    if (_navigationView.onCalculateRouteSuccess) {
        _navigationView.onCalculateRouteSuccess(nil);
        _navigationView.trackingMode = AMapNaviViewTrackingModeCarNorth;
        //将导航界面的界面元素进行隐藏，然后通过自定义的控件展示导航信息
        [_navigationView setShowUIElements:NO];
        //关闭路况显示，以展示自定义Polyline的样式
        [_navigationView setShowTrafficLayer:NO];
        
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

- (AMapNaviRoutePolylineOption *)_navigationView:(AMapNaviDriveView *)_navigationView needUpdatePolylineOptionForRoute:(AMapNaviRoute *)naviRoute
{
    NSLog(@"ChangePolyLine");
    //自定义普通路线Polyline的样式
    AMapNaviRoutePolylineOption *polylineOption = [[AMapNaviRoutePolylineOption alloc] init];
    polylineOption.lineWidth = 8;
    polylineOption.drawStyleIndexes = [NSArray arrayWithArray:naviRoute.wayPointCoordIndexes];
    polylineOption.replaceTrafficPolyline = YES;
    
    //可以使用颜色填充,也可以使用纹理图片(当同时设置时,strokeColors设置将被忽略)
    polylineOption.strokeColors = @[[UIColor purpleColor], [UIColor brownColor], [UIColor orangeColor]];
    //polylineOption.textureImages = @[[UIImage imageNamed:@"arrowTexture2"], [UIImage imageNamed:@"arrowTexture3"], [UIImage imageNamed:@"arrowTexture4"]];
    
    return polylineOption;
}

@end
