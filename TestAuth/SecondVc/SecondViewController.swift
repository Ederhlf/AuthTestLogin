//
//  SecondViewController.swift
//  TestAuth
//
//  Created by franklin gaspar on 12/02/23.
//
import UIKit
import FirebaseAuth
import FacebookLogin
import GoogleSignIn
import FBSDKLoginKit

class SecondViewController: UIViewController {
    let loginOutBtn = UIButton()
    var myViewModel: SecondViewModel?

    override func loadView() {
           super.loadView()
        myViewModel = SecondViewModel()
       }
      
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .link
        loginOutBtn.frame = CGRect(x: UIScreen.main.bounds.width / 4.0, y: view.center.y, width: 200, height:30)
        loginOutBtn.backgroundColor = .white
        loginOutBtn.setTitle("LogOut", for: .normal)
        loginOutBtn.setTitleColor(.link, for: .normal)
         view.addSubview(loginOutBtn)
        loginOutBtn.addTarget(self, action: #selector(handleSignOut), for: .touchUpInside)
    }
    
    @objc func handleSignOut() {
        myViewModel?.logOut(vc: self)
    }
}
