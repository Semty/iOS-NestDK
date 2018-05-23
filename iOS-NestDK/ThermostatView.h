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

#import <UIKit/UIKit.h>
#import "Thermostat.h"
#import "Constants.h"

@protocol ThermostatViewDelegate <NSObject>

- (void)thermostatInfoChange:(Thermostat *)thermostat forEndpoint:(NestEndpoint)endpoint;
- (void)showNextThermostat;

@end

@interface ThermostatView : UIView

@property (nonatomic) NSInteger currentTemp;
@property (nonatomic) NSInteger targetTemp;
@property (nonatomic, strong) NSString *hvacMode;
@property (nonatomic) BOOL fanTimerActive;
@property (nonatomic, strong) NSString *thermostatId;
@property (nonatomic, strong) NSString *thermostateName;
@property (nonatomic, weak) id <ThermostatViewDelegate>delegate;

- (void)showLoading;
- (void)hideLoading;

- (void)turnFan:(BOOL)on;

- (void)updateWithThermostat:(Thermostat *)thermostat;

- (void)disableView;
- (void)enableView;

@end
