//
//  SharePostViewController.swift
//  TiktokClone
//
//  Created by Jérémy Perez on 09/10/2023.
//

import UIKit
import AVFoundation
import ProgressHUD

class SharePostViewController: UIViewController {
    
    // MARK: - @IBOutlet
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var draftsButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    
    // MARK: - Properties
    
    let originalVideoUrl: URL
    var encodedVideoURL: URL?
    
    var selectedPhoto: UIImage?
    let placeholder = "Please write a description"

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        saveVideoTobeUploadedToServerToTempDirectory(sourceURL: originalVideoUrl) { [weak self] outputUrl in
            self?.encodedVideoURL = outputUrl
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    init?(coder: NSCoder, videoUrl: URL) {
        self.originalVideoUrl = videoUrl
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - IBAction
    
    @IBAction func sharePostDidTapped(_ sender: Any) {
        guard let text = textView.text else { return }
        
        ProgressHUD.show("Loading...")
        
        PostService.shared.sharePost(encodedVideoURL: encodedVideoURL, selectedPhoto: selectedPhoto, textView: text) {
            ProgressHUD.dismiss()
            
            self.dismiss(animated: true) {
                self.tabBarController?.selectedIndex = 0
            }
        } onError: { errorMessage in
//            ProgressHUD.dismiss()
            ProgressHUD.showError(errorMessage)
        }

    }
    
    // MARK: - Helpers
    
    func setupView() {
        textView.delegate = self
        textView.text = placeholder
        textView.textColor = .lightGray
        
        draftsButton.layer.cornerRadius = 3
        postButton.layer.cornerRadius = 3
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        if let thumbnailImage = self.thumbnailImageForFileUrl(originalVideoUrl) {
            self.selectedPhoto = thumbnailImage.imageRotated(by: .pi/2)
            self.thumbnailImageView.image = thumbnailImage.imageRotated(by: .pi/2)
        }
    }
    
    func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 7, timescale: 1), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch {
            print("DEBUG: Error \(error.localizedDescription)")
            return nil
        }
    }

}

extension SharePostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = placeholder
            textView.textColor = .lightGray
        }
    }
}
