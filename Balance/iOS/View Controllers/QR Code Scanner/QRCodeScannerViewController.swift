//
//  QRCodeScannerViewController.swift
//  BalanceiOS
//
//  Created by Red Davis on 13/11/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import AVFoundation
import UIKit


internal final  class QRCodeScannerViewController: UIViewController {
    // Private
    private let session: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        
        return session
    }()
    
    private let videoLayerContainer = UIView()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        
        return button
    }()
    
    private let processingQueue = DispatchQueue.global(qos: .userInitiated)
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View layer container
        self.videoLayerContainer.backgroundColor = UIColor.black
        self.view.addSubview(self.videoLayerContainer)
        
        self.videoLayerContainer.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // Cancel button
        self.cancelButton.isHidden = true
        self.cancelButton.addTarget(self, action: #selector(self.cancelButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(self.cancelButton)
        
        self.cancelButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.right.equalToSuperview().inset(20.0)
            make.left.equalToSuperview().inset(20.0)
            make.height.equalTo(50.0)
        }
        
        // Capture configuration
        self.configureCapture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.videoLayerContainer.layer.sublayers?.forEach({ (layer) in
            layer.frame = self.videoLayerContainer.bounds
        })
    }
    
    // MARK: Capture configuration
    
    private func configureCapture()
    {
        let metadataOutput = AVCaptureMetadataOutput()
        metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        metadataOutput.setMetadataObjectsDelegate(self, queue: self.processingQueue)
        
        guard let backCamera = self.defaultBackCamera(),
            let captureDeviceInput = try? AVCaptureDeviceInput(device: backCamera),
            self.session.canAddInput(captureDeviceInput),
            self.session.canAddOutput(metadataOutput) else {
            return
        }
        
        self.session.addInput(captureDeviceInput)
        self.session.addOutput(metadataOutput)
        
        // Preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        previewLayer.frame = self.videoLayerContainer.bounds
        
        self.previewLayer = previewLayer
        self.videoLayerContainer.layer.addSublayer(previewLayer)
        
        // Start session
        self.session.startRunning()
    }
    
    private func defaultBackCamera() -> AVCaptureDevice? {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        } else {
            return nil
        }
    }
    
    // MARK: Actions
    
    @objc private func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: AVCaptureMetadataOutputObjectsDelegate

extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  object.type == .qr else {
            return
        }
        
        print(object.stringValue)
    }
}
