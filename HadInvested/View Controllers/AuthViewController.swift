//
//  AuthViewController.swift
//  HadInvested
//
//  Created by Conner on 10/29/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class AuthViewController: UIViewController, GIDSignInUIDelegate {
    @IBOutlet var googleLoginButton: GIDSignInButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
}
