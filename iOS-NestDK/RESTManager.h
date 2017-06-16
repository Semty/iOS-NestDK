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

@interface RESTManager : NSObject <NSURLConnectionDelegate>

+ (RESTManager *)sharedManager;

- (NSString *)endpointURL;

- (void)setRootEndpoint:(NSString *)rootURL;

- (void)getData:(NSString *)endpoint
        success:(void (^)(NSDictionary *response))success
       redirect:(void (^)(NSHTTPURLResponse *responseURL))redirect
        failure:(void(^)(NSError* error))failure;

- (void)getDataRedirect:(NSString *)endpoint
                success:(void (^)(NSDictionary *response))success
                failure:(void(^)(NSError* error))failure;

- (void)setData:(NSString *)endpoint
     withValues:(NSDictionary *)values
        success:(void (^)(NSDictionary *response))success
        redirect:(void (^)(NSHTTPURLResponse *responseURL))redirect
        failure:(void(^)(NSError* error))failure;

- (void)setDataRedirect:(NSString *)endpoint withValues:(NSDictionary *)values
                success:(void (^)(NSDictionary *response))success
                failure:(void(^)(NSError* error))failure;

@end
