//
//  File.swift
//  
//
//  Created by Paco Sainz on 4/15/23.
//

import Foundation
import LocalAuthentication


public class BiomericLockModel: ObservableObject {
    @Published public var isUnlocked: Bool = false
    
    public func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate yourself to unlock your places."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in

                if success {
                    Task { @MainActor in
                        self.isUnlocked = true
                    }
                } else {
                    // error
                }
            }
        } else {
            // no biometrics
        }
    }
}


/*
 
 var biometryType: LABiometryType {
     var error: NSError?
     let context = LAContext()

     guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
         return .none
     }

     return context.biometryType
 }


 // Test the biometry type
 switch self.biometryType {
     case .faceID:
         print("Face ID")
     case .touchID:
         print("Touch ID")
     case .none:
         print("None")
     @unknown default:
         print("Unknown")
 }
 */
