import UIKit
import AVFoundation
import Foundation

class ViewController: UIViewController, CameraHandler {
    var previewView : UIView!;
    var boxView:UIView!;
    
    var session:AVCaptureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var videoDataOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    var videoDataOutputQueue : dispatch_queue_t?
    var previewLayer:AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer()
    var currentFrame:CIImage = CIImage()
    var cameraPreviewView:UIView!
    var isCameraRunning:Bool = false
    var isSetupCompleted: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cameraPreviewView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height));
        self.cameraPreviewView.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(cameraPreviewView);
        
        //Add a box view
        self.boxView = UIView(frame: CGRectMake(0, 0, 100, 200));
        self.boxView.backgroundColor = UIColor.greenColor();
        self.boxView.alpha = 0.3;
        
        self.view.addSubview(self.boxView);
        
        self.setupAVCapture();
    }
    
    override func viewWillAppear(animated: Bool) {
        if !isCameraRunning {
            startRunning();
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func shouldAutorotate() -> Bool {
        if (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.Unknown) {
            return false;
        }
        else {
            return true;
        }
    }
}

