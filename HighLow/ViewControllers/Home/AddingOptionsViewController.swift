//
//  AddingOptionsViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 6/23/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class AddingOptionsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    weak var delegate: AddingOptionsViewControllerDelegate?
    
    let items: [[AddOption]] = [
        [AddOption(image: "DiaryThumbnail", title: "Diary Entry", action: #selector(createDiaryEntry)),
         AddOption(image: "HighLowSmallIcon", title: "High/Low", action: #selector(createHighLow)),
         AddOption(image: "AudioDiarySmallIcon", title: "Audio Diary", action: #selector(createAudioEntry)),
         AddOption(image: "Meditation", title: "Meditation", action: #selector(startMeditationSession))],
        [AddOption(image: "DiaryThumbnail", title: "Diary Entry", action: #selector(createDiaryEntry)),
         AddOption(image: "DiaryThumbnail", title: "Diary Entry", action: #selector(createDiaryEntry)),
         AddOption(image: "DiaryThumbnail", title: "Diary Entry", action: #selector(createDiaryEntry)),
         AddOption(image: "DiaryThumbnail", title: "Diary Entry", action: #selector(createDiaryEntry))]
    ]
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddOption", for: indexPath) as! AddOptionCell
        cell.awakeFromNib()
        cell.setAddOption(items[indexPath.section][indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selector = items[indexPath.section][indexPath.row].action
        self.perform(selector)
        delegate?.didSelectItem()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2.5, height: collectionView.frame.width/2.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: (collectionView.frame.height - (2 * collectionView.frame.width/2.5 + 10) )/2, left: (collectionView.frame.width - (2 * collectionView.frame.width/2.5 + 10) )/2, bottom: (collectionView.frame.height - (2 * collectionView.frame.width/2.5 + 10) )/2, right: (collectionView.frame.width - (2 * collectionView.frame.width/2.5 + 10) )/2)
    }
    
    
    let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view = PopupView()
        
        self.view.addSubview(collectionView)
        
        collectionView.backgroundColor = .white
        
        collectionView.eqLeading(view, 10).eqTrailing(view, -10).eqTop(view, 10).eqBottom(view, -30)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(AddOptionCell.self, forCellWithReuseIdentifier: "AddOption")
        
        collectionView.isPagingEnabled = true
    }
    
    @objc func createDiaryEntry() {
        if let tabController = self.parent as? CustomTabBarController {
            tabController.selectedIndex = 2
            if let navController = tabController.selectedViewController as? UINavigationController {
                let data: NSDictionary = [
                    "title": "Untitled Entry",
                    "blocks": [
                        [
                            "type": "h1",
                            "content": "",
                            "editable": true
                        ]
                    ]
                ]
                ActivityService.shared.createActivity(type: .diary, data: data, onSuccess: { activity in
                    
                    NotificationCenter.default.post(name: NSNotification.Name("updatedDiary"), object: nil)
                    
                    let editor = DiaryEditorViewController()
                    editor.activity = activity
                    navController.pushViewController(editor, animated: true)
                    
                }, onError: { error in
                })
            }
        }
    }
    
    @objc func createHighLow() {
        if let tabController = self.parent as? CustomTabBarController {
            tabController.selectedIndex = 2
            if let navController = tabController.selectedViewController as? UINavigationController {
                let data: NSDictionary = [
                    "title": "Untitled Entry",
                    "blocks": [
                        [
                            "type": "h1",
                            "content": "High",
                            "editable": false
                        ],
                        [
                            "type": "img"
                        ],
                        [
                            "type": "p",
                            "content": "",
                            "editable": true
                        ],
                        [
                            "type": "h1",
                            "content": "Low",
                            "editable": false
                        ],
                        [
                            "type": "img"
                        ],
                        [
                            "type": "p",
                            "content": "",
                            "editable": true
                        ],
                    ]
                ]
                ActivityService.shared.createActivity(type: .highlow, data: data, onSuccess: { activity in
                    
                    let editor = DiaryEditorViewController()
                    editor.activity = activity
                    navController.pushViewController(editor, animated: true)
                    
                }, onError: { error in
                    
                })
            }
        }
    }

    @objc func createAudioEntry() {
        let recordAudioViewController = RecordAudioDiaryViewController()
        self.present(recordAudioViewController, animated: true)
    }
    
    @objc func startMeditationSession() {
        let startMeditationSessionViewController = StartMeditationSessionViewController()
        startMeditationSessionViewController.modalPresentationStyle = .fullScreen
        self.present(startMeditationSessionViewController, animated: true)
    }
}


protocol AddingOptionsViewControllerDelegate: AnyObject {
    func didSelectItem()
}





class PopupView: UIView {
    
    private var shapeLayer: CALayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private  func setup() {
        
    }
    
    override func draw(_ rect: CGRect) {
        self.addShape()
    }
    
    private func addShape() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 1.0
        
        if let oldShapeLayer = self.shapeLayer {
            self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.layer.insertSublayer(shapeLayer, at: 0)
        }
        
        self.shapeLayer = shapeLayer
        self.shapeLayer?.shadowColor = UIColor.black.cgColor
        self.shapeLayer?.shadowOffset = CGSize(width: 0, height: 10)
        self.shapeLayer?.shadowRadius = 10
        self.shapeLayer?.shadowOpacity = 0.2
    }
    
    private func createPath() -> CGMutablePath {
        let path = CGMutablePath()
        let centerWidth = self.frame.width / 2

        path.move(to: CGPoint(x: 0, y: 0))
        path.addRoundedRect(in: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height - 20), cornerWidth: 10, cornerHeight: 10)
        path.move(to: CGPoint(x: centerWidth - 15, y: self.frame.height - 20))
        path.addLine(to: CGPoint(x: centerWidth, y: self.frame.height - 3))
        path.addLine(to: CGPoint(x: centerWidth + 15, y: self.frame.height - 20))
        
        return path
    }
}
