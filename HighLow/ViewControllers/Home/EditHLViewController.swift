//
//  EditHLViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 6/11/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit
import PopupDialog
import Aztec
import Gridicons
import Foundation
import MobileCoreServices

class EditHLViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imageViewContainer: UIView = UIView()
    var imageURL: String?
    var content: String?
    
    var type: String! = "high"
    var highlowid: String?
    var date: String?
    
    var isPrivate: Bool = true
    
    var textViewHasBeenEdited: Bool = false {
        didSet {
            if #available(iOS 13.0, *), textViewHasBeenEdited || didChangeImage {
                self.isModalInPresentation = true
            }
        }
    }
    
    weak var delegate: EditHLDelegate?
    
    var headerImage: UIImage = UIImage(named: "add_image")!
    var didChangeImage: Bool = false {
        didSet {
            if #available(iOS 13.0, *), textViewHasBeenEdited || didChangeImage {
                self.isModalInPresentation = true
            }
        }
    }
    
    private func icon(_ type: GridiconType) -> UIImage {
        let size = CGSize(width: 20.0, height: 20.0)
        return .gridicon(type, size: size)
    }
    
    var imageView: UIImageView = UIImageView()
    
    var scrollView: UIScrollView = UIScrollView()
    
    var textView: Aztec.EditorView = Aztec.EditorView(defaultFont: .systemFont(ofSize: 20), defaultHTMLFont: .systemFont(ofSize: 20), defaultParagraphStyle: .default, defaultMissingImage: UIImage())
    
    let imagePicker: UIImagePickerController = UIImagePickerController()

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateViewColors()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleDarkMode()
        //Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        //Filler view, to protect content on devices such as iPhone X with a notch
        let fillerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0))
        
        self.view.backgroundColor = getColor("White2Black")
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
        imageViewContainer.backgroundColor = getColor("Separator")
        
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
        
        spacer.layer.shadowColor = UIColor.black.cgColor
        spacer.layer.shadowRadius = 2
        spacer.layer.shadowOffset = CGSize(width: 0, height: 2)
        spacer.layer.shadowOpacity = 0.2
        
        spacer.centerX(scrollView).eqWidth(scrollView).topToBottom(imageViewContainer).height(10)
        
        //Add textView
        scrollView.addSubview(textView)
        
        scrollView.bringSubviewToFront(spacer)
        
        //textView constraints
        textView.centerX(scrollView).eqWidth(scrollView, -40).topToBottom(spacer)
        textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 350).isActive = true
        
        
        //textView setup
        textView.setHTML(content ?? "Enter Text")
        
        if content == "" {
            textView.setHTML("Enter Text")
        }
        
        textView.richTextView.delegate = self
        //textView.font = UIFont.systemFont(ofSize: 20)
        
        let toolBar = Aztec.FormatBar()
        let bold = FormatBarItem(image: .gridicon(.bold), identifier: "bold")
        let italic = FormatBarItem(image: .gridicon(.italic), identifier: "italic")
        let underline = FormatBarItem(image: .gridicon(.underline), identifier: "underline")
        let link = FormatBarItem(image: .gridicon(.link), identifier: "link")
        let strikethrough = FormatBarItem(image: .gridicon(.strikethrough), identifier: "strikethrough")
        let blockquote = FormatBarItem(image: .gridicon(.quote), identifier: "blockquote")
        toolBar.setDefaultItems([bold, italic, underline, link, strikethrough, blockquote])
        
        toolBar.tintColor = .gray
        toolBar.highlightedTintColor = AppColors.primary
        toolBar.selectedTintColor = AppColors.primary
        toolBar.backgroundColor = getColor("Separator")
        
        toolBar.barItemHandler = { formBarItem in
            switch formBarItem.identifier {
            case "bold":
                self.textView.richTextView.toggleBold(range: self.textView.richTextView.selectedRange)
                break
            case "italic":
                self.textView.richTextView.toggleItalic(range: self.textView.richTextView.selectedRange)
                break
            case "underline":
                self.textView.richTextView.toggleUnderline(range: self.textView.richTextView.selectedRange)
                break
            case "link":
                self.toggleLink()
                break
            case "strikethrough":
                self.textView.richTextView.toggleStrikethrough(range: self.textView.richTextView.selectedRange)
                break
            case "blockquote":
                self.textView.richTextView.toggleBlockquote(range: self.textView.richTextView.selectedRange)
                break
            default:
                break
            }
            
            self.updateFormatBar()
        }
        
        textView.richTextView.inputAccessoryView = toolBar
        textView.richTextView.autocorrectionType = .no
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image"]

        textView.isScrollEnabled = false
        textView.backgroundColor = .none
        
        
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
    
    func updateFormatBar() {
        guard let toolbar = textView.richTextView.inputAccessoryView as? Aztec.FormatBar else {
            return
        }

        let identifiers: Set<FormattingIdentifier>
        if textView.richTextView.selectedRange.length > 0 {
            identifiers = textView.richTextView.formattingIdentifiersSpanningRange(textView.richTextView.selectedRange)
        } else {
            identifiers = textView.richTextView.formattingIdentifiersForTypingAttributes()
        }

        toolbar.selectItemsMatchingIdentifiers(identifiers.map({ $0.rawValue }))
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func cancel() {
        self.dismiss(animated: true)
    }
    
    func submit() {
        //First, we need to present a loader so the user knows it worked.
        let loader = HLLoaderView()
        
        self.view.addSubview(loader)
        
        loader.eqLeading(self.view).eqTrailing(self.view).eqTop(self.view).eqBottom(self.view)
        
        loader.startLoading()
        
        //Now we make the request to update the High/Low
        var parameters: [String: Any] = [
            "private": isPrivate,
            "request_id": UUID().uuidString
        ]
        
        if textViewHasBeenEdited {
            parameters[type] = textView.getHTML()
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
        
        authenticatedRequest(url: "/highlow/set/" + type, method: .post, parameters: parameters, file: file, onFinish: { json in
            
            loader.stopLoading()
            
            self.delegate?.didFinishEditingHL(data: json)
            
            self.dismiss(animated: true)
            
        }, onError: {error in
            
            loader.stopLoading()
            
        })
    }
    
    @objc func done() {
        
        let popup = PopupDialog(title: "Who do you want to see this High/Low?", message: "You can make them private or public")
        popup.addButtons([
            DestructiveButton(title: "Public") {
                self.isPrivate = false
                self.submit()
            },
            DefaultButton(title: "Private") {
                self.isPrivate = true
                self.submit()
            },
            DefaultButton(title: "Who can see my High/Lows?") {
                openURL("https://gethighlow.com/help/highlowvisibility.html")
            },
            CancelButton(title: "Cancel", action: nil)
        ])
        self.present(popup, animated: true)
        
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
    
    @objc func toggleLink() {
        var linkTitle = ""
        var linkURL: URL? = nil
        var linkRange = textView.richTextView.selectedRange
        // Let's check if the current range already has a link assigned to it.
        if let expandedRange = textView.richTextView.linkFullRange(forRange: textView.richTextView.selectedRange) {
           linkRange = expandedRange
           linkURL = textView.richTextView.linkURL(forRange: expandedRange)
        }
        let target = textView.richTextView.linkTarget(forRange: textView.richTextView.selectedRange)
        linkTitle = textView.richTextView.attributedText.attributedSubstring(from: linkRange).string
        let allowTextEdit = !textView.richTextView.attributedText.containsAttachments(in: linkRange)
        showLinkDialog(forURL: linkURL, text: linkTitle, target: target, range: linkRange, allowTextEdit: allowTextEdit)
    }
    
    func showLinkDialog(forURL url: URL?, text: String?, target: String?, range: NSRange, allowTextEdit: Bool = true) {

        let isInsertingNewLink = (url == nil)
        var urlToUse = url

        if isInsertingNewLink {
            let pasteboard = UIPasteboard.general
            if let pastedURL = pasteboard.value(forPasteboardType:String(kUTTypeURL)) as? URL {
                urlToUse = pastedURL
            }
        }

        let insertButtonTitle = isInsertingNewLink ? NSLocalizedString("Insert Link", comment:"Label action for inserting a link on the editor") : NSLocalizedString("Update Link", comment:"Label action for updating a link on the editor")
        let removeButtonTitle = NSLocalizedString("Remove Link", comment:"Label action for removing a link from the editor");
        let cancelButtonTitle = NSLocalizedString("Cancel", comment:"Cancel button")

        let alertController = UIAlertController(title:insertButtonTitle,
                                                message:nil,
                                                preferredStyle:UIAlertController.Style.alert)
        alertController.view.accessibilityIdentifier = "linkModal"

        alertController.addTextField(configurationHandler: { [weak self]textField in
            textField.clearButtonMode = UITextField.ViewMode.always;
            textField.placeholder = NSLocalizedString("URL", comment:"URL text field placeholder");
            textField.keyboardType = .URL
            textField.textContentType = .URL
            textField.text = urlToUse?.absoluteString

            textField.addTarget(self,
                action:#selector(EditHLViewController.alertTextFieldDidChange),
            for:UIControl.Event.editingChanged)
            
            textField.accessibilityIdentifier = "linkModalURL"
            })

        if allowTextEdit {
            alertController.addTextField(configurationHandler: { textField in
                textField.clearButtonMode = UITextField.ViewMode.always
                textField.placeholder = NSLocalizedString("Link Text", comment:"Link text field placeholder")
                textField.isSecureTextEntry = false
                textField.autocapitalizationType = UITextAutocapitalizationType.sentences
                textField.autocorrectionType = UITextAutocorrectionType.default
                textField.spellCheckingType = UITextSpellCheckingType.default

                textField.text = text;

                textField.accessibilityIdentifier = "linkModalText"

                })
        }

        alertController.addTextField(configurationHandler: { textField in
            textField.clearButtonMode = UITextField.ViewMode.always
            textField.placeholder = NSLocalizedString("Target", comment:"Link text field placeholder")
            textField.isSecureTextEntry = false
            textField.autocapitalizationType = UITextAutocapitalizationType.sentences
            textField.autocorrectionType = UITextAutocorrectionType.default
            textField.spellCheckingType = UITextSpellCheckingType.default

            textField.text = target;

            textField.accessibilityIdentifier = "linkModalTarget"

        })

        let insertAction = UIAlertAction(title:insertButtonTitle,
                                         style:UIAlertAction.Style.default,
                                         handler:{ [weak self]action in

                                            self?.textView.richTextView.becomeFirstResponder()
                                            guard let textFields = alertController.textFields else {
                                                    return
                                            }
                                            let linkURLField = textFields[0]
                                            let linkTextField = textFields[1]
                                            let linkTargetField = textFields[2]
                                            let linkURLString = linkURLField.text
                                            var linkTitle = linkTextField.text
                                            let target = linkTargetField.text

                                            if  linkTitle == nil  || linkTitle!.isEmpty {
                                                linkTitle = linkURLString
                                            }

                                            guard
                                                let urlString = linkURLString,
                                                let url = URL(string:urlString)
                                                else {
                                                    return
                                            }
                                            if allowTextEdit {
                                                if let title = linkTitle {
                                                    self?.textView.richTextView.setLink(url, title: title, target: target, inRange: range)
                                                }
                                            } else {
                                                self?.textView.richTextView.setLink(url, target: target, inRange: range)
                                            }
                                            })
        
        insertAction.accessibilityLabel = "insertLinkButton"

        let removeAction = UIAlertAction(title:removeButtonTitle,
                                         style:UIAlertAction.Style.destructive,
                                         handler:{ [weak self] action in
                                            self?.textView.richTextView.becomeFirstResponder()
                                            self?.textView.richTextView.removeLink(inRange: range)
            })

        let cancelAction = UIAlertAction(title: cancelButtonTitle,
                                         style:UIAlertAction.Style.cancel,
                                         handler:{ [weak self]action in
                                            self?.textView.richTextView.becomeFirstResponder()
            })

        alertController.addAction(insertAction)
        if !isInsertingNewLink {
            alertController.addAction(removeAction)
        }
            alertController.addAction(cancelAction)

        // Disabled until url is entered into field
        if let text = alertController.textFields?.first?.text {
            insertAction.isEnabled = !text.isEmpty
        }

        present(alertController, animated:true, completion:nil)
    }
    
    @objc func alertTextFieldDidChange(_ textField: UITextField) {
        guard
            let alertController = presentedViewController as? UIAlertController,
            let urlFieldText = alertController.textFields?.first?.text,
            let insertAction = alertController.actions.first
            else {
            return
        }

        insertAction.isEnabled = !urlFieldText.isEmpty
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
        
        scrollView.contentOffset.y = textView.intrinsicContentSize.height + textView.richTextView.inputAccessoryView!.intrinsicContentSize.height
        
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
