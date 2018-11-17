//
//  CanvasView.swift
//  Bezier
//
//  Created by Paweł Wszeborowski on 17/11/2018.
//  Copyright © 2018 Paweł Wszeborowski. All rights reserved.
//

import AppKit

class CanvasView: NSView {
    private var dashedLines = [(CGPoint, CGPoint, NSColor)]()
    private var points = [(CGPoint, CGSize, NSColor)]()
    private var bezierPath: ([CGPoint], NSColor)?

    init() {
        super.init(frame: .zero)
        wantsLayer = true
        layer?.borderColor = .white
        layer?.borderWidth = 1
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        for line in dashedLines {
            let (p1, p2, color) = line

            let path = NSBezierPath()
            path.move(to: p1)
            path.line(to: p2)

            path.lineWidth = 2

            let pattern: [CGFloat] = [5, 2]
            path.setLineDash(pattern, count: 2, phase: 0)

            color.setStroke()
            path.stroke()
        }

        if let bezierPath = bezierPath {
            let path = NSBezierPath()
            path.lineWidth = 3
            var points = bezierPath.0
            path.move(to: points[0])
            path.appendPoints(&points, count: points.count)
            bezierPath.1.setStroke()
            path.stroke()
        }

        for point in points {
            let (center, size, color) = point
            let path = NSBezierPath(ovalIn: NSRect(origin: center.applying(.init(translationX: -size.width / 2, y: -size.height / 2)), size: size))
            color.setFill()
            path.fill()
        }
    }

    func drawLine(_ p1: CGPoint, _ p2: CGPoint, lineColor: NSColor, pointSize: CGSize, pointColor: NSColor) {
        dashedLines.append((p1, p2, lineColor))
        points.append((p1, pointSize, pointColor))
        points.append((p2, pointSize, pointColor))
        setNeedsDisplay(frame)
    }

    func drawPoint(_ point: CGPoint, size: CGSize, color: NSColor) {
        points.append((point, size, color))
        setNeedsDisplay(frame)
    }

    func drawPath(points: [CGPoint], color: NSColor) {
        bezierPath = (points, color)
        setNeedsDisplay(frame)
    }

    func reset() {
        dashedLines = []
        points = []
        bezierPath = nil
        setNeedsDisplay(frame)
    }
}
