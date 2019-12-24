//
//  EditHLViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 6/11/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit

class EditHLViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let imageViewContainer: UIView = UIView()
    var imageURL: String?
    var content: String?
    
    var type: String! = "high"
    var highlowid: String?
    var date: String?
    
    var textViewHasBeenEdited: Bool = false
    
    weak var delegate: EditHLDelegate?
    
    var headerImage: UIImage = UIImage(named: "add_image")!
    var didChangeImage: Bool = false
    
    var imageView: UIImageView = UIImageView()
    
    var scrollView: UIScrollView = UIScrollView()
    
    var textView: UITextView = UITextView()
    
    let imagePicker: UIImagePickerController = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        //Filler view, to protect content on devices such as iPhone X with a notch
        let fillerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0))
        
        self.view.backgroundColor = .white
        self.view.addSubview(fillerView)
        
        //fillerView constraints
        fillerView.eqLeading(self.view).eqTrailing(self.view).eqTop(self.view).bottomToTop(self.view.safeAreaLayoutGuide)
        
        fillerView.backgroundColor = AppColors.primary
        
        
        
        //Controls
        let controls = UIView()
        
        controls.backgroundColor = AppColors.primary
        
        let controlsStack = UIStackView()
        
        controls.addSubview(controlsStack)
        
        controlsStack.centerX(controls).centerY(controls).eqWidth(controls).eqHeight(controls)
        
        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        
        let doneButton = UIButton()
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        
        
        
        controlsStack.axis = .horizontal
        controlsStack.distribution = .fillEqually
        controlsStack.addArrangedSubview(cancelButton)
        controlsStack.addArrangedSubview(doneButton)
        
        self.view.addSubview(controls)
        
        controls.eqLeading(self.view).eqTrailing(self.view)
                .eqTop(self.view.safeAreaLayoutGuide).eqWidth(self.view).height(50)
        
        //Add scrollView
        self.view.addSubview(scrollView)
        
        //scrollView constraints
        scrollView.eqLeading(self.view.safeAreaLayoutGuide).eqTrailing(self.view.safeAreaLayoutGuide)
                  .topToBottom(controls).eqBottom(self.view.safeAreaLayoutGuide)
        
        scrollView.isScrollEnabled = true
        
        //imageViewContainer
        imageViewContainer.backgroundColor = rgb(230, 230, 230)
        
        let imageViewContainerTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImg))
        imageViewContainer.addGestureRecognizer(imageViewContainerTapGestureRecognizer)
        
        
        //Add imageViewContainer
        scrollView.addSubview(imageViewContainer)
        
        //imageViewContainer constraints
        imageViewContainer.eqTop(scrollView).centerX(scrollView).eqWidth(scrollView).height(250)
                
        //Add imageView
        imageViewContainer.addSubview(imageView)
        
        //imageView constraints
        imageView.centerX(imageViewContainer).centerY(imageViewContainer)
        imageView.widthAnchor.constraint(lessThanOrEqualTo: imageViewContainer.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(lessThanOrEqualTo: imageViewContainer.heightAnchor).isActive = true
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        //Add spacer between image and textview
        let spacer = UIView()
        spacer.backgroundColor = AppColors.primary
        
        scrollView.addSubview(spacer)
        
        spacer.centerX(scrollView).eqWidth(scrollView).topToBottom(imageViewContainer).height(10)
        
        //Add textView
        scrollView.addSubview(textView)
        
        //textView constraints
        textView.centerX(scrollView).eqWidth(scrollView, -40).topToBottom(spacer)
        textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 350).isActive = true
        
        //textView setup
        textView.text = content ?? "Enter Text"
        if content == "" {
            textView.text = "Enter Text"
        }
        
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 20)
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image"]

        textView.isScrollEnabled = false
        
        
        if imageURL != nil || imageURL == "" {
            let loader = HLLoaderView()
            
            self.view.addSubview(loader)
                    
            loader.eqLeading(self.view).eqTrailing(self.view).eqTop(self.view).eqBottom(self.view)
            
            loader.startLoading()
            
            
            ImageCache.getImage(imageURL!, onSuccess: { (image) in
                loader.stopLoading()
                loader.removeFromSuperview()
                
                self.headerImage = image
                self.updateHeaderImage()
                
                
            }, onError: {
                
            })
            
        } else {
            initialHeaderUpdate()
        }
        
    }
    
    func updateHeaderImage() {
        
        didChangeImage = true
        imageView.image = headerImage
        
    }
    
    func initialHeaderUpdate() {
        imageView.image = headerImage
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func cancel() {
        self.dismiss(animated: true)
    }
    
    @objc func done() {
        
        //First, we need to present a loader so the user knows it worked.
        let loader = HLLoaderView()
        
        self.view.addSubview(loader)
        
        loader.eqLeading(self.view).eqTrailing(self.view).eqTop(self.view).eqBottom(self.view)
        
        loader.startLoading()
        
        //Now we make the request to update the High/Low
        
        var parameters: [String: Any] = [:]
        
        if textViewHasBeenEdited {
            parameters[type] = textView.text!
        }
        
        //Optionally add highlowid
        if highlowid != nil && highlowid != "" {
            parameters["highlowid"] = highlowid
        }
        if date != nil {
            parameters["date"] = date
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let todayAsDateStr = dateFormatter.string(from: Date())
            parameters["date"] = todayAsDateStr
        }
        
        
        //Optionally add image
        var file: UIImage? = nil
        if didChangeImage {
            file = headerImage
        }
        
        authenticatedRequest(url: "https://api.gethighlow.com/highlow/set/" + type, method: .post, parameters: parameters, file: file, onFinish: { json in
            
            loader.stopLoading()
            
            self.delegate?.didFinishEditingHL(data: json)
            
            self.dismiss(animated: true)
            
        }, onError: {error in
            
            loader.stopLoading()
            
        })
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func getScrollViewContentHeight() -> CGFloat {
        
        var height: CGFloat = 0;
        
        for i in scrollView.subviews {
            height += i.frame.height
        }
        
        return height;
    }
    
    
    
    
    @objc func chooseImg() {
        
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
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
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) && !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.title = "Unable to access photos or camera"
            alert.message = "Make sure your camera is not in use, and that you have photos in your library"
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        } else {
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
        }
        
        
        alert.popoverPresentationController?.sourceView = imageViewContainer
        self.present(alert, animated: true, completion: nil)
        
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
            headerImage = img as! UIImage
            updateHeaderImage()
        }
        
        picker.dismiss(animated: true)
        
    }
    

    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    
    
    //Textview delegate functions
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if !textViewHasBeenEdited && content == "" {
            textView.text = ""
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        scrollView.contentOffset.y = textView.intrinsicContentSize.height
        textViewHasBeenEdited = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        
        scrollView.contentOffset.y = textView.intrinsicContentSize.height
        
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        
    }
 
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: 375.0, height: getScrollViewContentHeight())
    }
    
    
    
}


protocol EditHLDelegate: AnyObject {
    func didFinishEditingHL(data: NSDictionary)
}
