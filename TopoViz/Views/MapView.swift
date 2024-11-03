//
//  MapView.swift
//  TopoViz
//
//  Created by Ben Pearman on 2024-10-20.
//

import SwiftUI
import MapKit

var calgary: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 51.03529, longitude:  -114.072266)
var wapta: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 51.578302, longitude: -116.444282)


var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: wapta, // Adjust to use your desired coordinates, e.g., 'sf' or 'af'
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // Adjust zoom level
        )
    }

struct MapView: View {
    @State private var position: MapCameraPosition = .region(region)
    @State private var centerCoordinate: CLLocationCoordinate2D = wapta
    @State private var dotCoordinates: [CLLocationCoordinate2D] = Array(repeating: wapta, count: 10)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                Map(position: $position) {
                    // Map annotations
                }
                .onAppear(perform: { // Start the connection with the python socket
                    
                })
                .onDisappear(perform: { // close connection when the view closes
                    closeConnection()
                })
                .mapStyle(.hybrid(elevation: .realistic, pointsOfInterest: .including(.nationalPark), showsTraffic: false))
                .mapControlVisibility(.visible)
                .onMapCameraChange { context in
                    centerCoordinate = context.region.center

                    // Get the size of the map view
                    let mapRect = context.rect

                    // For each dot, compute its coordinate
                    for index in 0..<10 {
                        // Compute x position of dot
                        let x = mapRect.minX + mapRect.width * CGFloat(index + 1) / CGFloat(11) // 10 dots, 11 intervals
                        let y = mapRect.midY // Vertically centered
                        let screenPoint = CGPoint(x: x, y: y)

                        // Calculate coordinate based on the screen point
                        let coordinate = coordinateAtPoint(screenPoint: screenPoint, in: mapRect, region: context.region)
                        dotCoordinates[index] = coordinate
                        
                        // print("Dot \(index + 1) coordinate: \(coordinate.latitude), \(coordinate.longitude)")
                        
                    }
                    let url = urlBuilder(coordinates: dotCoordinates)
                    print("URL: \(url)")
                    Task {
                        do {
                            if let altitudeData = try await getAltitude(urlString: url) {
                               let elevations = extractElevations(from: altitudeData)
                                print(elevations)
                                sendAltitude(altitude: elevations)
                            }
                            
                        } catch {
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)

                // Overlay the dots
                HStack(spacing: 0) {
                    Spacer()
                    ForEach(0..<10, id: \.self) { index in
                        Image(systemName: "circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 12))
                        Spacer()
                    }
                }
                .padding(.horizontal)
                
                // Buttons for controlling the socket
                HStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            startConnection()
                        }, label: {
                            Text("Open Connection")
                        })
                        Button(action: {
                            closeConnection()
                        }, label: {
                            Text("Close Connection")
                        })
                        Button(action: {
                            goToZero()
                        }, label: {
                            Text("Zero")
                        })
                        Button(action: {
                            goToMax()
                        }, label: {
                            Text("Max")
                        })
                    }
                    
                }
            }
        }
    }

    func coordinateAtPoint(screenPoint: CGPoint, in rect: MKMapRect, region: MKCoordinateRegion) -> CLLocationCoordinate2D {
        // Calculate the fraction of the point within the map's rect
        let xFraction = (screenPoint.x - rect.minX) / rect.width
        let yFraction = (screenPoint.y - rect.minY) / rect.height

        // Calculate longitude
        let minLongitude = region.center.longitude - region.span.longitudeDelta / 2
        let longitude = minLongitude + xFraction * region.span.longitudeDelta

        // Calculate latitude (note the inversion because y increases downward)
        let maxLatitude = region.center.latitude + region.span.latitudeDelta / 2
        let latitude = maxLatitude - yFraction * region.span.latitudeDelta

        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}


#Preview {
    MapView()
}
