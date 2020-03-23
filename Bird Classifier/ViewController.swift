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
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var birdImageView: UIImageView!
    
    @IBOutlet weak var birdsTableView: UIImageView!

    @IBOutlet weak var tableView: UITableView!
    
    var birdInfo = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
       // tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.isHidden = true
    }

    //MARK: - Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.descriptionLabel.text = birdInfo
        return cell
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
                var data = firstResult.identifier.lowercased()
                self.navigationItem.title = title
                self.tableView.isHidden = false
                self.requestInfo(birdName: data)
                self.tableView.reloadData()
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
     //MARK: - Fetching Data from Wikipedia
    
    let wikipediaURL = "https://en.wikipedia.org/w/api.php"
    
    func requestInfo(birdName: String) {
           //making Alamofire request
           
           let parameters : [String:String] = [
               "format" : "json",
               "action" : "query",
               "prop" : "extracts",
               "exintro" : "",
               "explaintext" : "",
               "titles" : birdName,
               "indexpageids" : "",
               "redirects" : "1",
               "pithumbsize" : "500"
           ]
           
           AF.request(wikipediaURL, method: .get, parameters: parameters).responseJSON { (response) in
             
               let birdJSON : JSON = JSON(response.value)
               let pageid = birdJSON["query"]["pageids"][0].stringValue
               print(pageid)
               let birdDescription = birdJSON["query"]["pages"][pageid]["extract"].stringValue
            //  print(birdDescription)
              
               //adding label text
            self.birdInfo = birdDescription
            self.tableView.reloadData()
            print(self.birdInfo)
            
           }
       }
    



}

