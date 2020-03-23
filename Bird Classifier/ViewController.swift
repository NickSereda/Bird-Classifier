//
//  ViewController.swift
//  Bird Classifier
//
//  Created by Mykola Sereda on 23.03.2020.
//  Copyright © 2020 Mykola Sereda. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var birdImageView: UIImageView!
    
    @IBOutlet weak var birdsTableView: UIImageView!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
    }

    @IBAction func cameraButtonClicked(_ sender: Any) {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.sourceType = .photoLibrary
    self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         if let chosenImage = info[.originalImage] as? UIImage {
               
               birdImageView.image = chosenImage
                   
                   guard let ciimage = CIImage(image: chosenImage) else {
                       print("error")
                       return
                   }
               detect(image: ciimage)
               
               self.dismiss(animated: true, completion: nil)
           }
    }
    
     //MARK: - ML Method
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: BirdImageClassifier_1().model) else {
            fatalError("Loading CoreML Model Failed")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
      //  print(request.results)
            if let firstResult = results.first {
                var title = firstResult.identifier.uppercased()
                self.navigationItem.title = title
                self.tableView.isHidden = false
//                var titleString = firstResult.identifier.lowercased()
//                var a = ""
//                var b = ""
//                if let first = titleString.components(separatedBy: " ").first {
//                    a = first
//                }
//                if let last = titleString.components(separatedBy: " ").last {
//                    b = last
//                }
//
              //  self.wikiManager.fetchDataFromWiki(flower: "\(a)%20\(b)")
                    
                } else {
                    self.navigationItem.title = "Unknown bird"
                }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        }
        catch {
            print("error")
        }
    }
    
    //MARK: - Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.descriptionLabel.text = "This is a bird"
        return cell
    }
    


}

