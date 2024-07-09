//
//  CameraController.swift
//  mrzscanner
//
//  Created by xulihang on 2024/7/9.
//

import Foundation
import AVFoundation
import UIKit
import DynamsoftCore
import DynamsoftLabelRecognizer

class CameraController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    var recognizer:DynamsoftLabelRecognizer = DynamsoftLabelRecognizer();
    var previewView: PreviewView!
    var captureSession: AVCaptureSession!
    var videoOutput: AVCaptureVideoDataOutput!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.previewView = PreviewView()
        self.view.addSubview(self.previewView)
        setupDLRForMRZ()
        startCamera()
    }
    
    func setupDLRForMRZ(){
        loadModel()
        let template = "{\"CharacterModelArray\":[{\"DirectoryPath\":\"\",\"Name\":\"MRZ\"}],\"LabelRecognizerParameterArray\":[{\"Name\":\"default\",\"ReferenceRegionNameArray\":[\"defaultReferenceRegion\"],\"CharacterModelName\":\"MRZ\",\"LetterHeightRange\":[5,1000,1],\"LineStringLengthRange\":[30,44],\"LineStringRegExPattern\":\"([ACI][A-Z<][A-Z<]{3}[A-Z0-9<]{9}[0-9][A-Z0-9<]{15}){(30)}|([0-9]{2}[(01-12)][(01-31)][0-9][MF<][0-9]{2}[(01-12)][(01-31)][0-9][A-Z<]{3}[A-Z0-9<]{11}[0-9]){(30)}|([A-Z<]{0,26}[A-Z]{1,3}[(<<)][A-Z]{1,3}[A-Z<]{0,26}<{0,26}){(30)}|([ACIV][A-Z<][A-Z<]{3}([A-Z<]{0,27}[A-Z]{1,3}[(<<)][A-Z]{1,3}[A-Z<]{0,27}){(31)}){(36)}|([A-Z0-9<]{9}[0-9][A-Z<]{3}[0-9]{2}[(01-12)][(01-31)][0-9][MF<][0-9]{2}[(01-12)][(01-31)][0-9][A-Z0-9<]{8}){(36)}|([PV][A-Z<][A-Z<]{3}([A-Z<]{0,35}[A-Z]{1,3}[(<<)][A-Z]{1,3}[A-Z<]{0,35}<{0,35}){(39)}){(44)}|([A-Z0-9<]{9}[0-9][A-Z<]{3}[0-9]{2}[(01-12)][(01-31)][0-9][MF<][0-9]{2}[(01-12)][(01-31)][0-9][A-Z0-9<]{14}[A-Z0-9<]{2}){(44)}\",\"MaxLineCharacterSpacing\":130,\"TextureDetectionModes\":[{\"Mode\":\"TDM_GENERAL_WIDTH_CONCENTRATION\",\"Sensitivity\":8}],\"Timeout\":9999}],\"LineSpecificationArray\":[{\"BinarizationModes\":[{\"BlockSizeX\":30,\"BlockSizeY\":30,\"Mode\":\"BM_LOCAL_BLOCK\",\"MorphOperation\":\"Close\"}],\"LineNumber\":\"\",\"Name\":\"defaultTextArea->L0\"}],\"ReferenceRegionArray\":[{\"Localization\":{\"FirstPoint\":[0,0],\"SecondPoint\":[100,0],\"ThirdPoint\":[100,100],\"FourthPoint\":[0,100],\"MeasuredByPercentage\":1,\"SourceType\":\"LST_MANUAL_SPECIFICATION\"},\"Name\":\"defaultReferenceRegion\",\"TextAreaNameArray\":[\"defaultTextArea\"]}],\"TextAreaArray\":[{\"Name\":\"defaultTextArea\",\"LineSpecificationNameArray\":[\"defaultTextArea->L0\"]}]}"
        try? recognizer.initRuntimeSettings(template)
    }
    
    func loadModel(){
        let modelFolder = "MRZ"
        let modelFileNames = ["MRZ"]
       
        for model in modelFileNames {
            
            guard let prototxt = Bundle.main.url(
                forResource: model,
                withExtension: "prototxt",
                subdirectory: modelFolder
            ) else {
                print("model not exist")
                return
            }

            let datapro = try! Data.init(contentsOf: prototxt)
            let txt = Bundle.main.url(forResource: model, withExtension: "txt", subdirectory: modelFolder)
            let datatxt = try! Data.init(contentsOf: txt!)
            let caffemodel = Bundle.main.url(forResource: model, withExtension: "caffemodel", subdirectory: modelFolder)
            let datacaf = try! Data.init(contentsOf: caffemodel!)
            DynamsoftLabelRecognizer.appendCharacterModel(model, prototxtBuffer: datapro, txtBuffer: datatxt, characterModelBuffer: datacaf)
            print("load model %@", model)
        }
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
     
        let imageData = iImageData.init()
        imageData.bytes = buffer
        imageData.width = width
        imageData.height = height
        imageData.stride = bpr
        imageData.format = .ARGB_8888
        imageData.orientation = 90
        let results = try? recognizer.recognizeBuffer(imageData)
        print("resolution")
        print(width)
        print(height)
        if results != nil {
            if (results?.count ?? 0 > 0) {
                if (results?[0].lineResults?.count ?? 0 >= 2) {
                    returnWithResults(results: results!)
                }
            }
        }
    }
    
    func returnWithResults(results:[iDLRResult]){
        ViewController.results = results
        self.captureSession.stopRunning()
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
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
