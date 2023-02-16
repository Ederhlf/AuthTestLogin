//
//  ViewController.swift
//  TestAuth
//
//  Created by franklin gaspar on 10/02/23.
//

import UIKit
import FBSDKCoreKit
import FirebaseCore
import FacebookLogin
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class ViewController: UIViewController {
    let dataBase1 = Database.database().reference()
    var myViewModel: ViewModel?
    
    override func loadView() {
        super.loadView()
        myViewModel = ViewModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        
        let loginButton = FBLoginButton()
        loginButton.center = view.center
        view.addSubview(loginButton)
        loginButton.delegate = self
        loginButton.permissions = ["public_profile", "email"]
       
        
        let googleLoginBtn = GIDSignInButton()
        googleLoginBtn.frame = CGRect(x: loginButton.frame.origin.x, y: view.center.y - 100, width: loginButton.frame.width, height: 25)
         view.addSubview(googleLoginBtn)
        googleLoginBtn.addTarget(self, action: #selector(handleSignInWithGoogle), for: .touchUpInside)

    }
}

extension ViewController {
  @objc fileprivate func handleSignInWithGoogle() {
    myViewModel?.singInGoogle(vc: self) { result in
        switch result {
        
        case .error(let error):
            print(error)
       
        case .success(let success):
            let vc = SecondViewController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
     }
   }
}

//// MARK: FaceBookBtn
//extension ViewController {
//    func configureLayoutLoginFaceBookbtn() {
//        configureLoginFaceBookbtnSpecs()
//        configureLoginFaceBookbtnConstraints()
//    }
//    
//    // MARK: Specs
//    func configureLoginFaceBookbtnSpecs() {
//        view.addSubview(loginButton)
//    }
//    
//    // MARK: Cosntraints
//    func configureLoginFaceBookbtnConstraints() {
//        loginButton.anchor(
//            top: topAnchor,
//            paddingTop: UIScreen.main.bounds.height / 1/1.7 ,
//            bottom: nil,
//            paddingBottom: 0,
//            left: leftAnchor,
//            paddingLeft: 30,
//            right: rightAnchor,
//            paddingRight: 30,
//            width: 0,
//            height: 28,
//            centerVertical: false,
//            centerHorizontal: false,
//            view: self
//        )
//    }
//}

// MARK:  - Facebook
extension ViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("CTOken")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(
            graphPath: "me",
            parameters: ["fields" : "email, name"],
            tokenString: token,
            version: nil,
            httpMethod: .get
        )
        
        facebookRequest.start(completionHandler: { _, result, error in
            guard let result = result as? [String: Any], error == nil else {
             print("Failed to make Facebook graphic request")
                return
            }
            print(result)
            guard let username = result["name"] as? String,
                  let email = result["email"] as? String else {
                print("Failed to get email and name from fb result")
                return
            }

            self.dataBase1.child(username).setValue(email)
            
            let credential  = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { (autResult, error) in

                guard autResult != nil, error == nil else {
                    if  let error = error {
                    print("Facebook credential loggin failed, MFA may be needed \(error)")
                }
                    return
            }
                print("Successefully logged user in")
                let vc = SecondViewController()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        })
    }
}
