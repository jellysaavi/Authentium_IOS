//
//  BarCodeScanView.swift
//  Saavi
//
//  Created by gomad on 16/05/19.
//  Copyright © 2019 Saavi. All rights reserved.
//

import AVFoundation

/// Delegate callback for the QRScannerView.
protocol BarScannerViewDelegate: class {
    func barScanningDidFail()
    func barScanningSucceededWithCode(_ str: String?)
    func barScanningDidStop()
}

class BarCodeScanView: UIView {
    
    static var storyBoardIdentifier = "BarCodeScanViewController"
    weak var delegate: BarScannerViewDelegate?
    
    /// capture settion which allows us to start and stop scanning.
    var captureSession: AVCaptureSession?
    var isRunning:Bool = true

    // Init methods..
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        doInitialSetup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        doInitialSetup()
    }
    
    //MARK: overriding the layerClass to return `AVCaptureVideoPreviewLayer`.
    override class var layerClass: AnyClass  {
        return AVCaptureVideoPreviewLayer.self
    }
    override var layer: AVCaptureVideoPreviewLayer {
        return super.layer as! AVCaptureVideoPreviewLayer
    }
    
}

extension BarCodeScanView {
    
    func startScanning() {
        captureSession?.startRunning()
    }
    
    func stopScanning() {
        captureSession?.stopRunning()
        delegate?.barScanningDidStop()
    }
    
    /// Does the initial setup for captureSession
    private func doInitialSetup() {
        clipsToBounds = true
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch let error {
            print(error)
            return
        }
        
        if (captureSession?.canAddInput(videoInput) ?? false) {
            captureSession?.addInput(videoInput)
        } else {
            scanningDidFail()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession?.canAddOutput(metadataOutput) ?? false) {
            captureSession?.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13,.code128]
            metadataOutput.rectOfInterest = self.frame
        } else {
            scanningDidFail()
            return
        }
        
        self.layer.session = captureSession
        self.layer.videoGravity = .resizeAspectFill
        self.layer.frame = self.bounds
        self.layer.connection?.videoOrientation = self.transformOrientation(orientation: UIInterfaceOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!)
        self.captureSession?.startRunning()
    }
    
    func transformOrientation(orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
    
    func scanningDidFail() {
        delegate?.barScanningDidFail()
        captureSession = nil
    }
    
    func found(code: String) {
        delegate?.barScanningSucceededWithCode(code)
    }
    
}

extension BarCodeScanView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        
        //self.captureSession?.stopRunning()
        if self.isRunning {
            self.isRunning = false
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                found(code: stringValue)
            }
        }
    }
}
