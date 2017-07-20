//
//  ViewController.swift
//  Project28
//
//  Created by Macbook on 18/07/2017.
//  Copyright © 2017 Chappy-App. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {

  @IBOutlet weak var secret: UITextView!
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Nothing to see here"
    
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
    notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: Notification.Name.UIApplicationWillResignActive, object: nil)
    
    
  }
  
  func adjustForKeyboard(notification: Notification) {
    let userInfo = notification.userInfo!
    
    let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
    
    if notification.name == Notification.Name.UIKeyboardWillHide {
      secret.contentInset = UIEdgeInsets.zero
      
    } else {
      secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
      
    }
    
    secret.scrollIndicatorInsets = secret.contentInset
    
    let selectedRange = secret.selectedRange
    secret.scrollRangeToVisible(selectedRange)
    
  }
  
  func unlockSecretMessage() {
    
    secret.isHidden = false
    title = "Secret stuff"
    
    if let text = KeychainWrapper.standardKeychainAccess().string(forKey: "SecretMessage") {
      
      secret.text = text
      
    }
  }
    
    func saveSecretMessage() {
      
      if !secret.isHidden {
        
        _ = KeychainWrapper.standardKeychainAccess().setString(secret.text, forKey: "SecretMessage")
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing to see here"

      }
    }
    
    
  @IBAction func authenticateTapped(_ sender: Any) {
    
    let context = LAContext()
    var error: NSError?
    
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
      let reason = "Identify yourself!"
      
      context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
        [unowned self] (success, authenticationError) in
        
        DispatchQueue.main.async {
          
          if success {
            self.unlockSecretMessage()
            
          } else {
            
            let ac = UIAlertController(title: "Authentication failed", message: "Your fingerprint could not be verified", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(ac, animated: true)
          }
        }
      }
    } else {
      // no Touch ID
    }
   }
}

