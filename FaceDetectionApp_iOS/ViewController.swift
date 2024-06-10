//
//  ViewController.swift
//  FaceDetectionApp_iOS
//
//  Created by Raj Shekhar on 10/06/24.
//

import UIKit
import MLKitFaceDetection
import MLKitVision
import PhotosUI

class ViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var changeImageButton: UIButton!
    
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.requestAuthorization { status in
            // Handle authorization status
        }
        
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        
        activityIndicator.hidesWhenStopped = true
        
        setupUI()
        SharedFaceDetection.shared.setupFaceDetection()
    }
    
    private func setupUI() {
        // Set placeholder image
        imageView.image = UIImage(named: "placeholder")
        imageView.contentMode = .scaleAspectFit
        
        // Add border and corner radius to imageView
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 2
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        
        // Style change image button
        changeImageButton.layer.cornerRadius = 10
        changeImageButton.layer.borderWidth = 2
        changeImageButton.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    @IBAction private func changeImageTapped(_ sender: UIButton) {
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    private func detectFaces(in image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let visionImage = VisionImage(image: image)
        let options = FaceDetectorOptions()
        options.performanceMode = .accurate
        options.landmarkMode = .all
        options.classificationMode = .all
        let faceDetector = FaceDetector.faceDetector(options: options)
        
        activityIndicator.startAnimating()
        faceDetector.process(visionImage) { faces, error in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                if let error = error {
                    print("Face detection failed with error: \(error.localizedDescription)")
                    return
                }
                
                guard let faces = faces, !faces.isEmpty else {
                    print("No faces detected")
                    return
                }
                
                self.highlightFaces(for: faces, in: image)
            }
        }
    }
    
    private func highlightFaces(for faces: [Face], in image: UIImage) {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        image.draw(in: CGRect(origin: .zero, size: image.size))
        
        context?.setStrokeColor(UIColor.red.cgColor)
        context?.setLineWidth(6.0) // Increase the line width to make the square thicker
        
        for face in faces {
            let boundingBox = face.frame
            context?.stroke(boundingBox)
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        imageView.image = newImage
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let chosenImage = info[.originalImage] as? UIImage {
            imageView.image = chosenImage
            picker.dismiss(animated: true, completion: nil)
            detectFaces(in: chosenImage)
        }
    }
}
