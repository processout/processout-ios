//
//  CameraPreviewView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.11.2024.
//

import AVFoundation
import SwiftUI
@_spi(PO) import ProcessOutCoreUI

struct CameraPreviewView: View {

    var body: some View {
        CameraPreviewViewRepresentable().clipped()
    }
}

private struct CameraPreviewViewRepresentable: UIViewRepresentable {

    func makeUIView(context: Context) -> CameraPreviewUiView {
        CameraPreviewUiView()
    }

    func updateUIView(_ uiView: CameraPreviewUiView, context: Context) {
        uiView.setPreviewSource(context.environment.cameraSessionPreviewSource)
    }
}

private final class CameraPreviewUiView: UIView, CameraSessionPreviewTarget {

    init() {
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

    override static var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    override var layer: AVCaptureVideoPreviewLayer {
        super.layer as! AVCaptureVideoPreviewLayer // swiftlint:disable:this force_cast
    }

    // MARK: - Preview Target

    func setPreviewSource(_ source: CameraSessionPreviewSource?) {
        if let source {
            source.connect(to: self)
        } else {
            layer.session = nil
        }
    }

    func setCameraSession(_ cameraSession: CameraSession, captureSession: AVCaptureSession) {
        guard layer.session != captureSession else {
            return
        }
        guard let videoPort = videoPort(with: captureSession) else {
            return
        }
        let connection = AVCaptureConnection(inputPort: videoPort, videoPreviewLayer: layer)
        Task { @MainActor in
            await cameraSession.addConnection(connection)
            updateInterfaceOrientation()
        }
        layer.setSessionWithNoConnection(captureSession)
    }

    // MARK: - Private Methods

    private func commonInit() {
        observeDeviceOrientation()
        layer.videoGravity = .resizeAspectFill
    }

    // MARK: - Device Orientation

    private func observeDeviceOrientation() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateInterfaceOrientation),
            name: UIDevice.orientationDidChangeNotification,
            object: UIDevice.current
        )
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        updateInterfaceOrientation()
    }

    @objc
    private func updateInterfaceOrientation() {
        let interfaceOrientation = window?.windowScene?.interfaceOrientation ?? .unknown
        let rotationAngle: CGFloat
        if let session = layer.session, shouldMatchInputDeviceOrientation(in: session) {
            switch interfaceOrientation {
            case .landscapeLeft:
                rotationAngle = .pi / 2
            case .portraitUpsideDown:
                rotationAngle = .pi
            case .landscapeRight:
                rotationAngle = 3 * .pi / 2
            default:
                rotationAngle = 0
            }
        } else {
            rotationAngle = 0
        }
        transform = .init(rotationAngle: rotationAngle)
    }

    private func shouldMatchInputDeviceOrientation(in session: AVCaptureSession) -> Bool {
        videoPort(with: session)?.sourceDevicePosition != .unspecified
    }

    private func videoPort(with session: AVCaptureSession) -> AVCaptureInput.Port? {
        let videoInputs = session.inputs.compactMap { input in
            input as? AVCaptureDeviceInput
        }
        guard let videoInput = videoInputs.first else {
            return nil
        }
        return videoInput.ports(for: .video, sourceDeviceType: nil, sourceDevicePosition: .unspecified).first
    }
}
