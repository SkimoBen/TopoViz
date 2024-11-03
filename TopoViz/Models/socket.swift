//
//  socket.swift
//  TopoViz
//
//  Created by Ben Pearman on 2024-10-20.
//

import Foundation
import Network

var connection: NWConnection?

//MARK: startConnection()
func startConnection() {
    connection = NWConnection(host: "127.0.0.1", port: 12346, using: .tcp)
    connection?.stateUpdateHandler = { state in
        switch state {
        case .ready:
            print("Connected to Python server")
        case .failed(let error):
            print("Connection failed: \(error)")
            connection = nil
        default:
            break
        }
    }
    connection?.start(queue: .global())
}
//MARK: closeConnection()
func closeConnection() {
    connection?.cancel()
    connection = nil
    print(connection as Any)
}

//MARK: Functions

// Send altitude
func sendAltitude(altitude: [Int]) {
    guard let connection = connection else {
        print("Connection is not available")
        return
    }
    
    let message = "\(altitude)\n".data(using: .utf8)!
    connection.send(content: message, completion: .contentProcessed { error in
        if let error = error {
            print("Failed to send: \(error)")
        } else {
            print("Altitude sent successfully")
        }
    })
}

// Go to zero
func goToZero() {
    guard let connection = connection else {
        print("Connection is not available")
        return
    }
    
    let message = "\([0,0,0,0,0,0,0,0,0,0])\n".data(using: .utf8)!
    connection.send(content: message, completion: .contentProcessed { error in
        if let error = error {
            print("Failed to send: \(error)")
        } else {
            print("function sent successfully")
        }
    })
}

func goToMax() {
    guard let connection = connection else {
        print("Connection is not available")
        return
    }
    
    let message = "\([1,1,1,1,1,1,1,1,1,1])\n".data(using: .utf8)!
    connection.send(content: message, completion: .contentProcessed { error in
        if let error = error {
            print("Failed to send: \(error)")
        } else {
            print("function sent successfully")
        }
    })
}


//func sendAltitude(altitude: [Int]) {
//    let connection = NWConnection(
//        host: NWEndpoint.Host("127.0.0.1"),
//        port: NWEndpoint.Port(12345),
//        using: .tcp
//    )
//    
//    connection.stateUpdateHandler = { state in
//        switch state {
//        case .ready:
//            print("Connected to Python server")
//            let message = "\(altitude)\n".data(using: .utf8)!
//            connection.send(content: message, completion: .contentProcessed { error in
//                if let error = error {
//                    print("Failed to send: \(error)")
//                } else {
//                    print("Altitude sent successfully")
//                }
//                connection.cancel()  // Close the connection
//            })
//        case .failed(let error):
//            print("Connection failed: \(error)")
//        default:
//            break
//        }
//    }
//
//    connection.start(queue: .global())
//}

// Example usage
// sendAltitude(altitude: 123.45)
