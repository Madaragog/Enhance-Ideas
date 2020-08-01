//
//  SignInViewController.swift
//  Enhance Ideas
//
//  Created by Cedric on 01/08/2020.
//  Copyright © 2020 Cedric. All rights reserved.
//

import UIKit
import GoogleSignIn

class SignInViewController: UIViewController {
    @IBOutlet weak var signInWithGoogleButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        signInWithGoogleButton.setBackgroundImage(UIImage(named: "googleSignInPressed"), for: .highlighted)
        GIDSignIn.sharedInstance()?.presentingViewController = self

        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
    }

    @IBAction func didPressSignInWithGoogleButton(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.signIn()
    }
}
