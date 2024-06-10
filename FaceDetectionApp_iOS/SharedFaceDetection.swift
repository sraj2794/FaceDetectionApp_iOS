//
//  SharedFaceDetection.swift
//  FaceDetectionApp_iOS
//
//  Created by Raj Shekhar on 10/06/24.
//

import Foundation
import Foundation
import MLKitVision
import MLKitFaceDetection
import AVFoundation
import CoreMedia

class SharedFaceDetection {
    static let shared = SharedFaceDetection()
    
    var faceDetector: FaceDetector?
    var options = FaceDetectorOptions()
    
    func setupFaceDetection() {
        self.options.performanceMode = .fast
        self.options.landmarkMode = .all
        self.options.classificationMode = .all
        self.options.minFaceSize = CGFloat(0.1)

        self.faceDetector = FaceDetector.faceDetector(options: self.options)
    }
    
    func predictUsingVision(pixelBuffer: CVPixelBuffer, completion: @escaping (_ face: [Face], _ pickedImage: UIImage) -> Void) {
        let ciimage: CIImage = CIImage(cvImageBuffer: pixelBuffer)
        let ciContext = CIContext()
        guard let cgImage: CGImage = ciContext.createCGImage(ciimage, from: ciimage.extent) else {
            return
        }
        let uiImage: UIImage = UIImage(cgImage: cgImage)
        
        self.detectFace(uiImage) { face, pickedImage in
            completion(face, pickedImage)
        }
    }
    
    func detectFace(_ pickedImage: UIImage, completion: @escaping (_ face: [Face], _ pickedImage: UIImage) -> Void) {
        let visionImage = VisionImage(image: pickedImage)
        self.faceDetector?.process(visionImage) { faces, error in
            guard let faces = faces, !faces.isEmpty, faces.count >= 1, let face = faces.first else {
                return
            }
            completion([face], pickedImage)
        }
    }
}
