//
//  CertValidator.m
//  Bal
//
//  Created by Benjamin Baron on 12/12/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

#import "CertValidator.h"
#import <TrustKit/TrustKit.h>

//const NSString *balanceReportUri = @"http://localhost:8080/certReport";
const NSString *balanceReportUri = @"https://api.balancemy.money/certReport";

// NOTE: To get the intermediate and root cert hashes, go to https://www.ssllabs.com/ssltest/analyze.html
//       and enter the URL you want to check. Expand the Certificate #1 section and in the Certification Paths
//       section, use the Pin SHA256 value for each certificate.

// Let's Encrypt
const NSString *letsEncryptAuthorityX3                  = @"YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg="; // Let's Encrypt Authority X3
const NSString *dstRootCAX3                             = @"sRHdihwgkaib1P1gxX8HFszlD+7/gTfNvuAybgLPNis="; // DST Root CA X3

// DigiCert
const NSString *digiCertSHA2SecureServerCA              = @"5kJvNEMw0KjrCAu7eXY5HZdvyCS13BbA0VJG1RSP91w="; // DigiCert SHA2 Secure Server CA
const NSString *digiCertGlobalRootCA                    = @"r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E="; // DigiCert Global Root CA

// GlobalSign
const NSString *alphaSSLCASHA256G2                      = @"amMeV6gb9QNx0Zf7FtJ19Wa/t2B7KpCF/1n2Js3UuSU="; // AlphaSSL CA - SHA256 - G2
const NSString *globalSignRootR1                        = @"K87oWBWM9UZfyddvDfoxL+8lpNyoUB2ptGtn0fv6G2Q="; // GlobalSign Root R1 (note this shows up as GlobalSign Root CA in Safari, but according to GlobalSign, AlphaSSL uses their R1 root cert: https://support.globalsign.com/customer/portal/articles/1426602-globalsign-root-certificates

// Google App Engine (Old)
const NSString *googleInternetAuthorityG2               = @"h6801m+z8v3zbgkRHpq6L29Esgfzhj89C1SyUCOQmqU="; // Google Internet Authority G2
const NSString *geoTrustGlobalCA                        = @"7HIpactkIAq2Y49orFOOQKurWxmmSFZhBCoQYcRhJ3Y="; // GeoTrust Global CA

// Google App Engine (New)
const NSString *googleInternetAuthorityG3               = @"f8NnEFZxQ4ExFOhSN7EiFWtiudZQVD2oY60uauV/n78="; // Google Internet Authority G3
const NSString *globalSign                              = @"7HIpactkIAq2Y49orFOOQKurWxmmSFZhBCoQYcRhJ3Y="; // GlobalSign

// Comodo ECC (Cloudflare SSL)
const NSString *COMODOECCCertificationAuthority         = @"58qRu/uxh4gFezqAcERupSkRYBlBAvfcw7mEjGPLnNU="; // COMODO ECC Certification Authority (note this uses kTSKAlgorithmEcDsaSecp384r1)
const NSString *COMODOECCDomainValidationSecureServerCA = @"EohwrK1N7rr3bRQphPj4j2cel+B2d0NNbM9PWHNDXpM="; // COMODO ECC Domain Validation Secure Server CA 2 (note this uses kTSKAlgorithmEcDsaSecp256r1)

// Comodo RSA
const NSString *COMODORSADomainValidationSecureServerCA = @"klO23nT2ehFDXCfx3eHTDRESMz3asj1muO+4aIdjiuY="; // COMODO RSA Domain Validation Secure Server CA
const NSString *COMODORSACertificationAuthority         = @"grX4Ta9HpZx6tSHkmCrvpApTQGo67CYDnvprLg5yRME="; // COMODO RSA Certification Authority (note this uses kTSKAlgorithmRsa4096)

@implementation CertValidator
    
- (instancetype)init {
    if (self = [super init]) {
        NSDictionary *trustKitConfig =
        @{kTSKSwizzleNetworkDelegates: @NO,
          kTSKPinnedDomains : @{
                  // Balance backend servers
                  @"balancemy.money" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                          kTSKPublicKeyHashes : @[letsEncryptAuthorityX3, dstRootCAX3],
                          kTSKReportUris : @[balanceReportUri]
                          },
                  @"api.balancemy.money" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                          kTSKPublicKeyHashes : @[letsEncryptAuthorityX3, dstRootCAX3],
                          kTSKReportUris : @[balanceReportUri]
                          },
                  @"countly.balancemy.money" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048],
                          kTSKPublicKeyHashes : @[letsEncryptAuthorityX3, dstRootCAX3],
                          kTSKReportUris : @[balanceReportUri]
                          },
                  @"exchangerates.balancemy.money" : @{
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
                  
                  // Exchange API Servers
                  @"api.bitfinex.com" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmEcDsaSecp384r1, kTSKAlgorithmEcDsaSecp256r1],
                          kTSKPublicKeyHashes : @[COMODOECCDomainValidationSecureServerCA, COMODOECCCertificationAuthority],
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
                          },
                  @"api.kraken.com" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmEcDsaSecp384r1, kTSKAlgorithmEcDsaSecp256r1],
                          kTSKPublicKeyHashes : @[COMODOECCDomainValidationSecureServerCA, COMODOECCCertificationAuthority],
                          kTSKReportUris : @[balanceReportUri]
                          },
                  @"bittrex.com" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmEcDsaSecp384r1, kTSKAlgorithmEcDsaSecp256r1],
                          kTSKPublicKeyHashes : @[COMODOECCDomainValidationSecureServerCA, COMODOECCCertificationAuthority],
                          kTSKReportUris : @[balanceReportUri]
                          },
                  @"api.ethplorer.io" : @{
                          kTSKEnforcePinning : @YES,
                          kTSKPublicKeyAlgorithms : @[kTSKAlgorithmRsa2048, kTSKAlgorithmRsa4096],
                          kTSKPublicKeyHashes : @[COMODORSADomainValidationSecureServerCA, COMODORSACertificationAuthority],
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
    [[[TrustKit sharedInstance] pinningValidator] handleChallenge:challenge completionHandler:completionHandler];
}
    
@end
