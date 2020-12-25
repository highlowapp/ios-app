//
//  ReflectEditorViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 6/30/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit
import WebKit
import Purchases

class ReflectEditorViewController: UIViewController, WKScriptMessageHandler, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WKNavigationDelegate, ProgressLoaderViewDelegate, SwiftPaywallDelegate {
    func purchaseCompleted(paywall: SwiftPaywall, transaction: SKPaymentTransaction, purchaserInfo: Purchases.PurchaserInfo) {
        updatePremiumStatus()
    }
    
    func purchaseRestored(paywall: SwiftPaywall, purchaserInfo: Purchases.PurchaserInfo?, error: Error?) {
        updatePremiumStatus()
    }
    
    func didSkip() {
        
    }
    
    var currentBlockId: String?
    var type: String = "diary"
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "chooseImage" {
            let body = message.body as! NSDictionary
            currentBlockId = body["blockId"] as? String
            
            let alert = UIAlertController(title: "Choose a method", message: nil, preferredStyle: .actionSheet)
                
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
                    alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                        self.openCamera()
                    }))
                    
                }
                
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    
                    alert.addAction(UIAlertAction(title: "Existing Photo", style: .default, handler: { _ in
                        self.openPhotos()
                    }))
                    
                }
            
                alert.addAction(UIAlertAction(title: "Image URL", style: .default, handler: { _ in
                    
                    self.chooseImageUrl()
                    
                }))
                
                if !UIImagePickerController.isSourceTypeAvailable(.camera) && !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    alert.title = "Unable to access photos or camera"
                    alert.message = "Make sure your camera is not in use, and that you have photos in your library"
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                } else {
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    
                }
                
                
            alert.popoverPresentationController?.sourceView = self.editor
                self.present(alert, animated: true, completion: nil)
        }
        else if message.name == "showPremium" {
            let paywall = SwiftPaywall(termsOfServiceUrlString: "https://gethighlow.com/termsofservice", privacyPolicyUrlString: "https://gethighlow.com/privacy", allowRestore: true, backgroundColor: .white, textColor: AppColors.primary, productSelectedColor: AppColors.primary, productDeselectedColor: AppColors.secondary)
            paywall.titleLabel.text = "Get Full Access"
            paywall.subtitleLabel.text = "With High/Low Premium, you get unlimited diary blocks, unlimited time for audio diaries and meditation sessions, and access to exclusive content! "
            paywall.delegate = self
            self.present(paywall, animated: true)
        }
        else if message.name == "save" {
            self.saveDocument(message.body as! NSDictionary)
        } else if message.name == "hasEdited" {
            self.hasEdited()
        }
    }
    
    let imagePicker: UIImagePickerController = UIImagePickerController()
    var currentUrl: String = ""
    var editor: ReflectEditorView?
    let loaderView: ProgressLoaderView = ProgressLoaderView()
    var isLoading: Bool = false {
        didSet {
            loaderView.isHidden = !isLoading
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationController?.navigationBar.tintColor = AppColors.primary
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "chooseImage")
        userContentController.add(self, name: "showPremium")
        userContentController.add(self, name: "save")
        userContentController.add(self, name: "hasEdited")
        config.userContentController = userContentController
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        
        editor = ReflectEditorView(frame: .zero, configuration: config)
        
        self.view.addSubview(editor!)
        
        
        
        editor!.eqLeading(self.view).eqTrailing(self.view).eqTop(self.view.safeAreaLayoutGuide).eqBottom(self.view)
        editor!.load()
        
        editor?.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        editor?.navigationDelegate = self
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image"]
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        self.view.addSubview(loaderView)
        
        loaderView.eqTop(self.view).eqBottom(self.view).eqLeading(self.view).eqTrailing(self.view)
        loaderView.isHidden = !isLoading
        loaderView.delegate = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func saveDocument(_ blocks: NSDictionary) {
        
    }
    
    func hasEdited() {
        
    }
    
    func darkMode() {
        editor?.evaluateJavaScript("darkMode()")
    }
    
    func lightMode() {
        editor?.evaluateJavaScript("lightMode()")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let progress = editor?.estimatedProgress
            if progress == 1.0 {
                self.configureEditor()
            }
        }
    }
    
    func setBlocks(_ blocks: [NSDictionary]) {
        do {
            let blocksJson = try JSONSerialization.data(withJSONObject: blocks, options: .prettyPrinted)
            let jsonStr = NSString(data: blocksJson, encoding: String.Encoding.utf8.rawValue)! as String
            editor?.evaluateJavaScript("setBlocks(\(jsonStr))")
        } catch {
            
        }
        
    }
    
    func configureEditor() {
        editor!.evaluateJavaScript("setType('\(type)')", completionHandler: nil)
        updatePremiumStatus()
    }
    
    func updatePremiumStatus() {
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            let premium = purchaserInfo?.entitlements["Premium"]
            if premium?.isActive == true {
                self.editor?.evaluateJavaScript("enablePremiumFeatures()", completionHandler: nil)
            }
            if purchaserInfo?.entitlements["Premium"]?.billingIssueDetectedAt != nil {
                alert("Billing Issue Detected", "There has been a billing issue that prevented your subscription from renewing. You will still have access to premium features during a 16-day grace period, but you should probably get that worked out as soon as possible.")
            }
        }
    }

    func openCamera() {
        imagePicker.sourceType = .camera
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func openPhotos() {
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let img = info[.editedImage] {
            //Upload new image, get link, and add it to img block
            uploadImage(img as! UIImage)
        }
        
        picker.dismiss(animated: true)
        
    }
    
    func chooseImageUrl() {
        let alert = UIAlertController(title: "Enter URL", message: "Type or paste in the URL of the image you'd like to display", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.addTarget(self, action: #selector(self.updateLink(_:)), for: .editingChanged)
            textField.placeholder = "https://example.com"
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            self.editor?.evaluateJavaScript("updateBlock('\(self.currentBlockId ?? "")', {'url': '\(self.currentUrl)'})", completionHandler: nil)
        }))
        
        self.present(alert, animated: true)
    }
    
    @objc func updateLink(_ sender: UITextField) {
        currentUrl = sender.text ?? ""
    }
    
    func uploadImage(_ img: UIImage) {
        loaderView.allowsSkip = false
        loaderView.setTitle("Uploading...")
        isLoading = true
        
        ActivityService.shared.addImage(img: img, onSuccess: { url in
            self.isLoading = false
            self.editor?.evaluateJavaScript("updateBlock('\(self.currentBlockId ?? "")', {'url': '\(url)'})", completionHandler: nil)
        }, onError: { error in
        }, onProgressUpdate: { progress in
            self.loaderView.setProgress(Float(progress.fractionCompleted))
        })
    }
    

    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
