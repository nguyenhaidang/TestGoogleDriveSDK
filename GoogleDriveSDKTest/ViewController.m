//
//  ViewController.m
//  GoogleDriveSDKTest
//
//  Created by nguyen tuan dang on 4/22/17.
//  Copyright © 2017 DA. All rights reserved.
//

#import "ViewController.h"
#import "GTLRDrive.h"
#import "AppAuth.h"
#import "GTMAppAuth.h"
#import "AppDelegate.h"

static NSString *const kClientID = @"326466930866-q3bkaqkesc76epod6asmjqqrslluha3u.apps.googleusercontent.com";

@interface ViewController ()

@property (nonatomic, strong) GTLRDriveService *service;
@property (nonatomic, strong) UITextView *output;
@property (nonatomic, nullable) GTMAppAuthFetcherAuthorization *authorization;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) UIViewController *secondVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create a UITextView to display output.
    self.output = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.output.editable = false;
    self.output.contentInset = UIEdgeInsetsMake(20.0, 0.0, 20.0, 0.0);
    self.output.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.output];
    
    // Initialize the Drive API service & load existing credentials from the keychain if available.
    self.service = [[GTLRDriveService alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.service.authorizer.canAuthorize) {
    
        self.secondVC = [[UIViewController alloc]init];
        [self addChildViewController:self.secondVC];
        [self.view addSubview:self.secondVC.view];
        
        NSURL *authorizationEndpoint = [NSURL URLWithString:@"https://accounts.google.com/o/oauth2/v2/auth"];
        NSURL *tokenEndpoint = [NSURL URLWithString:@"https://www.googleapis.com/oauth2/v4/token"];
        OIDServiceConfiguration *configuration = [[OIDServiceConfiguration alloc]initWithAuthorizationEndpoint:authorizationEndpoint tokenEndpoint:tokenEndpoint];
        
        OIDAuthorizationRequest *request =
        [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                      clientId:kClientID
                                                  clientSecret:@""
                                                        scopes:@[OIDScopeOpenID, OIDScopeProfile,kGTLRAuthScopeDrive]
                                                   redirectURL:[NSURL URLWithString:@"com.googleusercontent.apps.326466930866-q3bkaqkesc76epod6asmjqqrslluha3u:/oauthredirect"]
                                                  responseType:OIDResponseTypeCode
                                          additionalParameters:nil];
        // performs authentication request
        self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        self.appDelegate.currentAuthorizationFlow =
        [OIDAuthState authStateByPresentingAuthorizationRequest:request presentingViewController:self.secondVC callback:^(OIDAuthState * _Nullable authState, NSError * _Nullable error) {
            if (authState) {
                // Creates the GTMAppAuthFetcherAuthorization from the OIDAuthState.
                GTMAppAuthFetcherAuthorization *authorization =
                [[GTMAppAuthFetcherAuthorization alloc] initWithAuthState:authState];
                self.service.authorizer = authorization;
                [self.secondVC dismissViewControllerAnimated:true completion:nil];
            } else {
                NSLog(@"Authorization error: %@", [error localizedDescription]);
                self.authorization = nil;
            }
        }];
    } else {
        [self listFiles];
    }
}

// List up to 10 files in Drive
- (void)listFiles {
    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    query.fields = @"nextPageToken, files(id, name)";
    query.pageSize = 10;
    
    [self.service executeQuery:query
                      delegate:self
             didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// Process the response and display output
- (void)displayResultWithTicket:(GTLRServiceTicket *)ticket
             finishedWithObject:(GTLRDrive_FileList *)result
                          error:(NSError *)error {
    if (error == nil) {
        NSMutableString *output = [[NSMutableString alloc] init];
        if (result.files.count > 0) {
            [output appendString:@"Files:\n"];
            int count = 1;
            for (GTLRDrive_File *file in result.files) {
                [output appendFormat:@"%@ (%@)\n", file.name, file.identifier];
                count++;
            }
        } else {
            [output appendString:@"No files found."];
        }
        self.output.text = output;
    } else {
        NSMutableString *message = [[NSMutableString alloc] init];
        [message appendFormat:@"Error getting presentation data: %@\n", error.localizedDescription];
        [self showAlert:@"Error" message:message];
    }
}

// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
     {
         [alert dismissViewControllerAnimated:YES completion:nil];
     }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
}

@end
