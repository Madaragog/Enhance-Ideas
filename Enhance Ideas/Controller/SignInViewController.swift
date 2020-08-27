//
//  SignInViewController.swift
//  Enhance Ideas
//
//  Created by Cedric on 01/08/2020.
//  Copyright © 2020 Cedric. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

class SignInViewController: UIViewController {
    @IBOutlet weak var googleSignInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        googleSignInButton.setBackgroundImage(UIImage(named: "googleSignInPressed"), for: .highlighted)
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(performSegueIfCurrentUserIsNotEmpty),
                                               name: NSNotification.Name("performSuccessSignInSegue"),
                                               object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        performSegueIfCurrentUserIsNotEmpty()
    }

    @IBAction func signInWithGoogleButton() {
        GIDSignIn.sharedInstance()?.signIn()
    }
// goes back to the log in page after a user disconnected
    @IBAction func unwindToSignInPage(segue: UIStoryboardSegue) { }

    @objc private func performSegueIfCurrentUserIsNotEmpty() {
        if GIDSignIn.sharedInstance()?.currentUser != nil {
            performSegue(withIdentifier: "SuccessSignInSegue", sender: nil)
        }
    }
}
