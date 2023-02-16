//
//  ViewModel.swift
//  TestAuth
//
//  Created by franklin gaspar on 15/02/23.
//

import UIKit
import FBSDKCoreKit
import FirebaseCore
import FacebookLogin
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

enum  ResultTypes {
    case error(NSError)
    case success(String)
}

class ViewModel {
    let dataBase = Database.database().reference()

    func singInGoogle(vc: UIViewController, completion: @escaping (ResultTypes) -> Void) {
        // MARK: - Google
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: vc, hint: config.clientID) { (user, error) in
            
            if let error = error {
                completion(.error(error as NSError))
              return
            }
            
            guard
                let authentication = user?.user,
                let idToken = authentication.idToken,
                let userId = authentication.userID

             else {
               return
             }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: authentication.accessToken.tokenString)

            FirebaseAuth.Auth.auth().signIn(with: credential, completion: {authResult , error in
                guard authResult != nil, error == nil else {
                print("failed to log in with google credencial")
                    completion(.error(error as! NSError))
                return
                }
                print("Successfully signed in with Google credendital")
                completion(.success((authResult?.additionalUserInfo!.providerID)!))
            })
        }
    }
    
    func singInFaceBook(tokenString: String, completion: @escaping (ResultTypes) -> Void) {
        guard let token = tokenString as? String else {
            print("CTOken")
            #warning("alertView")
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
                completion(.error(error as! NSError))
                return
            }
            print(result)
            guard let username = result["name"] as? String,
                  let email = result["email"] as? String else {
                #warning("alertView")
                return
            }

            self.dataBase.child(username).setValue(email)
            
            let credential  = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { (autResult, error) in

                guard autResult != nil, error == nil else {
                    if  let error = error {
                    print("Facebook credential loggin failed, MFA may be needed \(error)")
                        completion(.error(error as NSError))
                        
                    }
                    return
            }
                print("Successefully logged user in")
                completion(.success("Successefully logged user in"))
            }
        })

    }
}
