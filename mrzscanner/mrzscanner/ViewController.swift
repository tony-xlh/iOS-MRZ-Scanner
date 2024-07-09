//
//  ViewController.swift
//  mrzscanner
//
//  Created by xulihang on 2024/7/9.
//

import UIKit
import DynamsoftLabelRecognizer

class ViewController: UIViewController {
    var button: UIButton!
    var label: UILabel!
    static var results:[iDLRResult]!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.button = UIButton(frame: .zero)
        self.button.setTitle("Scan MRZ", for: .normal)
        self.button.setTitleColor(.systemBlue, for: .normal)
        self.button.setTitleColor(.lightGray, for: .highlighted)

        self.button.addTarget(self,
                         action: #selector(buttonAction),
                         for: .touchUpInside)
        self.label = UILabel(frame: .zero)
        self.label.textAlignment = .center
        self.label.font = UIFont.monospacedSystemFont(ofSize: 16.0, weight: .regular)
        self.label.numberOfLines = 10
        self.navigationItem.title = "Home"
        
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.button)
        self.view.addSubview(self.label)
    }
    override func viewDidLayoutSubviews() {
       super.viewDidLayoutSubviews()
       if let button = self.button {
           let width: CGFloat = 300
           let height: CGFloat = 50
           let x = view.frame.width/2 - width/2
           let y = view.frame.height - 100
           button.frame = CGRect.init(x: x, y: y, width: width, height: height)
       }
        if let label = self.label {
            let width: CGFloat = 300
            let height: CGFloat = 100
            let x = view.frame.width/2 - width/2
            let y = view.frame.height - 200
            label.frame = CGRect.init(x: x, y: y, width: width, height: height)
        }
    }
   
    @objc
    func buttonAction() {
        print("button pressed")
        self.navigationController?.pushViewController(CameraController(), animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("did appear")
        let results = ViewController.results
        var MRZString = ""
        if results != nil {
            self.label.text = "done"
            for lineResult in results![0].lineResults! {
                print(lineResult.text!)
                MRZString = MRZString + lineResult.text! + "\n"
            }
        }
        self.label.text = MRZString
    }
}

