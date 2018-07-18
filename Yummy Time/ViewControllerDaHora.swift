//
//  ViewController.swift
//  ObjectDetectionCamera
//
//  Created by AppWebStudios on 15/12/17.
//  Copyright © 2017 AppWebStudios. All rights reserved.
//

import UIKit
import AVKit
import Vision


class ViewControllerDaHora: UIViewController{
    
    
   
   

    @IBOutlet weak var personagem: UIImageView!
    var brocImages:[UIImage] = []
    
    //Declaring capture session
    let captureSession = AVCaptureSession()
    
    
    @IBOutlet weak var cameraView: UIView!
    
    
    @IBOutlet weak var descLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Camera starting function
        self.startingTheCam()
        
        
      
//        personagem.frame = CGRect(x: 200, y: 150, width: 300, height: 300)
        brocImages = createImageArray(total: 95, imagePrefix: "Screenshot")
        animate(imageView: personagem, images: brocImages, positionX: 200,positionY: 150,width: 300,height:300)
    }
    func createImageArray(total:Int,imagePrefix:String)->[UIImage]{
        
        var imageArray:[UIImage] = []
        
        for imageCount in 1...total {
            let imageName = "\(imagePrefix)\(imageCount).png"
            let image = UIImage(named: imageName)
            imageArray.append(image!)
        }
        
        
        return imageArray
    }//end createImageArray
    

    
    func animate(imageView:UIImageView, images:[UIImage],positionX:Double,positionY:Double,width:Double,height:Double){
        imageView.frame = CGRect(x: 200, y: 150, width: 300, height: 300)
        imageView.animationImages = images
        imageView.layer.zPosition = 10
        imageView.animationDuration = 1.0
        imageView.startAnimating()
        
    }//end animate
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Starting the camera
    func startingTheCam(){
        
        //Set session preset
        captureSession.sessionPreset = .photo
        
        //Capturing Device
        guard let capturingDevice = AVCaptureDevice.default(for: .video) else { return }
        
        //Capture Input
        guard let capturingInput = try? AVCaptureDeviceInput(device: capturingDevice) else { return }
        
        //Adding input to capture session
        captureSession.addInput(capturingInput)
        
        //Data output
        let cameraDataOutput = AVCaptureVideoDataOutput()
        cameraDataOutput.setSampleBufferDelegate(self as! AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue(label: "outputVideo"))
        captureSession.addOutput(cameraDataOutput)
        
        //Construct a camera preview layer
        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        //Set the frame
        cameraPreviewLayer.frame = cameraView.bounds
        
        //Add this preview layer to sublayer of view
        cameraView.layer.addSublayer(cameraPreviewLayer)
        
        //Start the session
        captureSession.startRunning()
        
        
    }
    


}


extension ViewControllerDaHora: AVCaptureVideoDataOutputSampleBufferDelegate{

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {


        //Get pixel buffer
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return

        }

        //get model
        guard let resNetModel = try? VNCoreMLModel(for: ImageClassifier().model) else { return }

        //Create a coreml request
        let requestCoreML = VNCoreMLRequest(model: resNetModel) { (vnReq, err) in

            //handling error and request

            DispatchQueue.main.async {
                if err == nil{



                    guard let capturedRes = vnReq.results as? [VNClassificationObservation] else { return }

                    guard let firstObserved = capturedRes.first else { return }

                    print(firstObserved.identifier, firstObserved.confidence)

                    self.descLabel.text = String(format: "This may be %.2f%% %@", firstObserved.confidence, firstObserved.identifier)

                }

            }

        }


        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([requestCoreML])

    }

}
