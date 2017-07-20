/**
 *  Copyright 2014 Nest Labs Inc. All Rights Reserved.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

#import "NestAuthManager.h"
#import "Constants.h"
#import "AccessToken.h"

@interface NestAuthManager ()

@property (nonatomic, strong) NSMutableData *responseData;

@end

@implementation NestAuthManager

/**
 * Get the shared manager singleton.
 * @return The singleton object
 */
+ (NestAuthManager *)sharedManager {
	static dispatch_once_t once;
	static NestAuthManager *instance;
    
	dispatch_once(&once, ^{
		instance = [[NestAuthManager alloc] init];
	});
    
	return instance;
}


/**
 * Checks whether or not the current session is authenticated by checking for the
 * authorization token and making sure it is not expired.
 * @return YES if valid session, NO if invalid session.
 */
- (BOOL)isValidSession
{
    if ([self accessToken]) {
        return true;
    } else {
        return false;
    }
}

/**
 * Get the URL to get the authorizationcode.
 * @return The URL to get the authorization code (the login with nest screen).
 */
- (NSString *)authorizationURL
{
    // First get the client id
    NSString *clientId = [[NSUserDefaults standardUserDefaults] valueForKey:@"clientId"];
    if (clientId) {
        return [NSString stringWithFormat:@"https://%@/login/oauth2?client_id=%@&state=%@", NestCurrentAPIDomain, clientId, NestState];
    } else {
        NSLog(@"Missing the Client ID");
        return nil;
    }
}

/**
 * Get the URL to deauthorize the connection.
 * @return The URL to deauthorize the connection.
 */
- (NSString *)deauthorizationURL
{
    // Get the access token
    NSString *authBearer = [NSString stringWithFormat:@"%@",
                            [[NestAuthManager sharedManager] accessToken]];
    
    return [NSString stringWithFormat:@"https://api.%@/oauth2/access_tokens/%@", NestCurrentAPIDomain, authBearer];
}

/**
 * Get the URL for to get the access key.
 * @return The URL to get the access token from Nest.
 */
- (NSString *)accessURL
{
    NSString *clientId = [[NSUserDefaults standardUserDefaults] valueForKey:@"clientId"];
    NSString *clientSecret = [[NSUserDefaults standardUserDefaults] valueForKey:@"clientSecret"];
    NSString *authorizationCode = [[NSUserDefaults standardUserDefaults] valueForKey:@"authorizationCode"];
    
    if (clientId && clientSecret && authorizationCode) {
        return [NSString stringWithFormat:@"https://api.%@/oauth2/access_token?code=%@&client_id=%@&client_secret=%@&grant_type=authorization_code", NestCurrentAPIDomain, authorizationCode, clientId, clientSecret];
    } else {
        if (!clientSecret) {
            NSLog(@"Missing Client Secret");
        }
        if (!clientId) {
            NSLog(@"Missing Client ID");
        }
        if (!authorizationCode) {
            NSLog(@"Missing authorization code");
        }
        return nil;
    }
}

/**
 * Get the access token (if there is one).
 * @return The access token for this session. String is nil if no access token.
 */
- (NSString *)accessToken
{
    NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    
    // If there is nothing there -- return
    if (!encodedObject) {
        return nil;
    }
    AccessToken *at = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    if ([at isValid]) {
        return at.token;
    } else {
        return nil;
    }
}



/**
 * Set the authorization code.
 * @param The authorization code you wish to write to NSUserdefaults.
 */
- (void)setAuthorizationCode:(NSString *)authorizationCode
{
    [[NSUserDefaults standardUserDefaults] setObject:authorizationCode forKey:@"authorizationCode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self exchangeCodeForToken];
}

/**
 * Set the acccess token.
 * @param accessToken The access token you wish to set.
 * @param expiration The expiration of the token (long).
 */
- (void)setAccessToken:(NSString *)accessToken withExpiration:(long)expiration
{
    AccessToken *nat = [AccessToken tokenWithToken:accessToken expiresIn:expiration];
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:nat];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:@"accessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 * Remove the access token and authorization code from storage
 *    upon deauthorization.
 */
- (void)removeAuthorizationData
{
    
    // If an access token exists, delete it
    NSData *encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    
    if (encodedObject) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"accessToken"];
        
        //NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        NSLog(@"removeAccessToken");
    }
    
    // If an authorization code exists, delete it
    encodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"authorizationCode"];

    if (encodedObject) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"authorizationCode"];
        
        NSLog(@"removeAuthorizationCode");
    }
    
}

/**
 * Set the client's ID.
 * @param clientId The client. Generally set in the app delegate
 */
- (void)setClientId:(NSString *)clientId
{
    [[NSUserDefaults standardUserDefaults] setObject:clientId forKey:@"clientId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 * Set the client's secret.
 * @param clientSecret The client's secret. Generally set in the app delegate
 */
- (void)setClientSecret:(NSString *)clientSecret
{
    [[NSUserDefaults standardUserDefaults] setObject:clientSecret forKey:@"clientSecret"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

/**
 * Exchanges the authorization code for an access token.
 */
- (void)exchangeCodeForToken
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Create the response data
    self.responseData = [[NSMutableData alloc] init];
    
    // Get the accessURL
    NSString *accessURL = [self accessURL];
    
    // For the POST request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:accessURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"form-data" forHTTPHeaderField:@"Content-Type"];
    
    // Assign the session to the main queue so the call happens immediately
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    [[session dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
          
          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
          NSLog(@"AuthManager Token Response Status Code: %ld", (long)[httpResponse statusCode]);
          
          [self.responseData appendData:data];
          
          // The request is complete and data has been received
          // You can parse the stuff in your instance variable now
          NSDictionary* json = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                               options:kNilOptions
                                                                 error:&error];
          
          // Store the access key
          long expiresIn = [[json objectForKey:@"expires_in"] longValue];
          NSString *accessToken = [json objectForKey:@"access_token"];
          [self setAccessToken:accessToken withExpiration:expiresIn];
          
          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
          
      }] resume];

}

#pragma mark - NestControlsViewControllerDelegate Methods

/**
 * Called from NestControlsViewControllerDelegate, lets
 * the AuthManager know to deauthorize the Works with Nest connection
 */
- (void)deauthorizeConnection
{
    
    NSLog(@"deauthorizeConnection");

    // Get the deauthorizationURL
    NSString *deauthURL = [self deauthorizationURL];
    
    // Create the DELETE request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:deauthURL]];
    [request setHTTPMethod:@"DELETE"];
    
    // Assign the session to the main queue so the call happens immediately
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    [[session dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
          
          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
          NSLog(@"AuthManager Delete Response Status Code: %ld", (long)[httpResponse statusCode]);
          
      }] resume];

    // Delete the access token and authorization code from storage
    [self removeAuthorizationData];
    
}

@end
