//
//  CameraController.swift
//  mrzscanner
//
//  Created by xulihang on 2024/7/9.
//

import Foundation
import AVFoundation
import UIKit

class CameraController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    var previewView: PreviewView!
    var captureSession: AVCaptureSession!
    var videoOutput: AVCaptureVideoDataOutput!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.previewView = PreviewView()
        self.view.addSubview(self.previewView)
        startCamera()
    }
    
    func startCamera(){
        // Create the capture session.
        self.captureSession = AVCaptureSession()

        // Find the default audio device.
        guard let videoDevice = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            // Wrap the video device in a capture device input.
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            // If the input can be added, add it to the session.
            if self.captureSession.canAddInput(videoInput) {
                self.captureSession.addInput(videoInput)
                self.previewView.videoPreviewLayer.session = self.captureSession
                
                self.videoOutput = AVCaptureVideoDataOutput.init()
                if self.captureSession.canAddOutput(self.videoOutput) {
                    self.captureSession.addOutput(videoOutput)
                }
               
                
                self.captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
                
                var queue:DispatchQueue
                queue = DispatchQueue(label: "queue")
                self.videoOutput.setSampleBufferDelegate(self as AVCaptureVideoDataOutputSampleBufferDelegate, queue: queue)
                self.videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA] as [String : Any]
                self.captureSession.startRunning()
            }
            
        } catch {
            // Configuration failed. Handle error.
        }
    }
    

    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
        let imageBuffer:CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        let bufferSize = CVPixelBufferGetDataSize(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        let bpr = CVPixelBufferGetBytesPerRow(imageBuffer)
        CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly)
        let buffer = Data(bytes: baseAddress!, count: bufferSize)
     

        print("resolution")
        print(width)
        print(height)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let previewView = self.previewView {
            let width: CGFloat = view.frame.width
            let height: CGFloat = view.frame.height
            let x: CGFloat = 0.0
            let y: CGFloat = 0.0
            previewView.frame = CGRect.init(x: x, y: y, width: width, height: height)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.captureSession.startRunning()
    }

    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
}
