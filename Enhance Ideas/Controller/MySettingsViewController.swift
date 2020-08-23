//
//  MySettingsViewController.swift
//  Enhance Ideas
//
//  Created by Cedric on 21/08/2020.
//  Copyright © 2020 Cedric. All rights reserved.
//

import UIKit
import GoogleSignIn

class MySettingsViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchProfilePic()
        profilePictureImageView.addViewBorder(borderColor: #colorLiteral(red: 0.7943204045, green: 0.6480303407, blue: 0.4752466083, alpha: 1), borderWith: 1.0, borderCornerRadius: 125)
        logoutButton.setThemeImage(darkThemeImg: "logoutIconDarkMode", lightThemeImg: "logoutIconLightMode")
    }

    @IBAction func didPressLogoutButton() {
        GIDSignIn.sharedInstance()?.signOut()
    }

    @IBAction func didPressProfilePicture(_ sender: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
// swiftlint:disable force_cast
    internal func imagePickerController(_ picker: UIImagePickerController,
                                        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if info[UIImagePickerController.InfoKey.originalImage] != nil {
                let photo = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
                dismiss(animated: true, completion: nil)
                profilePictureImageView.image = photo
                FirestoreManagement.shared.uploadProfilePicture(image: profilePictureImageView.image!)
            } else {
                profilePictureImageView.image = UIImage(named: "profilePictureError")
            }
    }

    private func fetchProfilePic() {
        FirestoreManagement.shared.downloadProfilePicture(
            uIImageView: profilePictureImageView, userEmail: FirestoreManagement.shared.userEmail)
    }

    @objc private func profilePictureUploadError() {
        profilePictureImageView.image = UIImage(named: "profilePictureError")
    }
}
