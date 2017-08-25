//
//  CertValidator.m
//  Bal
//
//  Created by Benjamin Baron on 12/12/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

#import "CertValidator.h"
#import <TrustKit/TrustKit.h>

@interface CertValidator ()
    @property (nonatomic, readonly, strong) TSKPinningValidator* pinningValidator;
    @end

@implementation CertValidator
    
- (instancetype)init {
    if (self = [super init]) {
        _pinningValidator = [[TSKPinningValidator alloc] init];
        NSDictionary *trustKitConfig =
        @{kTSKSwizzleNetworkDelegates: @NO,
          kTSKPinnedDomains : @{
                  @"api.plaid.com" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                          kTSKPublicKeyHashes : @[@"UCNW3UCkRyrwx+B2lu8hy8wTgOxKj3xeka6IYYKhm1Q=",
                                                  @"WoiWRyIOVNa9ihaBciRSC7XHjliYS9VwUGOIud4PB18="],
                          kTSKReportUris : @[@"https://www.balancemysubscription.com/ce.r.t.R.e.p.o.r.t"]
                          },
                  @"www.balancemysubscription.com" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                          kTSKPublicKeyHashes : @[@"YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg=",
                                                  @"sRHdihwgkaib1P1gxX8HFszlD+7/gTfNvuAybgLPNis="],
                          kTSKReportUris : @[@"https://www.balancemysubscription.com/certReport"]
                          },
                  @"bal-subscription-server-beta.appspot.com" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                          kTSKPublicKeyHashes : @[@"h6801m+z8v3zbgkRHpq6L29Esgfzhj89C1SyUCOQmqU=",
                                                  @"7HIpactkIAq2Y49orFOOQKurWxmmSFZhBCoQYcRhJ3Y="],
                          kTSKReportUris : @[@"https://www.balancemysubscription.com/certReport"]
                          },
                  @"balancemy.money" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                          kTSKPublicKeyHashes : @[@"YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg=",
                                                  @"sRHdihwgkaib1P1gxX8HFszlD+7/gTfNvuAybgLPNis="],
                          kTSKReportUris : @[@"https://www.balancemysubscription.com/certReport"]
                          },
                  @"sync.balancemy.money" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                          kTSKPublicKeyHashes : @[@"YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg=",
                                                  @"sRHdihwgkaib1P1gxX8HFszlD+7/gTfNvuAybgLPNis="],
                          kTSKReportUris : @[@"https://www.balancemysubscription.com/certReport"]
                          },
                  @"api.coinbase.com" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                          kTSKPublicKeyHashes : @[@"5kJvNEMw0KjrCAu7eXY5HZdvyCS13BbA0VJG1RSP91w=",
                                                  @"r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E="],
                          kTSKReportUris : @[@"https://www.balancemysubscription.com/certReport"]
                          }
                  }};
        
        // Silence logging and initialize
        [TrustKit setLoggerBlock: ^void (NSString *message){}];
        [TrustKit initSharedInstanceWithConfiguration: trustKitConfig];
    }
    
    return self;
}
    
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    [self.pinningValidator handleChallenge:challenge completionHandler:completionHandler];
}
    
@end
