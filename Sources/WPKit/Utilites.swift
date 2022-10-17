//
//  Utilities.swift
//  
//
//  Created by Fabio Mauersberger on 22.08.22.
//

import Foundation
import SwiftUI

public enum WPError: Error {
    case authFailed        // bad auth key
    case authMissing       // more for implementation failures than actual production
    case badRequest        // the dev failed to implement the correct params and/or data
    case badResult         // request seems to have completed just fine, but it actually hasn't
    case endpointNotFound  // there is nothin at the URL you are pointing at
    case urlBuildingFailed // worst case as its pretty hard to find out what went wrong
}

public enum HTTPMethod: String {
    case GET, POST, DELETE
}

public func wplog(_ message: CVarArg ...) {
    #if DEBUG
    let _message = message.reduce("", {result, step in
        return result + "\(step)"
    })
    NSLog(_message)
    #endif
}


