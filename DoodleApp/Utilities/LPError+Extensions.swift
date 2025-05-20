//
//  LPError+Extensions.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/16.
//

import LinkPresentation
import Foundation

extension LPError {
    var string: String {
        switch self.code {
        case .metadataFetchCancelled:
            return "Metadata fetch cancelled."
            
        case .metadataFetchFailed:
            return "Metadata fetch failed."
            
        case .metadataFetchTimedOut:
            return "Metadata fetch timed out."
            
        case .unknown:
            return "Metadata fetch unknown."
            
        case .metadataFetchNotAllowed:
            return "Metadata fetch not allowed."
            
        @unknown default:
          return "Metadata fetch failed with unknown error."
        }
    }
}

