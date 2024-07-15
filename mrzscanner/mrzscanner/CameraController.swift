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
import DynamsoftCameraEnhancer
import DynamsoftCaptureVisionRouter
import DynamsoftUtility
import DynamsoftCodeParser

class CameraController: UIViewController, CapturedResultReceiver {
    var scannedResults:[String] = []
    private var cvr: CaptureVisionRouter!
    private var dce: CameraEnhancer!
    private var dceView: CameraView!
    private var dlrDrawingLayer: DrawingLayer!
    private var resultFilter: MultiFrameResultCrossFilter!
    
    private var templateName = "ReadPassport"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        configureDCE()
        configureCVR()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dce.open()
        cvr.startCapturing(templateName)
    }
    
    private func configureCVR() -> Void {
        cvr = CaptureVisionRouter()

        try? cvr.initSettingsFromFile("PassportScanner.json")
        try? cvr.setInput(dce)
        
        // Add filter.
        resultFilter = MultiFrameResultCrossFilter()
        resultFilter.enableResultCrossVerification(.textLine, isEnabled: true)
        cvr.addResultFilter(resultFilter)
        cvr.addResultReceiver(self)
    }
    
    private func configureDCE() -> Void {
        dceView = CameraView(frame: self.view.bounds)
        dceView.scanLaserVisible = true
        dceView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(dceView)
        
        dlrDrawingLayer = dceView.getDrawingLayer(DrawingLayerId.DLR.rawValue)
        dlrDrawingLayer.visible = true
        dce = CameraEnhancer(view: dceView)
        dce.enableEnhancedFeatures(.frameFilter)
   }
    
    
    @objc func rotated() {
        layoutPreview()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutPreview()
    }
    
    func layoutPreview(){
        let bounds = view.bounds
        self.dceView.frame = bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        self.cvr.stopCapturing()
        self.dce.clearBuffer()
    }
    
    func onParsedResultsReceived(_ result: ParsedResult) {
        // Deal with the parsed results.
        print("parsed")
        if (result.items?.count ?? 0 > 0) {
            ViewController.result = result
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
