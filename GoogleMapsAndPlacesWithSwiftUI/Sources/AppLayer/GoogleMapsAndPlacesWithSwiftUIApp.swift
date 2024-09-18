//
//  GoogleMapsAndPlacesWithSwiftUIApp.swift
//  GoogleMapsAndPlacesWithSwiftUI
//
//  Created by Temur Chitashvili on 18.09.24.
//

import SwiftUI

@main
struct GoogleMapsAndPlacesWithSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
