//
//  profilePictureViewDownloader.swift
//  Enhance Ideas
//
//  Created by Cedric on 27/08/2020.
//  Copyright © 2020 Cedric. All rights reserved.
//

import Foundation
import FirebaseUI
import Firebase

class ProfilePictureViewDownloader {
    public func downloadProfilePicture(uIImageView: UIImageView, userEmail: String) {
       let imageName = "\(userEmail)ProfilePicture.jpeg"
        let storageRef = FirestoreManagement.shared.storagePath.child(imageName)
       // UIImageView in your ViewController
       let imageView: UIImageView = uIImageView
       // Placeholder image
       let placeholderImage = UIImage(named: "placeholder.jpg")
       // Load the image using SDWebImage
       imageView.sd_setImage(with: storageRef, placeholderImage: placeholderImage)
    }
}
