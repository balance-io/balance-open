//
//  CertValidator.m
//  Bal
//
//  Created by Benjamin Baron on 12/12/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

#import "CertValidator.h"
#import <TrustKit/TrustKit.h>

@implementation CertValidator

- (instancetype)init {
    if (self = [super init]) {
        NSDictionary *trustKitConfig =
        @{kTSKSwizzleNetworkDelegates: @NO,
          kTSKPinnedDomains : @{
                  @"balancemy.money" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                          kTSKPublicKeyHashes : @[@"YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg=",
                                                  @"sRHdihwgkaib1P1gxX8HFszlD+7/gTfNvuAybgLPNis="],
                          kTSKReportUris : @[@"https://www.balancemysubscription.com/certReport"]
                          }
                  }};
        
        // Silence logging and initialize
        [TrustKit setLoggerBlock: ^void (NSString *message){}];
        [TrustKit initializeWithConfiguration: trustKitConfig];
    }
    
    return self;
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    [TSKPinningValidator handleChallenge:challenge completionHandler:completionHandler];
}

@end
