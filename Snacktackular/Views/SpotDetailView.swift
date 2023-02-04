//
//  SpotDetailView.swift
//  Snacktackular
//
//  Created by Jeremy Taylor on 1/17/23.
//

import SwiftUI
import MapKit
import FirebaseFirestoreSwift

struct SpotDetailView: View {
    struct Annotation: Identifiable {
        let id = UUID().uuidString
        var name: String
        var address: String
        var coordinate: CLLocationCoordinate2D
    }
    
    @EnvironmentObject var spotVM: SpotViewModel
    @EnvironmentObject var locationManager: LocationManager
    @FirestoreQuery(collectionPath: "spots") var reviews: [Review]
    @State var spot: Spot
    @State private var showPlaceLookupSheet = false
    @State private var showReviewViewSheet = false
    @State private var showSaveAlert = false
    @State private var showingAsSheet = false
    @State private var mapRegion = MKCoordinateRegion()
    @State private var annotations: [Annotation] = []
    var avgRating: String {
        guard reviews.count != 0 else {
            return "-.-"
        }
        let averageValue = Double(reviews.reduce(0) {$0 + $1.rating}) / Double(reviews.count)
        return String(format: "%.1f", averageValue)
    }
    @Environment(\.dismiss) private var dismiss
    let regionSize = 500.0 // meters
    var previewRunning = false
    
    var body: some View {
        VStack {
            Group {
                TextField("Name", text: $spot.name)
                    .font(.title)
                TextField("Address", text: $spot.address)
                    .font(.title2)
            }
            .disabled(spot.id == nil ? false : true)
            .textFieldStyle(.roundedBorder)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.gray.opacity(0.5), lineWidth: spot.id == nil ? 2 : 0)
            }
            .padding(.horizontal)
            
            Map(coordinateRegion: $mapRegion, showsUserLocation: true, annotationItems: annotations) { annotation in
                MapMarker(coordinate: annotation.coordinate)
            }
            .frame(height: 250)
            .onChange(of: spot) { _ in
                annotations = [Annotation(name: spot.name, address: spot.address, coordinate: spot.coordinate)]
                mapRegion.center = spot.coordinate
            }
            
            List {
                Section {
                    ForEach(reviews) { review in
                        NavigationLink {
                            ReviewView(spot: spot, review: review)
                        } label: {
                           SpotReviewRowView(review: review)
                        }

                    }
                } header: {
                    HStack {
                        Text("Avg. Rating")
                            .font(.title2)
                            .bold()
                        Text(avgRating) 
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundColor(Color("SnackColor"))
                        Spacer()
                        Button("Rate It") {
                            if spot.id == nil {
                                showSaveAlert.toggle()
                            } else {
                                showReviewViewSheet.toggle()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .bold()
                        .tint(Color("SnackColor"))
                    }
                }

            }
            .headerProminence(.increased)
            .listStyle(.plain)
            
            Spacer()
        }
        .onAppear {
            if !previewRunning && spot.id != nil {
                $reviews.path = "spots/\(spot.id ?? "")/reviews"
                print("reviews.path = \($reviews.path)")
            } else {
                showingAsSheet = true
            }
            
            if spot.id != nil { // if we have a spot, center map on the spot
                mapRegion = MKCoordinateRegion(center: spot.coordinate, latitudinalMeters: regionSize, longitudinalMeters: regionSize)
            } else { // otherwise center the map on the device location
                Task { // if you don't embed in a Task, the map update likely won't show
                    mapRegion = MKCoordinateRegion(center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(), latitudinalMeters: regionSize, longitudinalMeters: regionSize)
                }
                
            }
            annotations = [Annotation(name: spot.name, address: spot.address, coordinate: spot.coordinate)]
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(spot.id == nil)
        .toolbar {
            if showingAsSheet {
                if spot.id == nil && showingAsSheet { // New spot, so show Cancel/Save buttons
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            Task {
                                let success = await spotVM.saveSpot(spot: spot)
                                if success {
                                    dismiss()
                                } else {
                                    print("😡 DANG! Error saving spot!")
                                }
                            }
                            dismiss()
                        }
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        
                        Button {
                            showPlaceLookupSheet.toggle()
                        } label: {
                            Image(systemName: "magnifyingglass")
                            Text("Lookup Place")
                        }
                        
                    }
                } else if showingAsSheet && spot.id != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showPlaceLookupSheet) {
            PlaceLookupView(spot: $spot)
        }
        .sheet(isPresented: $showReviewViewSheet) {
            NavigationStack {
                ReviewView(spot: spot, review: Review())
            }
            
        }
        .alert("Cannot Rate Spot Unless It Is Saved", isPresented: $showSaveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Save", role: .none) {
                Task {
                    let success = await spotVM.saveSpot(spot: spot)
                    spot = spotVM.spot
                    if success {
                        $reviews.path = "spots/\(spot.id ?? "")/reviews"
                        showReviewViewSheet.toggle()
                    } else {
                       print("😡 Dang! Error saving spot!")
                    }
                }
            }
        } message: {
            Text("Would you like to save this spot first so you can enter a review?")
        }

    }
}

struct SpotDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SpotDetailView(spot: Spot(), previewRunning: true)
                .environmentObject(SpotViewModel())
                .environmentObject(LocationManager())
        }
    }
}
