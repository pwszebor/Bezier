//
//  MainViewController.swift
//  Bezier
//
//  Created by Paweł Wszeborowski on 17/11/2018.
//  Copyright © 2018 Paweł Wszeborowski. All rights reserved.
//

import AppKit

fileprivate let POINT_SIZE = CGSize(width: 20, height: 20)
fileprivate let CONTROL_POINT_SIZE = POINT_SIZE.applying(.init(scaleX: 0.75, y: 0.75))
fileprivate let SEGMENT_POINT_SIZE = POINT_SIZE.applying(.init(scaleX: 0.5, y: 0.5))

class MainViewController: NSViewController {
    private lazy var slider = NSSlider(value: 0, minValue: 0, maxValue: 1, target: self, action: #selector(sliderValueChanged))
    private lazy var clearButton = NSButton(title: "Clear", target: self, action: #selector(clear))
    private lazy var drawSegmentsButton = NSButton(checkboxWithTitle: "Draw segments", target: self, action: #selector(drawSegmentsButtonPressed))
    private lazy var drawBezierButton = NSButton(checkboxWithTitle: "Draw path", target: self, action: #selector(drawBezierButtonPressed))
    private let canvas = CanvasView()

    private lazy var pressGestureRecognizer = NSPressGestureRecognizer(target: self, action: #selector(tappedCanvas))
    private lazy var panGestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(movedPoint))

    private static let MAX_CONTROL_POINTS = 10

    private var startPoint: PointView?
    private var endPoint: PointView?
    private var points = [PointView]()

    private weak var draggedPoint: PointView?
    private var draggedPointOrigin = CGPoint.zero

    private var colors = Colors() {
        didSet {
            updateView()
        }
    }

    private var t: CGFloat = 0 {
        didSet {
            updateView()
        }
    }

    private var drawLineSegments = true {
        didSet {
            updateView()
        }
    }

    private var drawBezierPath = true {
        didSet {
            updateView()
        }
    }

    override func loadView() {
        view = NSView(frame: NSApp.keyWindow?.frame ?? .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        slider.numberOfTickMarks = 5
        slider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(slider)
        view.addConstraints([
            slider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            slider.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        ])

        drawBezierButton.state = .on
        drawBezierButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(drawBezierButton)
        view.addConstraints([
            drawBezierButton.leftAnchor.constraint(equalTo: slider.rightAnchor, constant: 10),
            drawBezierButton.centerYAnchor.constraint(equalTo: slider.centerYAnchor)
        ])

        drawSegmentsButton.state = .on
        drawSegmentsButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(drawSegmentsButton)
        view.addConstraints([
            drawSegmentsButton.leftAnchor.constraint(equalTo: drawBezierButton.rightAnchor, constant: 10),
            drawSegmentsButton.centerYAnchor.constraint(equalTo: slider.centerYAnchor)
        ])

        clearButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clearButton)
        view.addConstraints([
            clearButton.leftAnchor.constraint(equalTo: drawSegmentsButton.rightAnchor, constant: 10),
            clearButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            clearButton.centerYAnchor.constraint(equalTo: slider.centerYAnchor)
        ])

        canvas.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvas)
        view.addConstraints([
            canvas.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            canvas.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            canvas.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            canvas.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -10)
        ])

        pressGestureRecognizer.delegate = self
        pressGestureRecognizer.minimumPressDuration = 0.1
        canvas.addGestureRecognizer(pressGestureRecognizer)

        panGestureRecognizer.delegate = self
        canvas.addGestureRecognizer(panGestureRecognizer)
    }

    @objc private func clear() {
        startPoint?.removeFromSuperview()
        startPoint = nil
        endPoint?.removeFromSuperview()
        endPoint = nil
        points.forEach { $0.removeFromSuperview() }
        points = []
        canvas.reset()
    }

    @objc private func drawSegmentsButtonPressed() {
        drawLineSegments = drawSegmentsButton.state == .on
    }

    @objc private func drawBezierButtonPressed() {
        drawBezierPath = drawBezierButton.state == .on
    }

    @objc private func sliderValueChanged() {
        t = CGFloat(slider.floatValue)
    }

    private func updateView() {
        guard let startPoint = startPoint, let endPoint = endPoint, !points.isEmpty else { return }
        canvas.reset()

        startPoint.color = colors.startPoint
        endPoint.color = colors.endPoint
        points.forEach { $0.color = colors.controlPoint }

        let controlPoints = [[startPoint], points, [endPoint]].flatMap { $0 }.map { $0.frame.center }

        let bezierPath = Bezier.bezierSegmentsAndPoint(withControlPoints: controlPoints, t: t)

        canvas.drawPoint(bezierPath.bezierPoint, size: POINT_SIZE, color: colors.bezierPoint)

        if drawLineSegments {
            bezierPath.segments.forEach {
                canvas.drawLine($0.0, $0.1, lineColor: colors.segmentLine, pointSize: SEGMENT_POINT_SIZE, pointColor: colors.segmentPoint)
            }
        }

        if drawBezierPath {
            canvas.drawPath(points: Bezier.bezierPathPoints(withControlPoints: controlPoints, from: 0, to: t), color: colors.bezierLine)
        }
    }
}

extension MainViewController { // creating points
    @objc private func tappedCanvas() {
        canvas.removeGestureRecognizer(pressGestureRecognizer)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.canvas.addGestureRecognizer(self.pressGestureRecognizer)
        }
        guard points.count < MainViewController.MAX_CONTROL_POINTS - 2 else {
            return
        }
        let point: PointView
        let size: CGSize
        if startPoint == nil {
            point = PointView(color: colors.startPoint)
            size = POINT_SIZE
            startPoint = point
        } else if endPoint == nil {
            point = PointView(color: colors.endPoint)
            size = POINT_SIZE
            endPoint = point
        } else {
            point = PointView(color: colors.controlPoint)
            size = CONTROL_POINT_SIZE
            points.append(point)
        }
        canvas.addSubview(point)
        point.frame = CGRect(origin: pressGestureRecognizer.location(in: canvas).applying(.init(translationX: -size.width / 2, y: -size.height / 2)), size: size)

        updateView()
    }
}

extension MainViewController { // moving points around canvas
    @objc private func movedPoint() {
        let location = panGestureRecognizer.location(in: canvas)
        switch panGestureRecognizer.state {
        case .began:
            draggedPoint = canvas.subviews.compactMap { $0 as? PointView }.first { $0.frame.contains(location) }
            draggedPointOrigin = draggedPoint?.frame.origin ?? .zero
        case .changed:
            guard let draggedPoint = draggedPoint else { break }
            let totalTranslation = panGestureRecognizer.translation(in: canvas)
            draggedPoint.frame.origin = draggedPointOrigin.applying(.init(translationX: totalTranslation.x, y: totalTranslation.y))
            updateView()
        default:
            break
        }
    }
}

extension MainViewController: NSGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: NSGestureRecognizer) -> Bool {
        var allPointsFrames: [CGRect] = points.map { $0.frame }
        if let startPointFrame = startPoint?.frame {
            allPointsFrames.append(startPointFrame)
        }
        if let endPointFrame = endPoint?.frame {
            allPointsFrames.append(endPointFrame)
        }
        let gesturePoint = gestureRecognizer.location(in: canvas)
        let pressedInPoint = allPointsFrames.contains { $0.contains(gesturePoint) }
        switch gestureRecognizer {
        case panGestureRecognizer:
            return pressedInPoint
        case pressGestureRecognizer:
            return !pressedInPoint
        default:
            return true
        }
    }
}
