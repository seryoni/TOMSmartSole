# Hero - PressureDetection

* **OS:** iOS 9.3+
* **Languages:** Swift
* **Tool requirements:** Xcode 7.3
* **License:** ________
* **Status:** “alpha”

This app communicate over bluetooth with a BLE device using GATT profile.

It uses bluetooth-central background mode and listen for notifications from the device and battery service.

Notifications are send from device only after over pressure state has been detected.
i.e. two min. standing or 15 min. walking with pressure over defined threshold.

The pressure threshold, and minimum time definitions are currently hard coded on the device (see sketch file).

When use hit the connect button the app start a scan for devices with our service UUID. 
When device is found it will pair with the first one and stop scanning.
The app remembers this device and will try to maintain the connection over disconnections are app restart.
On any failure afterwards a connection will be attemped.

# Build

* With Xcode just Build->Run
* Switch on the device and hit the connect button on the app. Let if few seconds to connect.

Note: For dependency managment, CocoaPods is being used, but for integrity the depedencies are being included in the git repository.

# Bluetooth Profile

The app use part of the Health Thermometer Service (HTS).
We actually don't need this specific service, but it was chosen for quick development using the ready made sketch for HTS.
This also allowed us to use ready made HTS monitors during the makeathon for testing the sensor while app is being developed.(Those monitor apps didn't work well in background mode)

[HTS Overview](https://developer.bluetooth.org/TechnologyOverview/Pages/HTS.aspx)
[HTS Profile spec](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.service.health_thermometer.xml)
[IOS-nRF-Toolbox with HTS](https://github.com/NordicSemiconductor/IOS-nRF-Toolbox)

# Adafruit Feather

To be able to use the sketch file or the adafuit healththromometer sketch, it requires to upgrade the adafruit feather to firmware version 0.7
This can be done using their connect app:  [AppStore link](https://itunes.apple.com/app/adafruit-bluefruit-le-connect/id830125974?mt=8)

To learn more on this device [Read here](https://learn.adafruit.com/adafruit-feather-32u4-bluefruit-le/downloads?view=all#bluefruit-le-connect-ios-slash-swift)

Arduino Libraries:
* [Adafruit_BluefruitLE_nRF51](https://github.com/adafruit/Adafruit_BluefruitLE_nRF51)
* [CountUpDownTimer](https://github.com/AndrewMascolo/CountUpDownTimer)

# Testing
A slight modified version of 'healththermometer' sketch is used.
It will randomly send

