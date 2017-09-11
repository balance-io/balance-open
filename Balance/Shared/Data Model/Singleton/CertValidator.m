//
//  CertValidator.m
//  Bal
//
//  Created by Benjamin Baron on 12/12/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

#import "CertValidator.h"
#import <TrustKit/TrustKit.h>

const NSString *balanceReportUri = @"https://www.balancemysubscription.com/certReport";

// Let's Encrypt
const NSString *letsEncryptAuthorityX3     = @"YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg="; // Let's Encrypt Authority X3
const NSString *dstRootCAX3                = @"sRHdihwgkaib1P1gxX8HFszlD+7/gTfNvuAybgLPNis="; // DST Root CA X3

// DigiCert
const NSString *digiCertSHA2SecureServerCA = @"5kJvNEMw0KjrCAu7eXY5HZdvyCS13BbA0VJG1RSP91w="; // DigiCert SHA2 Secure Server CA
const NSString *digiCertGlobalRootCA       = @"r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E="; // DigiCert Global Root CA

// GlobalSign
const NSString *alphaSSLCASHA256G2         = @"amMeV6gb9QNx0Zf7FtJ19Wa/t2B7KpCF/1n2Js3UuSU="; // AlphaSSL CA - SHA256 - G2
const NSString *globalSignRootR1           = @"K87oWBWM9UZfyddvDfoxL+8lpNyoUB2ptGtn0fv6G2Q="; // GlobalSign Root R1 (note this shows up as GlobalSign Root CA in Safari, but according to GlobalSign, AlphaSSL uses their R1 root cert: https://support.globalsign.com/customer/portal/articles/1426602-globalsign-root-certificates

// Google App Engine
const NSString *googleInternetAuthorityG2  = @"h6801m+z8v3zbgkRHpq6L29Esgfzhj89C1SyUCOQmqU="; // Google Internet Authority G2
const NSString *geoTrustGlobalCA           = @"7HIpactkIAq2Y49orFOOQKurWxmmSFZhBCoQYcRhJ3Y="; // GeoTrust Global CA

@interface CertValidator() {
    TSKPinningValidator *_pinningValidator;
}
@end

@implementation CertValidator
    
- (instancetype)init {
    if (self = [super init]) {
        _pinningValidator = [[TSKPinningValidator alloc] init];
        NSDictionary *trustKitConfig =
        @{kTSKSwizzleNetworkDelegates: @NO,
          kTSKPinnedDomains : @{
                  @"sandbox.plaid.com" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                          kTSKPublicKeyHashes : @[digiCertSHA2SecureServerCA, digiCertGlobalRootCA],
                          kTSKReportUris : @[balanceReportUri]
                          },
                  @"production.plaid.com" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                          kTSKPublicKeyHashes : @[digiCertSHA2SecureServerCA, digiCertGlobalRootCA],
                          kTSKReportUris : @[balanceReportUri]
                          },
                  @"www.balancemysubscription.com" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                          kTSKPublicKeyHashes : @[letsEncryptAuthorityX3, dstRootCAX3],
                          kTSKReportUris : @[balanceReportUri]
                          },
                  @"bal-subscription-server-beta.appspot.com" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                          kTSKPublicKeyHashes : @[googleInternetAuthorityG2, geoTrustGlobalCA],
                          kTSKReportUris : @[balanceReportUri]
                          },
                  @"balancemy.money" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                          kTSKPublicKeyHashes : @[letsEncryptAuthorityX3, dstRootCAX3],
                          kTSKReportUris : @[balanceReportUri]
                          },
                  @"sync.balancemy.money" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                          kTSKPublicKeyHashes : @[letsEncryptAuthorityX3, dstRootCAX3],
                          kTSKReportUris : @[balanceReportUri]
                          },
                  @"api.coinbase.com" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                          kTSKPublicKeyHashes : @[digiCertSHA2SecureServerCA, digiCertGlobalRootCA],
                          kTSKReportUris : @[balanceReportUri]
                          },
                  @"api.gdax.com" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                          kTSKPublicKeyHashes : @[digiCertSHA2SecureServerCA, digiCertGlobalRootCA],
                          kTSKReportUris : @[balanceReportUri]
                          },
                  @"poloniex.com" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                          kTSKPublicKeyHashes : @[alphaSSLCASHA256G2, globalSignRootR1],
                          kTSKReportUris : @[balanceReportUri]
                          }
                  }};
        
        // Silence logging and initialize
        [TrustKit setLoggerBlock: ^void (NSString *message){}];
        [TrustKit initSharedInstanceWithConfiguration: trustKitConfig];
    }
    
    return self;
}
    
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    [_pinningValidator handleChallenge:challenge completionHandler:completionHandler];
}
    
@end
