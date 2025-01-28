//
//  CameraPreviewView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.11.2024.
//

import AVFoundation
import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@MainActor
struct CameraPreviewView: View {

    var body: some View {
        CameraPreviewViewRepresentable().clipped()
    }
}

@MainActor
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
        removePreviewLayerFromCameraSession()
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
            removePreviewLayerFromCameraSession()
        }
    }

    func setCameraSession(_ cameraSession: CameraSession) {
        Task { @MainActor in
            await cameraSession.addPreviewLayer(layer)
            updateInterfaceOrientation()
        }
        self.cameraSession = cameraSession
    }

    // MARK: - Private Properties

    private weak var cameraSession: CameraSession?

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
        if shouldMatchInputDeviceOrientation() {
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

    private func shouldMatchInputDeviceOrientation() -> Bool {
        let videoPort = layer.connection?.inputPorts.first { port in
            port.mediaType == .video
        }
        return videoPort?.sourceDevicePosition != .unspecified
    }

    // MARK: -

    private func removePreviewLayerFromCameraSession() {
        Task { @MainActor [layer, cameraSession] in
            await cameraSession?.removePreviewLayer(layer)
        }
    }
}
