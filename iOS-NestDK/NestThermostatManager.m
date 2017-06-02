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

#import "NestThermostatManager.h"
#import "NestAuthManager.h"
#import "RESTManager.h"

@interface NestThermostatManager ()

@end

#define FAN_TIMER_ACTIVE @"fan_timer_active"
#define HAS_FAN @"has_fan"
#define TARGET_TEMPERATURE_F @"target_temperature_f"
#define AMBIENT_TEMPERATURE_F @"ambient_temperature_f"
#define HVAC_MODE @"hvac_mode"
#define NAME_LONG @"name_long"
#define THERMOSTAT_PATH @"devices/thermostats"

@implementation NestThermostatManager

/**
 * Sets up a new connection for the thermostat provided
 * and observes for any change in /devices/thermostats/thermostatId.
 * @param thermostat The thermostat you want to watch changes for.
 */
- (void)beginSubscriptionForThermostat:(Thermostat *)thermostat
{
    
    [[RESTManager sharedManager] getData:[NSString stringWithFormat:@"devices/thermostats/%@/", thermostat.thermostatId] success:^(NSDictionary *responseJSON) {
        
        NSLog(@"NestThermostatManager Success: %@", responseJSON);
        [self updateThermostat:thermostat forStructure:responseJSON];
        
    } redirect:^(NSHTTPURLResponse *responseURL) {
        
        // If a redirect was thrown, make another call using the redirect URL
        NSLog(@"NestThermostatManager Redirect: %@", [responseURL URL]);
        self.redirectURL = [NSString stringWithFormat:@"%@", [responseURL URL]];
        
        [[RESTManager sharedManager] getDataRedirect:self.redirectURL success:^(NSDictionary *responseJSON) {
            
            [self updateThermostat:thermostat forStructure:responseJSON];
            NSLog(@"NestThermostatManager Redirect Success: %@", responseJSON);
            
        } failure:^(NSError *error) {
            NSLog(@"NestThermostatManager Redirect Error: %@", error);
        }];
        
    } failure:^(NSError *error) {
        NSLog(@"NestThermostatManager Error: %@", error);
    }];
    
    NSLog(@"NestThermostatManager - after REST");
}

/**
 * Parse thermostat structure and put it in the thermostat object.
 * Then send the updated object to the delegate.
 * @param thermostat The thermostat you wish to update.
 * @param structure The structure you wish to update the thermostat with.
 */
- (void)updateThermostat:(Thermostat *)thermostat forStructure:(NSDictionary *)structure
{
    if ([structure objectForKey:AMBIENT_TEMPERATURE_F]) {
        thermostat.ambientTemperatureF = [[structure objectForKey:AMBIENT_TEMPERATURE_F] integerValue];
    }
    if ([structure objectForKey:TARGET_TEMPERATURE_F]) {
        thermostat.targetTemperatureF = [[structure objectForKey:TARGET_TEMPERATURE_F] integerValue];
    }
    
    if ([structure objectForKey:HVAC_MODE]) {
        thermostat.hvacMode = [structure objectForKey:HVAC_MODE];
    }
    
    if ([structure objectForKey:HAS_FAN]) {
        thermostat.hasFan = [[structure objectForKey:HAS_FAN] boolValue];

    }
    if ([structure objectForKey:FAN_TIMER_ACTIVE]) {
        thermostat.fanTimerActive = [[structure objectForKey:FAN_TIMER_ACTIVE] boolValue];

    }
    if ([structure objectForKey:NAME_LONG]) {
        thermostat.nameLong = [structure objectForKey:NAME_LONG];
    }
    
    [self.delegate thermostatValuesChanged:thermostat];
}

/**
 * Sets the thermostat values by using the Nest API.
 * @param thermostat The thermostat you wish to save.\
 */
- (void)saveChangesForThermostat:(Thermostat *)thermostat
{
    NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
    
    [values setValue:[NSNumber numberWithInteger:thermostat.targetTemperatureF] forKey:TARGET_TEMPERATURE_F];
    [values setValue:[NSNumber numberWithBool:thermostat.fanTimerActive] forKey:FAN_TIMER_ACTIVE];
    
    NSLog(@"NestThermostatManager write");
    
    [[RESTManager sharedManager] setData:[NSString stringWithFormat:@"devices/thermostats/%@/", thermostat.thermostatId] withValues:values success:^(NSDictionary *responseJSON) {
        NSLog(@"NestThermostatManager Success: %@", responseJSON);
        
    } redirect:^(NSHTTPURLResponse *responseURL) {
        
        // If a redirect was thrown, make another call using the redirect URL
        NSLog(@"NestStructureManager Redirect: %@", [responseURL URL]);
        self.redirectURL = [NSString stringWithFormat:@"%@", [responseURL URL]];
        
        [[RESTManager sharedManager] setDataRedirect:self.redirectURL withValues:values success:^(NSDictionary *responseJSON) {
            
            NSLog(@"NestThermostatManager Redirect Success: %@", responseJSON);
            
        } failure:^(NSError *error) {
            NSLog(@"NestThermostatManager Redirect Error: %@", error);
        }];
        
    } failure:^(NSError *error) {
        NSLog(@"NestThermostatManager Error: %@", error);
    }];


}



@end
