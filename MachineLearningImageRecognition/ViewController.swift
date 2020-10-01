//
//  ViewController.swift
//  MachineLearningImageRecognition
//
//  Created by Ali Atakan AKMAN on 11.08.2020.
//  Copyright © 2020 Ali Atakan AKMAN. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var resultsLabel: UILabel!
    
    var choosenImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        resultsLabel.text = "Select Image Please"
    }

    @IBAction func changeClicked(_ sender: Any) {

        //Resim seçme
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    //Resmi bir kere seçtikten sonra ne yapıcağını yazıyoruz bu fonksiyon altında
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!){
            
            choosenImage = ciImage
            
        }
        
        recognizeImage(image: choosenImage)
        
    }
    
    func recognizeImage(image : CIImage){
        
        //1- Request
        //2- Handler oluşturmak
        
        resultsLabel.text = "Finding..."
        
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            
            let request = VNCoreMLRequest(model: model) { (vnrequest, error) in
                
                if let results = vnrequest.results as? [VNClassificationObservation] { //Sınıflandırmanın ilk sonucunu almak için.
                  
                    if results.count > 0 {
                        
                        let topResult = results.first
                        
                        DispatchQueue.main.async {
                            
                            let confidanceLevel = (topResult?.confidence ?? 0) * 100
                            
                            let rounded = Int(confidanceLevel * 100) / 100
                            
                            self.resultsLabel.text = "\(rounded) % it's \(topResult!.identifier)"
                        
                        }
                        
                    }            
                }
            }
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do{
                    try handler.perform([request])
                }catch{
                    print("Error")
                }
            }
        }
    }
}

