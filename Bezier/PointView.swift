//
//  PointView.swift
//  Bezier
//
//  Created by Paweł Wszeborowski on 17/11/2018.
//  Copyright © 2018 Paweł Wszeborowski. All rights reserved.
//

import AppKit

class PointView: NSView {
    var color: NSColor {
        didSet {
            setNeedsDisplay(frame)
        }
    }

    init(color: NSColor) {
        self.color = color
        super.init(frame: .zero)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        color.setFill()
        NSBezierPath(ovalIn: dirtyRect).fill()
        super.draw(dirtyRect)
    }
}
