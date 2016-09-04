//
//  CameraHandler.swift
//  qeeptouch
//
//  Created by Javier Loucim on 9/4/16.
//  Copyright © 2016 QeepTouch. All rights reserved.
//  Thanks to mauricioconde from StackOverflow
//

import Foundation
import AVFoundation
import UIKit


// AVCaptureVideoDataOutputSampleBufferDelegate protocol and related methods
protocol  CameraHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    var session:AVCaptureSession { get set }
    var captureDevice : AVCaptureDevice? { get set }
    var videoDataOutput: AVCaptureVideoDataOutput { get set }
    var videoDataOutputQueue : dispatch_queue_t? { get set }
    var previewLayer:AVCaptureVideoPreviewLayer { get set }
    var currentFrame:CIImage { get set }
    var cameraPreviewView:UIView! { get set }
    var isCameraRunning:Bool { get set }
    var isSetupCompleted:Bool { get set }
}

extension CameraHandler  {
    func setupAVCapture(){
        session.sessionPreset = AVCaptureSessionPreset640x480;
        
        let devices = AVCaptureDevice.devices();
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the front camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice;
                    if captureDevice != nil {
                        isSetupCompleted = true
                        beginSession();
                        isCameraRunning = true;
                        break;
                    }
                }
            }
        }
    }
    
    func beginSession(){
        var err : NSError? = nil
        var deviceInput:AVCaptureDeviceInput?
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error as NSError {
            err = error
            deviceInput = nil
        };
        if err != nil {
            print("error: \(err?.localizedDescription)");
        }
        if self.session.canAddInput(deviceInput){
            self.session.addInput(deviceInput);
        }
        
        self.videoDataOutput = AVCaptureVideoDataOutput();
        self.videoDataOutput.alwaysDiscardsLateVideoFrames=true;
        self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
        self.videoDataOutput.setSampleBufferDelegate(self, queue:self.videoDataOutputQueue);
        if session.canAddOutput(self.videoDataOutput){
            session.addOutput(self.videoDataOutput);
        }
        self.videoDataOutput.connectionWithMediaType(AVMediaTypeVideo).enabled = true;
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session);
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        
        let rootLayer :CALayer = self.cameraPreviewView.layer;
        rootLayer.masksToBounds=true;
        self.previewLayer.frame = rootLayer.bounds;
        rootLayer.addSublayer(self.previewLayer);
        session.startRunning();
        
    }
    
    func startRunning() {
        if !isCameraRunning {
            session.startRunning();
            isCameraRunning = true
        }
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        currentFrame =   self.convertImageFromCMSampleBufferRef(sampleBuffer);
        
        
    }
    
    // clean up AVCapture
    func stopCamera(){
        session.stopRunning()
        isCameraRunning = false;
    }
    
    func convertImageFromCMSampleBufferRef(sampleBuffer:CMSampleBuffer) -> CIImage{
        let pixelBuffer:CVPixelBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!;
        let ciImage:CIImage = CIImage(CVPixelBuffer: pixelBuffer)
        return ciImage;
    }
}
