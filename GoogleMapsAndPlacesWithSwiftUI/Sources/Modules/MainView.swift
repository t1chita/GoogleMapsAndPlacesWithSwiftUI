//
//  MainView.swift
//  GoogleMapsAndPlacesWithSwiftUI
//
//  Created by Temur Chitashvili on 18.09.24.
//

import SwiftUI
import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    var body: some View {
        VStack {
            if !viewModel.addressIsEditing {
                TextField("City", text: $viewModel.city)
                    .font(.system(size: 12, weight: .regular))
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).stroke(lineWidth: 2).foregroundStyle(.black))
                
                TextField("Country", text: $viewModel.country)
                    .font(.system(size: 12, weight: .regular))
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).stroke(lineWidth: 2).foregroundStyle(.black))
            }
          
            TextField("Address", text: $viewModel.address)
                .font(.system(size: 12, weight: .regular))
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).stroke(lineWidth: 2).foregroundStyle(.black))
                .onTapGesture {
                    withAnimation {
                        viewModel.addressIsEditing = true
                    }
                }
            if viewModel.addressIsEditing {
            List(self.viewModel.predictions, id: \.self) { prediction in
                Button(action: {
                    viewModel.selectPrediction(prediction)
                    withAnimation {
                        viewModel.addressIsEditing = false
                    }
                }) {
                    HStack {
                        Text(prediction.attributedFullText.string)
                            .font(.system(size: 12, weight: .regular))                                .foregroundStyle(Color.black)
                            .padding()
                        
                        Spacer()
                    }
                    .background(RoundedRectangle(cornerRadius: 12).stroke(lineWidth: 2).foregroundStyle(.black))
                }
                .alignmentGuide(.listRowSeparatorLeading) { d in d[.leading] }
            }
            .background(Color.clear)
            .scrollContentBackground(.hidden)
            .listRowBackground(Color.clear)
            .listStyle(PlainListStyle())
        }
        
            if !viewModel.addressIsEditing {
                GoogleMapView(markerLocation: $viewModel.markerCoordinate)
            }  
            
            if viewModel.addressIsEditing {
               Spacer()
            }
        }
        .padding()
        .onChange(of: viewModel.markerCoordinate.latitude) { _, _ in
            viewModel.getAddressDetailsWithMapMarker()
        }
    }
}


struct GoogleMapView: UIViewRepresentable {
    @Binding var markerLocation: CLLocationCoordinate2D
    func makeCoordinator() -> Coordinator {
        let mapView = GMSMapView()
        let marker = GMSMarker()
        let coordinator = Coordinator(markerLocation: $markerLocation, mapView: mapView, marker: marker)
        return coordinator
    }
    
    func makeUIView(context: Context) -> GMSMapView {
        let mapView = context.coordinator.mapView
        mapView.delegate = context.coordinator
        
        let camera = GMSCameraPosition.camera(withTarget: markerLocation, zoom: 15)
        mapView.camera = camera
        
        context.coordinator.marker.position = markerLocation
        context.coordinator.marker.isDraggable = true
        context.coordinator.marker.map = mapView
        return mapView
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        // Update the existing marker position when the markerLocation changes
        context.coordinator.marker.position = markerLocation
        uiView.animate(toLocation: markerLocation)
    }
}


class Coordinator: NSObject, GMSMapViewDelegate {
    @Binding var markerLocation: CLLocationCoordinate2D
    var mapView: GMSMapView
    var marker: GMSMarker
    
    init(markerLocation: Binding<CLLocationCoordinate2D>,
         mapView: GMSMapView,
         marker: GMSMarker
    ) {
        self._markerLocation = markerLocation
        self.mapView = mapView
        self.marker = marker
    }
    
    // Handle marker drag end
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        let camera = GMSCameraPosition(target: marker.position, zoom: 16)
        markerLocation = marker.position
        mapView.animate(to: camera)
    }
}

#Preview {
    MainView()
}
