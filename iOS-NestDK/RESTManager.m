/**
 *  Copyright 2017 Nest Labs Inc. All Rights Reserved.
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

#import <Foundation/Foundation.h>
#import "NestAuthManager.h"
#import "RESTManager.h"
#import "Constants.h"

@interface RESTManager ()

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSString *redirectURL;

@end

@implementation RESTManager

/**
 * Creates or retrieves the shared REST manager.
 * @return The singleton shared REST manager
 */
+ (RESTManager *)sharedManager {
    static dispatch_once_t once;
    static RESTManager *instance;
    
    dispatch_once(&once, ^{
        instance = [[RESTManager alloc] init];
    });
    
    return instance;
}

/**
 * Get the URL to get the authorizationcode.
 * @return The URL to get the authorization code (the login with nest screen).
 */
- (NSString *)endpointURL
{
    NSString *endpoint = [[NSUserDefaults standardUserDefaults] valueForKey:@"endpointURL"];
    if (endpoint) {
        return [NSString stringWithFormat:@"%@", endpoint];
    } else {
        NSLog(@"Missing the API Endpoint");
        return nil;
    }
}

/**
 * Set the client's ID.
 * @param clientId The client. Generally set in the app delegate
 */
- (void)setRootEndpoint:(NSString *)rootURL
{
    [[NSUserDefaults standardUserDefaults] setObject:rootURL forKey:@"rootURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)getData:(NSString *)endpoint success:(void (^)(NSDictionary *response))success redirect:(void (^)(NSHTTPURLResponse *responseURL))redirect failure:(void(^)(NSError* error))failure {

    // making a GET request
    NSString *authBearer = [NSString stringWithFormat:@"Bearer %@",
                            [[NestAuthManager sharedManager] accessToken]];
    
    NSString *targetURL = [NSString stringWithFormat:@"%@/%@", NestAPIEndpoint, endpoint];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setHTTPMethod:@"GET"];
    //[request setValue:@"text/event-stream" forHTTPHeaderField:@"Accept"];
    //[request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:authBearer forHTTPHeaderField:@"Authorization"];
    [request setURL:[NSURL URLWithString:targetURL]];
    
    NSLog(@"RESTManager Request %@", request);
    
    //NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    //[connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    //[connection start];
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //EventSource *source = [EventSource eventSourceWithURL:[NSURL URLWithString:targetURL] mobileKey:authBearer];
    //[source onMessage:^(Event *e) {
    //    NSLog(@"%@: %@", e.event, e.data);
    //}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    [[session dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
          NSLog(@"RESTManager Response Status Code: %ld", (long)[httpResponse statusCode]);
          
          if ((long)[httpResponse statusCode] == 401) {
              self.redirectURL = [NSString stringWithFormat:@"%@", [httpResponse URL]];
              redirect(httpResponse);
          }
          else if (error)
              failure(error);
          else {
              NSDictionary *requestJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
              NSLog(@"RESTManager REST data received");
              success(requestJSON);
          }

    }] resume];
    
    
    // From Postman
    
    //NSDictionary *headers = @{ @"content-type": @"application/json",
    //                           @"authorization": @"Bearer c.01zPaezETxsVPRh28878orsKdt2hS9D9ljb8omu21pgT68AFW4kG120xTZDPyUFc3cvTWG56mJ0NOvhJfyhtMVSq4z4IAjRJKMxzSy0KzstGWzDjOWdy09yuKUqBtrKFSuy9FcxFsOivR5d2",
    //                           @"cache-control": @"no-cache",
    //                          @"postman-token": @"671def1e-caf7-3755-29ad-5fa2b105fcc9" };
    
    //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://developer-api.nest.com/structures"]
    //                                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
    //                                                   timeoutInterval:10.0];
    //[request setHTTPMethod:@"GET"];
    //[request setAllHTTPHeaderFields:headers];
    
    //NSURLSession *session = [NSURLSession sharedSession];
    //NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
    //                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    //                                                if (error) {
    //                                                    NSLog(@"%@", error);
    //                                                } else {
    //                                                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    //                                                    NSLog(@"%@", httpResponse);
    //                                                    NSDictionary *requestJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    //                                                    NSLog(@"POSTMAN REST data received: %@ %@", requestJSON, response);
    //                                                }
    //                                            }];
    //[dataTask resume];

}

- (void)getDataRedirect:(NSString *)endpoint success:(void (^)(NSDictionary *response))success failure:(void(^)(NSError* error))failure {
    
    // making a GET request
    NSString *authBearer = [NSString stringWithFormat:@"Bearer %@",
                            [[NestAuthManager sharedManager] accessToken]];
    
    NSString *targetURL = [NSString stringWithFormat:@"%@", endpoint];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setHTTPMethod:@"GET"];
    //[request setValue:@"text/event-stream" forHTTPHeaderField:@"Accept"];
    //[request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:authBearer forHTTPHeaderField:@"Authorization"];
    [request setURL:[NSURL URLWithString:targetURL]];
    
    NSLog(@"RESTManager Redirect Request %@", request);
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
          
          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
          NSLog(@"RESTManager Redirect Response Status Code: %ld", (long)[httpResponse statusCode]);
          
          if (error)
              failure(error);
          else {
              NSDictionary *requestJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
              NSLog(@"RESTManager Redirect REST data received: %@ %@", requestJSON, response);
              success(requestJSON);
          }
          
      }] resume];
    
}


- (void)setData:(NSString *)endpoint withValues:(NSDictionary *)values success:(void (^)(NSDictionary *response))success redirect:(void (^)(NSHTTPURLResponse *responseURL))redirect failure:(void(^)(NSError* error))failure {
    
    NSString *authBearer = [NSString stringWithFormat:@"Bearer %@",
                            [[NestAuthManager sharedManager] accessToken]];
    NSString *targetURL = [NSString stringWithFormat:@"%@/%@", NestAPIEndpoint, endpoint];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:values options:kNilOptions error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:authBearer forHTTPHeaderField:@"Authorization"];
    [request setURL:[NSURL URLWithString:targetURL]];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
          
          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
          NSLog(@"RESTManager Response Status Code: %ld", (long)[httpResponse statusCode]);
          
          if ((long)[httpResponse statusCode] == 401) {
              self.redirectURL = [NSString stringWithFormat:@"%@", [httpResponse URL]];
              redirect(httpResponse);
          }
          else if (error)
              failure(error);
          else {
              NSDictionary *requestJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
              NSLog(@"RESTManager data set: %@ %@", requestJSON, response);
              success(requestJSON);
          }
          
      }] resume];
    
}

- (void)setDataRedirect:(NSString *)endpoint withValues:(NSDictionary *)values success:(void (^)(NSDictionary *response))success failure:(void(^)(NSError* error))failure {
    
    NSString *authBearer = [NSString stringWithFormat:@"Bearer %@",
                            [[NestAuthManager sharedManager] accessToken]];
    NSString *targetURL = [NSString stringWithFormat:@"%@", endpoint];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:values options:kNilOptions error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:authBearer forHTTPHeaderField:@"Authorization"];
    [request setURL:[NSURL URLWithString:targetURL]];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
          
          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
          NSLog(@"RESTManager Redirect Response Status Code set: %ld", (long)[httpResponse statusCode]);
          
          if (error)
              failure(error);
          else {
              NSDictionary *requestJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
              NSLog(@"RESTManager Redirect data set: %@ %@", requestJSON, response);
              success(requestJSON);
          }
          
      }] resume];
    
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Create the response data
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [self.responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    //NSError* error;
    //NSDictionary *requestJSON = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&error];
    //NSLog(@"REST data received from connection: %@", requestJSON);
    
    // Store the access key
    //long expiresIn = [[json objectForKey:@"expires_in"] longValue];
    //NSString *accessToken = [json objectForKey:@"access_token"];
    //[self setAccessToken:accessToken withExpiration:expiresIn];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    NSLog(@"Failed to connect to the Nest API!");
}

@end
