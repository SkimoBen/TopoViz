//
//  altitudeAPI.swift
//  TopoViz
//
//  Created by Ben Pearman on 2024-10-20.
//

import Foundation
import CoreLocation

// urlBuilder
/// Turn a list of coordinates into a URL for the open elevation API call
func urlBuilder(coordinates: [CLLocationCoordinate2D]) -> String{
    var url = "https://api.open-elevation.com/api/v1/lookup?locations="
    for cord in coordinates {
        url = url + String(cord.latitude) + "," + String(cord.longitude) + "|"
    }
    if let index = url.lastIndex(of: "|") {
        url.remove(at: index)
    }
    return url
}

// getAltitude
/// Take in a url for the Open Elevation API and perform the API call.
func getAltitude(urlString: String) async throws -> OpenAltitudeResponce? {
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return nil
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        return nil
    }
    if httpResponse.statusCode == 200 {
        let decoded_data = try JSONDecoder().decode(OpenAltitudeResponce.self, from: data)
        return decoded_data
    } else {
        print(response)
    }
        
    return nil
}


func extractElevations(from response: OpenAltitudeResponce) -> [Int] {
    return response.results.map { $0.elevation }
}

// Codable structs 
struct OpenAltitudeResponce: Codable {
    let results: [OpenAltitudeResponse_Results]
    
}

struct OpenAltitudeResponse_Results: Codable {
    let latitude: Float
    let elevation: Int
    let longitude: Float
    
}
