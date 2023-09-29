//
//  CreatePostViewController.swift
//  TiktokClone
//
//  Created by Jérémy Perez on 28/09/2023.
//

import UIKit
import AVFoundation

class CreatePostViewController: UIViewController {
    
    // MARK: - @IBOutlet
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var captureButtonRingView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var flipCameraButton: UIButton!
    
    @IBOutlet weak var speedButton: UIButton!
    @IBOutlet weak var beautyButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var effectsButton: UIButton!
    
    @IBOutlet weak var timeCounterLabel: UILabel!
    
    @IBOutlet weak var soundsView: UIView!
    
    // MARK: - Properties
    
    let photoFileOutput = AVCapturePhotoOutput()
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    
    var activeInput: AVCaptureDeviceInput!
    var outputUrl: URL!
    var currentCameraDevice: AVCaptureDevice!
    var thumbnailImage: UIImage?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if setupCaptureSession() {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Helpers
    
    func setupView() {
        captureButton.backgroundColor = UIColor(red: 254/255, green: 44/255, blue: 85/255, alpha: 1.0)
        captureButton.layer.cornerRadius = 68/2
        captureButtonRingView.layer.borderColor = UIColor(red: 254/255, green: 44/255, blue: 85/255, alpha: 0.5).cgColor
        captureButtonRingView.layer.borderWidth = 6
        captureButtonRingView.layer.cornerRadius = 85/2
        
        timeCounterLabel.backgroundColor = UIColor.black.withAlphaComponent(0.42)
        timeCounterLabel.layer.cornerRadius = 15
        timeCounterLabel.layer.borderColor = UIColor.white.cgColor
        timeCounterLabel.layer.borderWidth = 1.8
        timeCounterLabel.clipsToBounds = true
        
        soundsView.layer.cornerRadius = 12
        
        [captureButton, captureButtonRingView, cancelButton, flipCameraButton, speedButton, beautyButton, filterButton, timerButton, galleryButton, effectsButton, soundsView, timeCounterLabel].forEach { subview in
            subview?.layer.zPosition = 1
        }
    }
    
    func setupCaptureSession() -> Bool {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        if let captureVideoDevice = AVCaptureDevice.default(for: AVMediaType.video), let captureAudioDevice = AVCaptureDevice.default(for: AVMediaType.audio) {
            do {
                let inputVideo = try AVCaptureDeviceInput(device: captureVideoDevice)
                let inputAudio = try AVCaptureDeviceInput(device: captureAudioDevice)
                
                if captureSession.canAddInput(inputVideo) {
                    captureSession.addInput(inputVideo)
                    activeInput = inputVideo
                }
                
                if captureSession.canAddInput(inputAudio) {
                    captureSession.addInput(inputAudio)
                }
                
                if captureSession.canAddOutput(movieOutput) {
                    captureSession.addOutput(movieOutput)
                }
                
            } catch let error {
                print("DEBUG: Could not setup camera input:", error)
                return false
            }
        }
        
        if captureSession.canAddOutput(photoFileOutput) {
            captureSession.addOutput(photoFileOutput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return true
    }
    
    func getDeviceProsition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
    }
    
    // MARK: - @IBAction
    
    @IBAction func handleDismiss(_ sender: Any) {
        tabBarController?.selectedIndex = 0
    }
    
    @IBAction func flipButtonDidTapped(_ sender: Any) {
        captureSession.beginConfiguration()
        
        guard let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else { return }
        guard let newCameraDevice = currentInput.device.position == .back ? getDeviceProsition(position: .front) : getDeviceProsition(position: .back) else { return }
        
        let newVideoInput = try? AVCaptureDeviceInput(device: newCameraDevice)
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                captureSession.removeInput(input)
            }
        }
        
        if captureSession.inputs.isEmpty {
            if let newVideoInputFinal = newVideoInput {
                captureSession.addInput(newVideoInputFinal)
                activeInput = newVideoInputFinal
            }
        }
        
        if let microphone = AVCaptureDevice.default(for: .audio) {
            do  {
                let microInput = try AVCaptureDeviceInput(device: microphone)
                if captureSession.canAddInput(microInput) {
                    captureSession.addInput(microInput)
                }
            } catch {
                print("DEBUG: Error setting device audio input \(error.localizedDescription)")
            }
        }
        
        captureSession.commitConfiguration()
    }
    
    @IBAction func captureButtonDidTapped(_ sender: Any) {
        
    }
    
}

// MARK: - AVCaptureMovieFileOutput

extension CreatePostViewController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("DEBUG: Error recording movie \(error.localizedDescription)")
        } else {
            guard let urlOfVideorecorded = outputUrl else { return }
            guard let generatedThumbnailImage = generateVideoThumbnail(withfile: urlOfVideorecorded) else { return }
            
            if currentCameraDevice.position == .front {
                thumbnailImage = didTakePicture(generatedThumbnailImage, to: .upMirrored)
            } else {
                thumbnailImage = generatedThumbnailImage
            }
        }
    }
    
    func didTakePicture(_ picture: UIImage, to orientation: UIImage.Orientation) -> UIImage {
        let flippedImage = UIImage(cgImage: picture.cgImage!, scale: picture.scale, orientation: orientation)
        return flippedImage
    }
    
    func generateVideoThumbnail(withfile videoUrl: URL) -> UIImage? {
        let asset = AVAsset(url: videoUrl)
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let cmTime = CMTimeMake(value: 1, timescale: 60)
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: cmTime, actualTime: nil)
            
            return UIImage(cgImage: thumbnailCGImage)
        } catch {
            print(error)
        }
        
        return nil
    }
    
}
