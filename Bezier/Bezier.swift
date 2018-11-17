//
//  Bezier.swift
//  Bezier
//
//  Created by Paweł Wszeborowski on 17/11/2018.
//  Copyright © 2018 Paweł Wszeborowski. All rights reserved.
//

import Foundation

struct Bezier {
    static let DRAWING_STEP: CGFloat = 0.01

    /// Linear interpolation.
    static func lerp(_ point1: CGPoint, _ point2: CGPoint, t: CGFloat) -> CGPoint {
        return CGPoint(
            x: (1 - t) * point1.x + t * point2.x,
            y: (1 - t) * point1.y + t * point2.y
        )
    }

    typealias LineSegment = (CGPoint, CGPoint)
    struct BezierCalculationResult {
        let segments: [LineSegment]
        let bezierPoint: CGPoint
    }

    /// Returns line segments used to derive the point and the point in the path for a given t.
    static func bezierSegmentsAndPoint(withControlPoints points: [CGPoint], t: CGFloat) -> BezierCalculationResult {
        guard points.count > 2 else {
            return .init(segments: [(points[0], points[1])], bezierPoint: lerp(points[0], points[1], t: t))
        }
        let segments = zip(points, points.dropFirst())
        let intermediatePoints = segments.map { lerp($0.0, $0.1, t: t) }
        let path = bezierSegmentsAndPoint(withControlPoints: intermediatePoints, t: t)
        return BezierCalculationResult(segments: Array(segments) + path.segments, bezierPoint: path.bezierPoint)
    }

    /// Returns points on the bezier path for t from startT to endT. Number of points depends on DRAWING_STEP.
    static func bezierPathPoints(withControlPoints points: [CGPoint], from startT: CGFloat, to endT: CGFloat) -> [CGPoint] {
        var pathPoints: [CGPoint] = []
        for t in stride(from: startT, through: endT, by: DRAWING_STEP) {
            pathPoints.append(bezierPoint(withControlPoints: points, t: t))
        }
        return pathPoints
    }

    /// Returns a point on a bezier path for a given t.
    private static func bezierPoint(withControlPoints points: [CGPoint], t: CGFloat) -> CGPoint {
        guard points.count > 2 else {
            return lerp(points[0], points[1], t: t)
        }
        let intermediatePoints = zip(points, points.dropFirst()).map { lerp($0.0, $0.1, t: t) }
        return bezierPoint(withControlPoints: intermediatePoints, t: t)
    }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}
