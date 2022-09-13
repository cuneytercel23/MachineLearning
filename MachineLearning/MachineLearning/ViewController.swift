//
//  ViewController.swift
//  MachineLearning
//
//  Created by Cüneyt Erçel on 14.08.2022.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
   var choosenImage = CIImage()

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
// 1 change butonuna tıklayınca resim koymak istiyoruz.
    @IBAction func changeClickedButton(_ sender: Any) {
        let picker = UIImagePickerController() // bundan ötürü klass kısmına 2 şey daha ekledik.
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    // 1.2 resim seçilince .. (didfinishpick)
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage // bitince seçtiğim orijinal resimi ui immage olarak cast et
        self.dismiss(animated: true, completion: nil) // dissmiss et.
        
        
        // 2.1 CIImage(coreml imagesı) oluşturma
        
        if let ciImage = CIImage(image: imageView.image!) {
            choosenImage = ciImage // chosen imageyi yuakrda oluşturduk başka fonksiyonlara da girebilmek için.
            
        }
        
        recognizeImage(image: choosenImage)
    }
    
    // 2 CoreML Recognize(tanıma) İmage yapma - önce en tepeye coreml ve vision import ediyoruz.
    // fonksiyonun içine önce:
    //1) Request 2) Handler yapıcaz yani istek oluşturup sonra ele alıcaz.
    
    func recognizeImage( image: CIImage) {
        
        // VNcoreml ile model oluşturma
        if let model = try? VNCoreMLModel(for:MobileNetV2().model){ // Böyle yaparak deeplapv3 modelini cast ettik.
            // VNcoreml ile request ıluşturma
            
            let request = VNCoreMLRequest(model: model) { vnrequest, error in
                
                if let results = vnrequest.results as? [VNClassificationObservation] {  // .results dediğim yerde any olarak bir array geliyor ve biz onu görsel analizinin isteğinin sonucunda üretilen bir sınıflandırmaya(VNClassificationObservation) cast ettik.
                    if results.count > 0 { // bu cokomelli diil
                        let topResults = results.first // burda resimleri gördüğümüzde 2-3 tanesi benzer olabiliyor biz o yüzden ilk görüleni cast ediyoruz.
                        
                        // kullanıcya gösterceğimiz şeyleri dispatchqueue içinde yapıcaz daha öncede ypamıştık hatırlamıyorum. ama arka planda sıra beklemeden çözülsün diye yapılan bir şey async.
                        DispatchQueue.main.async {
                            
                            let confidenceLevel = (topResults?.confidence ?? 0) * 100  // confidence demek doğruluk oranını gösteriyor. ama 1 ile 0 arası gösteriyor o yüzden yüzle çarpıyoruz. 0 olan yer default rakam boş bişi yani
                            
                            self.resultLabel.text = " \(confidenceLevel)% it is \(topResults!.identifier)" // burda identifierı kimliğini söylüyor yani maymunsa maymun
                
                        }
                        
                        
                    }
                    
                    
                    
                    
                }
            }
            
            // 3 Handler yapma
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do{
                    try handler.perform([request])
                }catch{
                    print("eror")
                }
                
        }
        
       
        }
        
        
    }
    
    
    
}

