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

## Create a developer account / client

You need a Nest Developer account to run this app.

1. Create a developer account at [https://developer.nest.com](https://developer.nest.com)
1. Register a new client and specify its Redirect URI as `http://localhost:8080/auth/nest/callback`

## Create a user account

You also need a Nest Learning Thermostat in order to use the app functionality. The Thermostat can be physical or virtual.

Create a user account at [https://home.nest.com](https://home.nest.com)

* If using a physical device, go through the new device setup detailed in the instructions
* If using a virtual device, create it in the [Nest Home Simulator Chrome Extension](https://chrome.google.com/webstore/detail/nest-home-simulator/jmcapoebgeaabepohkchkldlfhchkega)
    * Sign in with your user account (from home.nest.com)
    * On the Structure screen, select **ADD [DEVICE]**

## Build the app

1. In `Constants.m`, replace the placeholder strings for `NestClientID` and `NestClientSecret` with your Nest Developer credentials. See  the Overview tab on the products page: [https://console.developers.nest.com/products](https://console.developers.nest.com/products).
1. In Xcode, select Product > Build.

## Run the app

In Xcode, select Product > Run.

## How to contribute

Contributions are always welcome and highly encouraged.

See [CONTRIBUTING](CONTRIBUTING.md) for more information on how to get started.

## License

Apache 2.0 - See [LICENSE](LICENSE) for more information.
