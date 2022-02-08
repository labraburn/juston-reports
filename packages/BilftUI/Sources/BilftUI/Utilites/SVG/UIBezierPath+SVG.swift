//
//  Created by Anton Spivak
//

import UIKit

public extension UIBezierPath {
    enum UIBezierPathConvertingError: Error {
        case pointCount
        case unsupportedCommand
    }

    convenience init(elements: [SVG.Element]) throws {
        self.init()

        let get = { (_ index: Int, _ count: Int) throws -> [CGPoint] in
            var result: [CGPoint] = []
            for i in stride(from: index, to: index + count * 2, by: 2) {
                let ie = elements[i + 1]
                let iep = elements[i + 2]
                switch (ie, iep) {
                case let (.number(x), .number(y)):
                    result.append(CGPoint(x: x, y: y))
                default:
                    throw UIBezierPathConvertingError.pointCount
                }
            }
            return result
        }

        for var i in 0 ..< elements.count {
            switch elements[i] {
            case let .command(value):
                switch value {
                case "M":
                    let points = try get(i, 1)
                    move(to: points[0])
                    i += 2
                case "v", "V", "h", "H":
                    // Skip V and H lines
                    i += 2
                case "l", "L":
                    let points = try get(i, 1)
                    addLine(to: points[0])
                    i += 2
                case "c", "C":
                    let points = try get(i, 3)
                    addCurve(to: points[2], controlPoint1: points[0], controlPoint2: points[1])
                    i += 6
                case "q", "Q":
                    let points = try get(i, 2)
                    addQuadCurve(to: points[1], controlPoint: points[0])
                    i += 4
                case "Z":
                    close()
                default:
                    throw UIBezierPathConvertingError.unsupportedCommand
                }
            case .number:
                break
            }
        }
    }
}
