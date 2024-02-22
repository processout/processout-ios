//
//  CameraPreviewView.swift
//  vision-test
//
//  Created by Andrii Vysotskyi on 26.01.2024.
//

import SwiftUI
import AVFoundation

struct CameraPreviewView: View {

    init(session: AVCaptureSession) {
        self.session = session
        self.cameraOrientation = .up
    }

    let session: AVCaptureSession

    // MARK: - View

    var body: some View {
        CameraPreviewViewRepresentable(session: session, cameraOrientation: $cameraOrientation)
            .preference(key: CameraPreviewOrientationPreferenceKey.self, value: cameraOrientation)
    }

    // MARK: - Private Properties

    @State
    private var cameraOrientation: CGImagePropertyOrientation
}

private struct CameraPreviewViewRepresentable: UIViewRepresentable {

    /// Associated capture session.
    let session: AVCaptureSession

    /// Applied rotation angle.
    let cameraOrientation: Binding<CGImagePropertyOrientation>

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> CameraPreviewUiView {
        CameraPreviewUiView(cameraOrientation: cameraOrientation)
    }

    func updateUIView(_ uiView: CameraPreviewUiView, context: Context) {
        uiView.setSession(session)
    }
}

private final class CameraPreviewUiView: UIView {

    init(cameraOrientation: Binding<CGImagePropertyOrientation>) {
        self.cameraOrientation = cameraOrientation
        super.init(frame: .zero)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UIView

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    override var layer: AVCaptureVideoPreviewLayer {
        super.layer as! AVCaptureVideoPreviewLayer // swiftlint:disable:this force_cast
    }

    // MARK: -

    func setSession(_ session: AVCaptureSession) {
        layer.session = session
        layer.connection?.videoOrientation = .portrait
    }

    // MARK: - Private Properties

    private let cameraOrientation: Binding<CGImagePropertyOrientation>

    // MARK: - Private Methods

    private func commonInit() {
        // Preview view only supports built-in cameras, so observing device orientation is safe.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceOrientationDidChange(notification:)),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        layer.videoGravity = .resizeAspectFill
    }

    @objc private func deviceOrientationDidChange(notification: Notification) {
        let rotationAngle: CGFloat
        switch window?.windowScene?.interfaceOrientation {
        case .landscapeLeft:
            rotationAngle = .pi / 2
            cameraOrientation.wrappedValue = .left
        case .portraitUpsideDown:
            rotationAngle = .pi
            cameraOrientation.wrappedValue = .down
        case .landscapeRight:
            rotationAngle = 3 * .pi / 2
            cameraOrientation.wrappedValue = .right
        default:
            rotationAngle = 0
            cameraOrientation.wrappedValue = .up
        }
        transform = .init(rotationAngle: rotationAngle)
    }
}
