//
//  SecondViewModel.swift
//  TestAuth
//
//  Created by franklin gaspar on 16/02/23.
//

import Foundation
import UIKit
import FirebaseAuth
import FacebookLogin
import GoogleSignIn
import FBSDKLoginKit

class SecondViewModel {
    
    func logOut(vc: UIViewController) {
        // Log Out
        FBSDKLoginKit.LoginManager().logOut()
        // Google Log Out
        GIDSignIn.sharedInstance.signOut()
        
        do {
            try FirebaseAuth.Auth.auth().signOut()
            
            let loginVc = ViewController()
            loginVc.modalPresentationStyle = .fullScreen
            vc.present(loginVc, animated: true, completion: nil)
        } catch {
            print("Failed to log Out")
        }
    }
}
