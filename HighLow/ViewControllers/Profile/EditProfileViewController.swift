//
//  EditProfileViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 7/23/19.
//  Copyright © 2019 Caleb Hester. All rights reserved.
//

import UIKit
import TagListView
import PopupDialog

class EditProfileViewController: UITableViewController, UITableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, EditInterestsTableViewCellDelegate, EditInterestViewControllerDelegate, EditNameTableViewCellDelegate {
    func didChange(name whichName: String, toName name: String) {
        self.formState[whichName] = name
    }
    
    func willEdit() {
        let editInterestsViewController = EditInterestsViewController()
        let navigationController = UINavigationController(rootViewController: editInterestsViewController)
        
        navigationController.navigationBar.tintColor = .white
        navigationController.navigationBar.barStyle = .black
        //navigationController.navigationBar.barTintColor = AppColors.primary
        navigationController.navigationBar.isTranslucent = false
        
        editInterestsViewController.delegate = self
        
        self.present(navigationController, animated: true)
    }
    
    func willDisappear(tagsList: TagListView) {
        let tagViews = tagsList.tagViews
        var arr: [String] = []
        for tagView in tagViews {
            arr.append(tagView.titleLabel?.text ?? "")
        }
        
        formState["tags"] = arr
    }
    
    var user: UserResource? {
        didSet {
            formState = [
                "firstName": user?.firstname,
                "lastName": user?.lastname,
                "email": user?.email,
                "bio": user?.bio,
                "profileImage": user?.profileimage,
            ]
            tableView.reloadData()
        }
    }
    
    var formState: [String: Any] = [
        "firstName": "",
        "lastName": "",
        "email": "",
        "bio": "",
        "profileImage": "",
        "tags": []
        ]
    
    var updatedImage: UIImage?
    
    weak var delegate: EditProfileViewControllerDelegate?
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        
        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
            tableView.layoutIfNeeded()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateViewColors()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleDarkMode()
        self.view.backgroundColor = getColor("White2Black")

        tableView.keyboardDismissMode = .onDrag
        tableView.tableHeaderView = UIView()
        
        let controls = UIStackView()
        controls.axis = .horizontal
        controls.alignment = .center
        controls.distribution = .fillEqually
        
        tableView.tableHeaderView!.addSubview(controls)
        
        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(AppColors.primary, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        controls.addArrangedSubview(cancelButton)
        
        let doneButton = UIButton()
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(AppColors.primary, for: .normal)
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        
        controls.addArrangedSubview(doneButton)
        
        controls.eqTop(tableView.tableHeaderView!).eqWidth(tableView.tableHeaderView!).centerX(tableView.tableHeaderView!)
        
        let editProfileLabel = UILabel()
        editProfileLabel.text = "Edit Profile"
        editProfileLabel.font = .systemFont(ofSize: 20)
        editProfileLabel.textColor = .darkGray
        
        tableView.tableHeaderView!.addSubview(editProfileLabel)
        
        editProfileLabel.topToBottom(controls, 20).centerX(tableView.tableHeaderView!)
        
        tableView.tableHeaderView!.bottomAnchor.constraint(equalTo: editProfileLabel.bottomAnchor, constant: 20).isActive = true
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Name"
        case 1:
            return "Profile Image"
        case 2:
            return "Bio"
        default:
            return ""
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            let cell = EditNameTableViewCell(style: .default, reuseIdentifier: "editName")
            cell.delegate = self
            switch indexPath.row {
            case 0:
                cell.textField.text = formState["firstName"] as? String
                cell.namePiece = "firstName"
                break
            case 1:
                cell.textField.text = formState["lastName"] as? String
                cell.namePiece = "lastName"
                break
            default:
                break
            }
            
            return cell
        }
        
        if indexPath.section == 1 {
            let cell = EditProfileImageTableViewCell(style: .default, reuseIdentifier: "editProfileImage")
            cell.delegate = self
            if updatedImage == nil {
                if formState["profileImage"] as! String != "" {
                    cell.profileImage.loadImageFromURL(formState["profileImage"] as! String)
                }
            } else {
                cell.profileImage.image = updatedImage
                cell.profileImage.indicator.stopAnimating()
            }
            
            return cell
        }
        
        if indexPath.section == 2 {
            let cell = EditBioTableViewCell(style: .default, reuseIdentifier: "editBio")
            
            cell.textView.text = formState["bio"] as? String
            
            cell.delegate = self
            return cell
        }
        
        
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "none")
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 2
        }
        
        return 1
    }
    
    
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func done() {
        
        let loader = ProgressLoaderView()
        
        loader.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(loader)
        loader.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        loader.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        loader.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loader.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        loader.allowsSkip = false
        loader.setTitle("Saving...")
        
        let firstname = self.formState["firstName"] as? String ?? ""
        let lastname = self.formState["lastName"] as? String ?? ""
        let email = self.formState["email"] as? String ?? ""
        let bio = self.formState["bio"] as? String ?? ""
        
        
        user?.setProfile(firstname: firstname, lastname: lastname, email: email, bio: bio, profileimage: updatedImage, onSuccess: { json in
            loader.isHidden = true
            self.delegate?.editProfileViewControllerDidEndEditing()
            self.dismiss(animated: true, completion: nil)
        }, onError: { error in
            loader.isHidden = true
            alert()
        }, onProgressUpdate: { progress in
            loader.setProgress(Float(progress.fractionCompleted))
        })
        
    }
    
    func didAlert(alert: UIAlertController) {
        //self.present(alert, animated: true)
    }
    
    func didTap(sender: UITableViewCell) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.mediaTypes = ["public.image"]
        
        let alert = UIAlertController(title: "Choose an image source", message: "Would you like to use your camera or your photo roll?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { alertAction in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Existing Photo", style: .default, handler: { alertAction in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.popoverPresentationController?.sourceView = sender
        self.present(alert, animated: true)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[.editedImage] {
            self.updatedImage = img as? UIImage
            tableView.reloadData()
        }
        
        picker.dismiss(animated: true)
    }
    
    
}



//Edit Name Cell
class EditNameTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    let textField: UITextField = UITextField()
    weak var delegate: EditNameTableViewCellDelegate?
    var namePiece: String = "firstName"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
                
        self.contentView.addSubview(textField)
        self.backgroundColor = getColor("White2Black")
        self.isUserInteractionEnabled = true
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        textField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        textField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        textField.textColor = getColor("BlackText")
        textField.addTarget(self, action: #selector(textFieldDidChangeValue(_:)), for: .editingChanged)
        self.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 10).isActive = true
        
    }
    
    @objc func textFieldDidChangeValue(_ textField: UITextField) {
        self.delegate?.didChange(name: self.namePiece, toName: textField.text ?? "")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let parent = self.delegate as? EditProfileViewController else {
            return
        }
        parent.formState[self.namePiece] = textField.text ?? ""
    }
}

protocol EditNameTableViewCellDelegate: AnyObject {
    func didChange(name whichName: String, toName name: String)
}




//EditProfileImage
class EditProfileImageTableViewCell: UITableViewCell {
    let profileImage: HLImageView = HLImageView(frame: .zero)
    
    weak var delegate: UITableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        self.backgroundColor = getColor("White2Black")
        self.contentView.addSubview(profileImage)
        
        profileImage.isUserInteractionEnabled = true
        
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        
        profileImage.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        profileImage.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        self.contentView.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 10).isActive = true
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(onTap))
        
        profileImage.addGestureRecognizer(tapper)
    }
    
    @objc func onTap() {
        delegate?.didTap(sender: self)
    }
}




//Bio
class EditBioTableViewCell: UITableViewCell, UITextViewDelegate {
    
    let textView: UITextView = UITextView()
    
    weak var delegate: UITableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        self.backgroundColor = getColor("White2Black")
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 15)
        textView.delegate = self
        textView.textColor = getColor("BlackText")
        
        self.contentView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        textView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        textView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        self.contentView.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: 10).isActive = true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        
        if numberOfChars > 140 {
            alert("Whoops!", "140 character max for bio")
        }
        
        return numberOfChars <= 140
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let parent = delegate as? EditProfileViewController else {
            return
        }
        
        parent.formState["bio"] = textView.text
    }
}


class EditInterestsTableViewCell: UITableViewCell {
    let tagList: TagListView = TagListView()
    let editButton: UIButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    weak var delegate: EditInterestsTableViewCellDelegate?
    
    private func setup() {
        self.backgroundColor = getColor("White2Black")
        tagList.translatesAutoresizingMaskIntoConstraints = false
        tagList.textColor = .white
        tagList.tagBackgroundColor = AppColors.primary
        tagList.cornerRadius = 17
        tagList.textFont = .systemFont(ofSize: 15)
        tagList.paddingX = 10
        tagList.paddingY = 10
            
        self.contentView.addSubview(tagList)
        
        tagList.eqTop(self.contentView, 10).eqLeading(self.contentView, 10)
        
        self.contentView.addSubview(editButton)

        editButton.centerY(self.contentView).eqTrailing(self.contentView).eqWidth(self.contentView, 0.0, 0.2).height(40)
        
        tagList.trailingAnchor.link(editButton.leadingAnchor)
        
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitleColor(AppColors.primary, for: .normal)
        editButton.addTarget(self, action: #selector(edit), for: .touchUpInside)
        
        self.contentView.bottomAnchor.constraint(equalTo: tagList.bottomAnchor, constant: 10).isActive = true
    }
    
    @objc private func edit() {
        self.delegate?.willEdit()
    }
    
    public func loadTags(_ tags: [String]) {
        tagList.removeAllTags()
        tagList.addTags(tags)
    }
    
}

protocol EditInterestsTableViewCellDelegate: AnyObject {
    func willEdit()
}

protocol UITableViewCellDelegate: AnyObject {
    func didAlert(alert: UIAlertController)
    func didTap(sender: UITableViewCell)
}


protocol EditProfileViewControllerDelegate: AnyObject {
    func editProfileViewControllerDidEndEditing()
}
