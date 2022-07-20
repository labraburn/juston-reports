//
//  Created by Anton Spivak
//

import UIKit
import SystemUI

public enum SVGDecoderError {
    case undefined
}

public struct SVGDecoder {
    private let decoder = SUISVGDecoder()

    public init() {}

    public func decode(from fileURL: URL) throws -> UIImage {
        guard let image = try decoder.decodeImage(withContentsOf: fileURL)
        else {
            throw SVGDecoderError.undefined
        }

        return image
    }

    public func decode(from data: Data) throws -> UIImage {
        guard let image = try decoder.decodeImage(with: data)
        else {
            throw SVGDecoderError.undefined
        }

        return image
    }
}

extension SVGDecoderError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .undefined:
            return "Can't decode image from SVG data"
        }
    }
}
