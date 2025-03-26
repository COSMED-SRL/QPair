//
//  BluetoothManager.swift
//  QPair
//
//  Created by G. Filosofi on 26/03/2025.
//  Copyright © 2025 COSMED S.r.l. All rights reserved.
//
//  Description: This module manages all Bluetooth Low Energy (LE) interactions,
//  including scanning for Q Spirometer peripherals, connecting to them,
//  discovering CSS services and CSS Environment Measurement characteristics,
//  and triggering the iOS pairing process by attempting to get notify on it.
//

import CoreBluetooth
import Foundation

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var peripherals: [CBPeripheral] = []
    @Published var isScanning = false
    @Published var isConnected = false
    @Published var connectedPeripheralName: String? = nil

    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var encryptedCharacteristic: CBCharacteristic?
    private let CSSServiceUUID = CBUUID(string: "b381fcca-142a-4b9b-ba1f-af6a3ea715c7")
    private let CSSEnvCharacteristicUUID = CBUUID(string: "b3810002-142a-4b9b-ba1f-af6a3ea715c7")

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        guard centralManager.state == .poweredOn else {
            print("Bluetooth is not powered on.")
            return
        }
        peripherals.removeAll()
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        isScanning = true
        print("Scanning started...")
    }

    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        print("Scanning stopped.")
    }

    func connectToPeripheral(_ peripheral: CBPeripheral) {
        stopScanning() // Stop scanning when connecting
        centralManager.connect(peripheral, options: nil)
    }

    func disconnectFromPeripheral() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }

    // MARK: - CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on.")
            startScanning() // Start scanning when Bluetooth is powered on
            // Check for already paired peripherals
            let pairedPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [CSSServiceUUID])
            if let pairedPeripheral = pairedPeripherals.first {
                connectToPeripheral(pairedPeripheral)
            }
        case .poweredOff:
            print("Bluetooth is powered off.")
        case .unsupported:
            print("Bluetooth is unsupported.")
        case .unauthorized:
            print("Bluetooth is unauthorized.")
        case .unknown:
            print("Bluetooth state is unknown.")
        case .resetting:
            print("Bluetooth is resetting.")
        @unknown default:
            print("Unknown Bluetooth state.")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name, name.range(of: "^Q \\d{10}$", options: .regularExpression) != nil {
            if !peripherals.contains(peripheral) {
                peripherals.append(peripheral)
                print("Discovered peripheral: \(name)")
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral.name ?? "Unknown")")
        connectedPeripheral = peripheral
        connectedPeripheralName = peripheral.name
        isConnected = true
        peripheral.delegate = self
        print("Discovering services...")
        peripheral.discoverServices(nil) // Discover all services
        // Update the UI to reflect the connection
        if let index = peripherals.firstIndex(of: peripheral) {
            peripherals[index] = peripheral
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from peripheral: \(peripheral.name ?? "Unknown")")
        if let error = error {
            print("Disconnection error: \(error.localizedDescription)")
        }
        connectedPeripheral = nil
        connectedPeripheralName = nil
        isConnected = false
        encryptedCharacteristic = nil
        startScanning() // Start scanning again after disconnection
        // Update the UI to reflect the disconnection
        if let index = peripherals.firstIndex(of: peripheral) {
            peripherals[index] = peripheral
        }
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to peripheral: \(peripheral.name ?? "Unknown")")
        if let error = error {
            print("Connection error: \(error.localizedDescription)")
        }
        connectedPeripheral = nil
        connectedPeripheralName = nil
        isConnected = false
        encryptedCharacteristic = nil
        startScanning() // Start scanning again after connection failure
        // Update the UI to reflect the disconnection
        if let index = peripherals.firstIndex(of: peripheral) {
            peripherals[index] = peripheral
        }
    }

    // MARK: - CBPeripheralDelegate

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        print("Discovered services:")
        if let services = peripheral.services {
            if services.isEmpty {
                print("  No services found.")
            } else {
                for service in services {
                    print("  Service: \(service.uuid)")
                    if service.uuid == CSSServiceUUID {
                        print("    Discovering characteristics for target service...")
                        peripheral.discoverCharacteristics([CSSEnvCharacteristicUUID], for: service)
                    }
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering CSS characteristics: \(error.localizedDescription)")
            return
        }
        print("Discovered characteristics for CSS service \(service.uuid):")
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("  Characteristic: \(characteristic.uuid)")
                if characteristic.uuid == CSSEnvCharacteristicUUID {
                    encryptedCharacteristic = characteristic
                    print("    Setting notify value to true for the CSS Environment Measurement characteristic \(characteristic.uuid)...")
                    peripheral.setNotifyValue(true, for: encryptedCharacteristic!) // Attempt to subscribe to notifications
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error setting notification state for CSS Environment Measurement characteristic \(characteristic.uuid): \(error.localizedDescription)")
            return
        }
        print("Notification state updated for CSS Environment Measurement characteristic \(characteristic.uuid). Is notifying: \(characteristic.isNotifying)")
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error reading CSS Environment Measurement characteristic \(characteristic.uuid): \(error.localizedDescription)")
            return
        }
        print("Read characteristic \(characteristic.uuid)")
    }
}
