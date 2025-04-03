# QPair - iOS Bluetooth LE Pairing App Demo

## Overview

QPair is an iOS application developed in Swift, designed to demonstrate the pairing workflow for COSMED Q Bluetooth LE peripherals.
The necessity came up because, while Windows and Android provide a programmatic way to initiate pairing with the desired security level (without going into Settings), iOS handles this differently.
The CoreBluetooth framework does not have the ability to initiate pairing—this process is managed exclusively by iOS.  
A programmatic way to force iOS to start pairing is to connect to the device and attempt to access an encrypted characteristic.  
Therefore, in Q firmware version **1.0-rc15**, I have encrypted the following characteristics of the **CSS service** (UUID: `b381fcca-142a-4b9b-ba1f-af6a3ea715c7`):  

- **CSS Spirometer Measurement Characteristic Value** (`b3810001-142a-4b9b-ba1f-af6a3ea715c7`)  
- **CSS Environment Measurement Characteristic Value** (`b3810002-142a-4b9b-ba1f-af6a3ea715c7`) 

## Key Features

*   **Targeted Peripheral Discovery:** QPair performs targeted scanning, filtering for Bluetooth LE peripherals that match the regular expression pattern `^Q \\d{10}$` in their advertised name. This pattern matches peripheral names that start with "Q" followed by a space and then 10 digits.
*   **Automatic Pairing:** Upon establishing a connection, QPair automatically initiates the iOS pairing process by leveraging the `CBPeripheral.setNotifyValue(true, for:)` method on a protected GATT characteristic. This eliminates the need for manual pairing steps.
*   **Connection Management:** The app manages connection and disconnection events through the `CBCentralManagerDelegate` and `CBPeripheralDelegate` protocols.
*   **Protected Characteristic Access:** The app interacts with a specific, protected GATT characteristic (UUID: `b3810002-142a-4b9b-ba1f-af6a3ea715c7` within service `b381fcca-142a-4b9b-ba1f-af6a3ea715c7`) to trigger the pairing process.
*   **SwiftUI User Interface:** The user interface is built using SwiftUI, providing a reactive and declarative approach to UI updates.
* **Automatic Scan:** The app automatically starts scanning when it launches and when a peripheral is disconnected or the connection fails.
* **Stop Scan on Connect:** The app automatically stops scanning when a connection is established.
* **Connection State:** The app visually indicates the connection state of each peripheral in the list.

## Technical Details

### GATT Profile

The app interacts with the following GATT elements:

*   **Service UUID:** `b381fcca-142a-4b9b-ba1f-af6a3ea715c7`
*   **Characteristic UUID:** `b3810002-142a-4b9b-ba1f-af6a3ea715c7`

### App Icon and App Color

The app icon is the standard company logo with black background.

### Landscape Mode

WIP

## Getting Started

1.  Clone the repository.
2.  Open the Xcode project.
3.  Build, install and run the app on an iOS physical device.
4.  Eansure the Q Spirometer is powered-on and in range
5.  Tap on Q Spirometer label
6.  Confirm pairing by clicking pushbutton on Q
7.  Confirm pairing on iOS alert popup

## Author

G. Filosofi - COSMED S.r.l.
