//
//  SwiftUIView.swift
//  
//
//  Created by paco on 07/04/23.
//

import SwiftUI
import CloudKit

import SystemConfiguration

func hasNetworkConnection() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
        }
    }) else {
        return false
    }
    
    var flags: SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
        return false
    }
    
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    
    return isReachable && !needsConnection
}


//func hasAvailableICloudStorageSpace(completion: @escaping (Bool) -> Void) {
//    let container = CKContainer.default()
//    container.fetchUserRecordID { (recordID, error) in
//        if let error = error as? CKError {
//            if error.code == .quotaExceeded {
//                completion(false)
//            } else {
//                completion(false)
//            }
//        } else if let recordID = recordID {
//            let quota = container.uplo
//            completion(quota > 0)
//        }
//    }
//}

func isLowPowerModeEnabled() -> Bool {
    let processInfo = ProcessInfo.processInfo
    return processInfo.isLowPowerModeEnabled
}

public struct CloudkitStatusView: View {
    public  init(loggedIn: Bool = false, cloudkitPermissions: Bool = false, hasSpace: Bool = true, unknownStatus: Bool = false, unkown: Bool = false, hasWifi: Bool = false, lowPowerEnabled: Bool = false) {
        self.loggedIn = loggedIn
        self.cloudkitPermissions = cloudkitPermissions
        self.hasSpace = hasSpace
        self.unknownStatus = unknownStatus
        self.unkown = unkown
        self.hasWifi = hasWifi
        self.lowPowerEnabled = lowPowerEnabled
    }
    
    @State var loggedIn = false
    @State var cloudkitPermissions = false
    @State var hasSpace = true

    @State var unknownStatus = false
    @State var unkown = false
    @State var hasWifi = false
    @State var lowPowerEnabled = false
    
    public var body: some View {
        List {
            CloudKitStatusRow(label: "Network Connection", okay: hasWifi, secondaryLabel: hasWifi ? "Connected" : "Not Connected")
            CloudKitStatusRow(label: "iCloud Account", okay: loggedIn, secondaryLabel: loggedIn ? "Logged in" : "Not logged in")
            CloudKitStatusRow(label: "Low Power Mode", okay: !lowPowerEnabled, secondaryLabel: lowPowerEnabled ? "Enabled" : "Disabled")
            CloudKitStatusRow(label: "Enough iCloud Space", okay: hasSpace, secondaryLabel: hasSpace ? "You have enough space" : loggedIn ? "Not enough space" : "Not logged in")

        }
        .navigationTitle("iCloud Status")
        .onAppear {
            lowPowerEnabled = isLowPowerModeEnabled()
            
            let container = CKContainer.default()
            container.accountStatus { (accountStatus, error) in
                if let error = error as? CKError {
                           if error.code == .quotaExceeded {
                               print("User's iCloud storage space is full")
                                hasSpace = false
                           } else {
                               print("Error checking iCloud account status: \(error.localizedDescription)")
                           }
                    
                       
                    // Handle error
                } else {
                    switch accountStatus {
                    case .available:
                        print("User is logged in to iCloud.")
                        loggedIn = true
                        // Update view with logged-in status
                    case .restricted:
                        print("Access to user's iCloud data is restricted.")
                        cloudkitPermissions = false
                        // Update view with restricted status
                    case .noAccount:
                        print("User is not logged in to iCloud.")
                        loggedIn = false
                        hasSpace = false
                        // Update view with not logged-in status
                        
                    case .couldNotDetermine:
                        print("Could not determine iCloud account status.")
                        unkown = true
                        // Update view with could not determine status
                    case .temporarilyUnavailable:
                        print("tempo unaiv")
                        unkown = true

                    @unknown default:
                        print("nigga")
                        unkown = true

                    }
                }
            }
            
            hasWifi = hasNetworkConnection()
        }
        
    }
}

struct CloudkitStatusView_Previews: PreviewProvider {
    static var previews: some View {
        CloudkitStatusView()
    }
}
