# Nest for iOS

Sample iOS app demonstrating Nest Developer OAuth, REST read/write calls, and simple thermostat controls.

The app provides the following functionality:

* Display thermostat name
* Display HVAC mode
* Display current temperature in F
* Display target temperature in F
* Change target temperature in F
* Display fan timer on/off
* Turn fan timer on/off
* Display API errors

> This app does not update state changes from the Nest API in real-time. It polls the API every 30 seconds and only updates the app after a successful polling call.

The target temperatures used in this app correspond to those used for Heat and Cool modes only. If the thermostat is in Eco, Heat-Cool, or Off modes, an error will be thrown when attempting to write the temperature. See the [Thermostat Guide](https://developers.nest.com/documentation/cloud/thermostat-guide#how_hvac_mode_and_temperature_values_work_together) for more information.

## 1. Create a developer account / OAuth Client

You need a Nest Developer account to run this app.

1. Create a developer account at [https://developer.nest.com](https://developer.nest.com)
1. Register a new OAuth Client and specify its Redirect URI as `http://localhost:8080/auth/nest/callback`
1. Select the Thermostat read/write v6 permission for the client.

See [Register an OAuth Client](https://developers.nest.com/documentation/cloud/register-client) for more information.

## 2. Create a user account and add a device

You also need a Nest Learning Thermostat in order to use the app functionality. The Thermostat can be physical or virtual.

1. Create a user account at [https://home.nest.com](https://home.nest.com)
1. Add a Nest Learning Thermostat
	* If using a physical device, go through the new device setup detailed in the instructions included with the device
	* If using a virtual device, create it in the [Nest Home Simulator Chrome Extension](https://chrome.google.com/webstore/detail/nest-home-simulator/jmcapoebgeaabepohkchkldlfhchkega)
    	1. Sign in with your user account (from home.nest.com)
    	1. On the Structure screen, select **ADD [DEVICE]**

**Note:** When using a virtual device in the Nest Home Simulator, updates to the `fan_timer_active` endpoint may not be accurately reflected in the Nest API, compared to a physical device. See the [Thermostat Guide](https://developers.nest.com/documentation/cloud/thermostat-guide#fan) for more information.

## 3. Configure the app

1. Clone this repository: `git clone https://github.com/nestlabs/iOS-NestDK.git`
1. Open the project file (`iOS-NestDK.xcodeproj`) in Xcode.
1. In `Constants.m`, replace the placeholder strings for `NestClientID` and `NestClientSecret` with your OAuth client ID and client secret from the Nest Developer portal: [https://console.developers.nest.com/products](https://console.developers.nest.com/products).

> To change the GET polling frequency, modify the `POLL_INTERVAL` value in `NestThermostatManager.m`. Do not set the `POLL_INTERVAL` to less than 25 seconds, or you may hit the GET request rate limit.

## 4. Build and run the app

This app is targeted for iOS 9.0 or later. It will not run properly on prior versions of iOS.

In Xcode:
1. Select Product > Build.
1. Select Product > Run.

## How to contribute

Contributions are always welcome and highly encouraged.

See [CONTRIBUTING](CONTRIBUTING.md) for more information on how to get started.

## License

Apache 2.0 - See [LICENSE](LICENSE) for more information.
