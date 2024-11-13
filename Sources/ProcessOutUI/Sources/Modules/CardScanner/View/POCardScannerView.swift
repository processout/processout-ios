//
//  POCardScannerView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 12.11.2024.
//

import SwiftUI
import AVFoundation

@_spi(PO) import ProcessOutCoreUI

@_spi(PO)
@available(iOS 14, *)
public struct POCardScannerView: View {

    public init() {
        // Ignored
    }

    // MARK: - View

    public var body: some View {
        VStack(spacing: POSpacing.medium) {
            Text(viewModel.title)
            POCameraPreviewView(session: viewModel.captureSession)
                .frame(width: 200, height: 200 / 1.586) // ISO/IEC 7810 based Aspect Ratio
        }
        .padding(.vertical, POSpacing.medium)
        .padding(.horizontal, POSpacing.large)
    }

    // MARK: - Private Properties

    @StateObject
    private var viewModel = DefaultCardScannerViewModel()
}

@MainActor
final class DefaultCardScannerViewModel: ObservableObject {

    init() {
        self.cameraCoordinator = .init()
        start()
    }

    // MARK: - CardScannerViewModel

    /// Screen title.
    var title: String {
        "card scanner"
    }

    /// Capture session.
    var captureSession: AVCaptureSession {
        cameraCoordinator.session
    }

    // MARK: - Private Properties

    private let cameraCoordinator: CameraCoordinator

    // MARK: - Private Methods

    private func start() {
        Task {
            await cameraCoordinator.start()
        }
        // todo: detect any errors, like the fact that user didn't give camera permission
    }
}

@_spi(PO)
public struct POCameraPreviewOrientationPreferenceKey: PreferenceKey {

    public static var defaultValue: CGImagePropertyOrientation = .up

    public static func reduce(value: inout CGImagePropertyOrientation, nextValue: () -> CGImagePropertyOrientation) {
        value = nextValue()
    }
}

@_spi(PO)
public struct POCameraPreviewView: View {

    public init(session: AVCaptureSession) {
        self.session = session
    }

    public let session: AVCaptureSession

    // MARK: - View

    public var body: some View {
        CameraPreviewViewRepresentable(session: session)
    }
}

private struct CameraPreviewViewRepresentable: UIViewRepresentable {

    /// Associated capture session.
    let session: AVCaptureSession

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> CameraPreviewUiView {
        CameraPreviewUiView()
    }

    func updateUIView(_ uiView: CameraPreviewUiView, context: Context) {
        uiView.setSession(session)
    }
}

private final class CameraPreviewUiView: UIView {

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

    // MARK: -

    func setSession(_ session: AVCaptureSession) {
        layer.session = session
        if let device = layer.connection?.firstVideoCaptureInput?.device {
            layer.connection?.automaticallyAdjustsVideoMirroring = false
            layer.connection?.isVideoMirrored = false
//            if device.position == .front {
                layer.transform = CATransform3DMakeScale(-1, 1, 1)
//            } else {
                layer.transform = CATransform3DMakeScale(1, 1, 1)
//            }
        }

        // there seems to be no reason to apply transformation to connection,
        // if device is known to be frontal camera, output should be mirrored
    }

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
//            cameraOrientation.wrappedValue = .left
        case .portraitUpsideDown:
            rotationAngle = .pi
//            cameraOrientation.wrappedValue = .down
        case .landscapeRight:
            rotationAngle = 3 * .pi / 2
//            cameraOrientation.wrappedValue = .right
        default:
            rotationAngle = 0
//            cameraOrientation.wrappedValue = .up
        }
//         transform = .init(rotationAngle: rotationAngle)
    }
}

extension AVCaptureConnection {

    var firstVideoCaptureInput: AVCaptureDeviceInput? {
        for port in inputPorts where port.mediaType == .video {
            guard let input = port.input as? AVCaptureDeviceInput else {
                continue
            }
            return input
        }
        return nil
    }
}
