//
//  ViewController.swift
//  BioAuthentification
//
//  Created by Guillaume Lauzier on 2020-01-16.
//  Copyright © 2020 Guillaume Lauzier. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
    
    var context = LAContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        context.localizedCancelTitle = "My Cancel"
        context.localizedFallbackTitle = "Fallback!"
        context.localizedReason = "The app needs your authentication."
        context.touchIDAuthenticationAllowableReuseDuration = LATouchIDAuthenticationMaximumAllowableReuseDuration
        evaluatePolicy()
    }
    
    func evaluatePolicy() {
        var errorCanEval: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &errorCanEval) {
            
            switch context.biometryType {
            case .faceID:
                print ("face")
            case .touchID:
                print ("touch")
            case .none:
                print ("none")
            @unknown default:
                print ("unknown")
            }
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Fallback title - override reason") { (success, error) in
                print (success)
                if let err = error {
                    let evalErrCode = LAError(_nsError: err as NSError)
                    switch evalErrCode.code {
                    case LAError.Code.userCancel:
                        print ("user cancelled")
                    case LAError.Code.appCancel:
                        print ("app cancelled")
                    case LAError.Code.userFallback:
                        print ("fallback")
                        self.promptForCode()
                    case LAError.Code.authenticationFailed:
                        print  ("failed")
                    default:
                        print ("other error")
                        
                    }
                }
            }
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { (t) in
                self.context.invalidate()
            }
                
            
        } else {
            print ("can't evaluate")
            print (errorCanEval?.localizedDescription ?? "no error desc")
            if let err = errorCanEval {
                let evalErrCode = LAError(_nsError: err as NSError)
                switch evalErrCode.code {
                case LAError.Code.biometryNotEnrolled:
                    print ("not enrolled")
                default:
                    print ("other error")
                    
                }
            }
        }
        
    }
    
    func sendToSettings() {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Bio Enrollement", message: "Would you like to enroll now?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (aa) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
            ac.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(ac, animated: true, completion: nil)
        }
    }
    func promptForCode() {
        let ac = UIAlertController(title: "Enter Code", message: "Enter your user code.", preferredStyle: .alert)
        
        ac.addTextField { (tf) in
            tf.placeholder = "Enter User Code"
            tf.keyboardType = .numberPad
            tf.isSecureTextEntry = true
        }
        
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (aa) in
            print (ac.textFields?.first?.text ?? "no value")
        }))
        
        self.present(ac, animated: true, completion: nil)
    }

}

