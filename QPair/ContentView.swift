//
//  ContentView.swift
//  QPair
//
//  Created by G. Filosofi on 26/03/2025.
//  Copyright © 2025 COSMED S.r.l. All rights reserved.
//
//  Description: This module defines the main user interface for the QPair app.
//  It includes the list of discovered peripherals, and the logic for handling
//  user interactions.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @ObservedObject var bluetoothManager = BluetoothManager()

    var body: some View {
        NavigationView {
            GeometryReader { geometry in // Use GeometryReader to get screen size
                VStack {
                    Image("qpairing")
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(geometry.size.width * 0.8, 199), height: min(geometry.size.height * 0.3, 375)) // Adjust size based on screen size
                    List(bluetoothManager.peripherals, id: \.identifier) { peripheral in
                        Text(peripheral.name ?? "Unknown")
                            .foregroundColor(bluetoothManager.connectedPeripheralName == peripheral.name ? .green : .primary)
                            .onTapGesture {
                                bluetoothManager.connectToPeripheral(peripheral)
                            }
                    }
                }
                .navigationTitle("QPair")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    ContentView()
}

