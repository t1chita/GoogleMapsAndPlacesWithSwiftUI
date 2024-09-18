//
//  AppDelegate.swift
//  GoogleMapsAndPlacesWithSwiftUI
//
//  Created by Temur Chitashvili on 19.09.24.
//

import GoogleMaps
import GooglePlaces

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Provide the API key for both Google Maps and Google Places
        GMSServices.provideAPIKey("YOUR_API_KEY")
        GMSPlacesClient.provideAPIKey("YOUR_API_KEY")
        return true
    }
}
