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
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    
    // MARK: - Properties
    
    let photoFileOutput = AVCapturePhotoOutput()
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    
    var activeInput: AVCaptureDeviceInput!
    var outputUrl: URL!
    var currentCameraDevice: AVCaptureDevice!
    var thumbnailImage: UIImage?
    
    var recordedClips = [VideoClips]()
    var isRecording = false
    var videoDurationOfLastClip = 0
    var recordingTimer: Timer?
    
    var currentMaxRecordingDuration: Int = 15 {
        didSet {
            timeCounterLabel.text = "\(currentMaxRecordingDuration)s"
        }
    }
    
    var total_RecordedTime_In_Secs = 0
    var total_RecordedTime_In_Minutes = 0
    
    lazy var segmentedProgressView = SegmentedProgressView(width: view.frame.width - 18)
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        self.tabBarController?.tabBar.isHidden = false
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
    
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
        saveButton.layer.cornerRadius = 12
        saveButton.backgroundColor = UIColor(red: 254/255, green: 44/255, blue: 85/255, alpha: 1.0)
        saveButton.alpha = 0
        discardButton.alpha = 0
        
        view.addSubview(segmentedProgressView)
        segmentedProgressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        segmentedProgressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        segmentedProgressView.widthAnchor.constraint(equalToConstant: view.frame.width - 18).isActive = true
        segmentedProgressView.heightAnchor.constraint(equalToConstant: 6).isActive = true
        segmentedProgressView.translatesAutoresizingMaskIntoConstraints = false
        
        [captureButton, captureButtonRingView, cancelButton, flipCameraButton, speedButton, beautyButton, filterButton, timerButton, galleryButton, effectsButton, soundsView, timeCounterLabel, saveButton, discardButton].forEach { subview in
            subview?.layer.zPosition = 1
        }
    }
    
    func setupCaptureSession() -> Bool {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        if let captureVideoDevice = AVCaptureDevice.default(for: AVMediaType.video), let captureAudioDevice = AVCaptureDevice.default(for: AVMediaType.audio) {
            do {
                let inputVideo = try AVCaptureDeviceInput(device: captureVideoDevice)
                let inputAudio = try AVCaptureDeviceInput(device: captureAudioDevice)
                currentCameraDevice = captureVideoDevice
                
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
        handleDidTapRecord()
    }
    
    @IBAction func discardButtonDidTapped(_ sender: Any) {
        let alertCV = UIAlertController(title: "Discard the last clip?", message: nil, preferredStyle: .alert)
        
        let discardAction = UIAlertAction(title: "Discard", style: .default) { _ in
            self.handleDiscardLastRecordedClip()
        }
        
        let keppAction = UIAlertAction(title: "Keep", style: .cancel) { _ in
            
        }
        
        alertCV.addAction(discardAction)
        alertCV.addAction(keppAction)
        present(alertCV, animated: true)
    }
    
    @IBAction func saveButtonDidTapped(_ sender: Any) {
        let previewCV = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "PreviewCaptureViewController") { coder -> PreviewCaptureViewController? in
            PreviewCaptureViewController(coder: coder, recordingClips: self.recordedClips)
        }
        
        previewCV.viewWillDenitRestartVideoSession = { [weak self] in
            guard let self = self else { return }
            
            if self.setupCaptureSession() {
                DispatchQueue.global(qos: .background).async {
                    self.captureSession.startRunning()
                }
            }
        }
        
        navigationController?.pushViewController(previewCV, animated: true)
    }
    
}

// MARK: - Helpers Discard

extension CreatePostViewController {
    func handleDiscardLastRecordedClip() {
        outputUrl = nil
        thumbnailImage = nil
        recordedClips.removeLast()
        handleResetAllVisibilityToIdentity()
        handleSetNewOutputURLAndThumbailImage()
        segmentedProgressView.handleRemoveLastSegment()
        
        if recordedClips.isEmpty == true {
            handleResetTimersAndProgressViewToZero()
        } else if recordedClips.isEmpty == false {
            handleCalculateDurationLeft()
        }
    }
    
    func handleSetNewOutputURLAndThumbailImage() {
        outputUrl = recordedClips.last?.videoUrl
        let currentUrl: URL? = outputUrl
        
        guard let currentUrlUnwrapped = currentUrl else { return }
        guard let generateThumbailImage = generateVideoThumbnail(withfile: currentUrlUnwrapped) else { return }
        
        if currentCameraDevice.position == .front {
            thumbnailImage = didTakePicture(generateThumbailImage, to: .upMirrored)
        } else {
            thumbnailImage = generateThumbailImage
        }
    }
    
    func handleCalculateDurationLeft() {
        let timeToDiscard = videoDurationOfLastClip
        let currentCombineTime = total_RecordedTime_In_Secs
        let newVideoDuration = currentCombineTime - timeToDiscard
        
        total_RecordedTime_In_Secs = newVideoDuration
        let countDownSec: Int = Int(currentMaxRecordingDuration) - total_RecordedTime_In_Secs / 10
        timeCounterLabel.text = "\(countDownSec)"
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
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        let newRecordedClip = VideoClips(videoUrl: fileURL, cameraPosition: currentCameraDevice.position)
        recordedClips.append(newRecordedClip)
        startTime()
        print("DEBUG: Recording clips \(recordedClips.count)")
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
    
    func handleDidTapRecord() {
        if movieOutput.isRecording == false {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    func startRecording() {
        if movieOutput.isRecording == false {
            guard let connection = movieOutput.connection(with: .video) else { return }
            
            if connection.isVideoOrientationSupported {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
                let device = activeInput.device
                
                if device.isSmoothAutoFocusSupported {
                    do {
                        try device.lockForConfiguration()
                        device.isSmoothAutoFocusEnabled = false
                        device.unlockForConfiguration()
                    } catch {
                        print("DEBUG: Error setting configuration \(error.localizedDescription)")
                    }
                }
                
                outputUrl = tempUrl()
                movieOutput.startRecording(to: outputUrl, recordingDelegate: self)
                handleAnimateRecording()
            }
        }
    }
    
    func tempUrl() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    func stopRecording() {
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
            handleAnimateRecording()
            stopTimer()
            segmentedProgressView.pauseProgress()
        }
    }
    
    func handleAnimateRecording() {
       UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseIn) { [weak self] in
            guard let self = self else  { return }
            
            if self.isRecording == false {
                self.captureButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                self.captureButton.layer.cornerRadius = 5
                self.captureButtonRingView.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
                
                self.saveButton.alpha = 0
                self.discardButton.alpha = 0
                
                [self.galleryButton, self.effectsButton, self.soundsView].forEach { subview in
                    subview?.isHidden = true
                }
                
//                [self.flipCameraButton, self.speedButton, self.beautyButton, self.filterButton, self.timerButton, self.galleryButton, self.effectsButton, self.soundsView].forEach { subview in
//                    subview?.isHidden = true
//                }
            } else {
                self.captureButton.transform = CGAffineTransform.identity
                self.captureButton.layer.cornerRadius = 68/2
                self.captureButtonRingView.transform = CGAffineTransform.identity
                
                self.handleResetAllVisibilityToIdentity()
            }
        } completion: { [weak self] onComplete in
            guard let self = self else  { return }
            self.isRecording = !self.isRecording
        }

    }
    
    func handleResetAllVisibilityToIdentity() {
        if recordedClips.isEmpty == true {
            self.saveButton.alpha = 0
            self.discardButton.alpha = 0
            
            [self.galleryButton, self.effectsButton, self.soundsView].forEach { subview in
                subview?.isHidden = false
            }
        } else {
            self.saveButton.alpha = 1
            self.discardButton.alpha = 1
            
            [self.galleryButton, self.effectsButton, self.soundsView].forEach { subview in
                subview?.isHidden = true
            }
        }
    
    }
    
}

// MARK: - Recording Timer

extension CreatePostViewController {
    
    func startTime() {
        videoDurationOfLastClip = 0
        stopTimer()
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] _ in
            self?.timerTick()
        })
    }
    
    func timerTick() {
        total_RecordedTime_In_Secs += 1
        videoDurationOfLastClip += 1
        
        let time_limit = currentMaxRecordingDuration * 10
        
        if total_RecordedTime_In_Secs == time_limit {
            handleDidTapRecord()
        }
        
        let startTime = 0
        let trimmedTime: Int = Int(currentMaxRecordingDuration) - startTime
        let positiveOrZero = max(total_RecordedTime_In_Secs, 0)
        let progress = Float(positiveOrZero) / Float(trimmedTime) / 10
        segmentedProgressView.setProgress(CGFloat(progress))
        
        let countDownSec: Int = Int(currentMaxRecordingDuration) - total_RecordedTime_In_Secs / 10
        timeCounterLabel.text = "\(countDownSec)"
    }
    
    func stopTimer() {
        recordingTimer?.invalidate()
    }
    
    func handleResetTimersAndProgressViewToZero() {
        total_RecordedTime_In_Secs = 0
        total_RecordedTime_In_Minutes = 0
        videoDurationOfLastClip = 0
        stopTimer()
        segmentedProgressView.setProgress(0)
        timeCounterLabel.text = "\(currentMaxRecordingDuration)"
    }
    
}
