//
//  MainViewModel.swift
//  GoogleMapsAndPlacesWithSwiftUI
//
//  Created by Temur Chitashvili on 19.09.24.
//

import Combine
import CoreLocation
import GoogleMaps
import GooglePlaces

final class MainViewModel: ObservableObject {
    @Published var markerCoordinate = CLLocationCoordinate2D(latitude: 41.693333, longitude: 44.801667)
    @Published var city: String = ""
    @Published var country: String = ""
    @Published var address: String = ""
    @Published var predictions: [GMSAutocompletePrediction] = []
    @Published var addressIsEditing: Bool = false
    
    private var placesClient: GMSPlacesClient = GMSPlacesClient.shared()
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        getAddressDetailsWithMapMarker()
        observeQuery()
    }
    
    func getAddressDetailsWithMapMarker() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            GMSGeocoder().reverseGeocodeCoordinate(markerCoordinate) { [weak self]  addressInfo, error in
                if let error = error {
                    print("An error during geocoding coordinate: \(error)")
                    return
                }
                
                guard let self = self else { return }
                
                address = addressInfo?.firstResult()?.lines?[0] ?? ""
                city = addressInfo?.firstResult()?.locality ?? ""
                country = addressInfo?.firstResult()?.country ?? ""
            }
        }
    }
    
    func observeQuery() {
        $address
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.fetchPredictions(for: query)
            }
            .store(in: &cancellables)
    }
    
    // Function to handle user selecting a prediction
    func selectPrediction(_ prediction: GMSAutocompletePrediction) {
        // Fetch place details for the selected prediction
        fetchPlaceDetails(for: prediction.placeID)
    }

    
    private  func fetchPredictions(for query: String) {
        guard !query.isEmpty else {
            self.predictions = []
            return
        }
        
        let filter = GMSAutocompleteFilter()
        filter.types = [kGMSPlaceTypeGeocode]  // Fetch only addresses
        // Optional: You can add country or location bias here
        
        placesClient.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) { [weak self] (results, error) in
            if let error = error {
                print("Error fetching predictions: \(error.localizedDescription)")
                return
            }
            
            self?.predictions = results ?? []
        }
    }
    
    private func fetchPlaceDetails(for placeID: String) {
        let placeFields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(GMSPlaceField.coordinate.rawValue))
        
        placesClient.fetchPlace(fromPlaceID: placeID, placeFields: placeFields, sessionToken: nil) { [weak self] (place: GMSPlace?, error: Error?) in
            if let error = error {
                print("An error during fetch place: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                self?.markerCoordinate = place.coordinate
            }
        }
    }

}
