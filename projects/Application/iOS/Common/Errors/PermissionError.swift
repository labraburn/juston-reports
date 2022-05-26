//
//  PermissionError.swift
//  iOS
//
//  Created by Anton Spivak on 26.05.2022.
//

import Foundation

protocol PermissionError: LocalizedError {}

//
// CameraPermissionError
//

enum CameraPermissionError {
    
    case noCameraAccessQRCode
}

extension CameraPermissionError: PermissionError {
    
    var errorDescription: String? {
        switch self {
        case .noCameraAccessQRCode:
            return "PermissionErrorCameraAccessQRCode".asLocalizedKey
        }
    }
}
