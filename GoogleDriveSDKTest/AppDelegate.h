//
//  AppDelegate.h
//  GoogleDriveSDKTest
//
//  Created by nguyen tuan dang on 4/22/17.
//  Copyright © 2017 DA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppAuth.h"
#import "GTMAppAuth.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic, strong, nullable) id<OIDAuthorizationFlowSession> currentAuthorizationFlow;

@end

