//
//  PhotoPicker.swift
//  Sample
//
//  Created by Admin on 12/02/21.
//  Copyright © 2021 Ankit Kumar. All rights reserved.
//

import UIKit
import MobileCoreServices

/**
  Delegate method to respone for photopicker.
 */
protocol PhotoPickerDelegate: class {
    func photoPicker(didFinishPickingImage: UIImage?)
    func photoPicker(didFinishPickingVideoPath: URL?)
}

enum PPMediaType: Int{
    case none = 0, image, video, link
}



class PhotoPicker: NSObject {
    
    static let shared = PhotoPicker()

    private let imgPickerController = UIImagePickerController()
    private var title: String = ""
    private var message: String = ""
    private weak var delegate: PhotoPickerDelegate!
    private var ppMediaType: PPMediaType!
    private override init() { super.init() }
    
    /**
     Show ImagePicker with various constraints.
     
     - Parameters:
     - title: To set any title or default.
     - message: A message string to show to the user.
     - delegate: Set delete to get media rsponse.
     */
    
    public func open(title: String = "Select Photos",
              message: String = "Pick any option to get picture.",
              delegate: PhotoPickerDelegate,
              mediaType: PPMediaType = .image){
        self.imgPickerController.delegate = self
        self.imgPickerController.allowsEditing = true
        self.title = title
        self.message = message
        self.delegate = delegate
        self.ppMediaType = mediaType
        
        // show picker
        showOptions()
    }
    
    
    //MARK:- Setup Picker option
    private func showOptions(){
        var alertPayLoad = PopUpPayLoad(title: self.title,
                                        message: self.message,
                                        images: nil,
                                        style: .bottom)
        
        let photos = PopUpButton(title: (self.ppMediaType == .video) ? "Gallery" : "Photos", style: .default) {
            self.imgPickerController.sourceType = .photoLibrary
            
            var mediaTypes: [String] = []
            if self.ppMediaType == .video{
                mediaTypes = [kUTTypeMovie as String]
            }else if self.ppMediaType == .image{
                mediaTypes = [kUTTypeImage as String]
            }
            self.imgPickerController.mediaTypes = mediaTypes
            
            if let cc = UIWindow.currentController {
                cc.present(self.imgPickerController, animated: true, completion: nil)
            }
        }
        
        let camera = PopUpButton(title: "Camera", style: .default) {
            self.imgPickerController.sourceType = .camera
            if let cc = UIWindow.currentController {
                cc.present(self.imgPickerController, animated: true, completion: nil)
            }
        }
        
        let cancel = PopUpButton(title: "Cancel", style: .cancel, action: nil)
        
        alertPayLoad.addAction([photos, camera, cancel])
        if self.ppMediaType == .video{
            alertPayLoad.addAction([photos, cancel])
        }
        
        
        if let cc = UIWindow.currentController {
            alertPayLoad.show(cc)
        }
    }
}


extension PhotoPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if let cc = UIWindow.currentController {
            delegate.photoPicker(didFinishPickingImage: nil)
            delegate.photoPicker(didFinishPickingVideoPath: nil)
            cc.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let cc = UIWindow.currentController {
            
            if self.ppMediaType == .video{
                let video = info[.mediaURL] as? URL
                delegate.photoPicker(didFinishPickingVideoPath: video)
            }else if self.ppMediaType == .image{
                let img = info[.editedImage] as? UIImage
                delegate.photoPicker(didFinishPickingImage: img)
            }

            cc.dismiss(animated: true, completion: nil)
        }
    }
}
