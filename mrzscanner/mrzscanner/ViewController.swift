//
//  ViewController.swift
//  mrzscanner
//
//  Created by xulihang on 2024/7/9.
//

import UIKit
import DynamsoftCodeParser

class ViewController: UIViewController {
    var button: UIButton!
    var label: UILabel!
    static var result:ParsedResult!
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
        self.label.textAlignment = .left
        self.label.font = UIFont.monospacedSystemFont(ofSize: 16.0, weight: .regular)
        self.label.numberOfLines = 20
        self.label.lineBreakMode = .byClipping
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
        let result = ViewController.result
        if result != nil {
            var parsed = ""
            parsed = parsed + "No.: " + result!.items![0].parsedFields["passportNumber"]! + "\n"
            parsed = parsed + "Country.: " + result!.items![0].parsedFields["nationality"]! + "\n"
            parsed = parsed + "Given names: " + result!.items![0].parsedFields["secondaryIdentifier"]! + "\n"
            parsed = parsed + "Surname: " + result!.items![0].parsedFields["primaryIdentifier"]! + "\n"

            parsed = parsed + "Date of birth: " + result!.items![0].parsedFields["dateOfBirth"]! + "\n"
            self.label.text = parsed
        }
    }
}

