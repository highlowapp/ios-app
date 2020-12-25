//
//  ChooseBibleVerseViewController.swift
//  HighLow
//
//  Created by Caleb Hester on 9/1/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit

class ChooseBibleVerseViewController: UIViewController {
    
    var books: [BibleBook] = []
    var chapters: [BibleChapter] = []
    var verses: [BibleVerse] = []

    let verseChooser: UIPickerView = UIPickerView()
    let verseDisplay: UITextView = UITextView()
    var currentVerse: BibleVerseWithContent?

    override func viewDidLoad() {
        super.viewDidLoad()
        handleDarkMode()
        
        self.view.backgroundColor = .white
        self.addSubviews([verseChooser, verseDisplay])
        
        let navigationBar = UINavigationBar()
        
        self.view.addSubview(navigationBar)
        
        navigationBar.eqTop(self.view).eqLeading(self.view).eqTrailing(self.view)
        
        let navTitle = UINavigationItem(title: "Choose a Bible Verse")
        
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSelf))
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButton))
        
        navTitle.leftBarButtonItem = cancel
        navTitle.rightBarButtonItem = done
        
        navigationBar.setItems([navTitle], animated: false)
        navigationBar.tintColor = AppColors.primary
        
        
        verseChooser.delegate = self
        verseChooser.dataSource = self
        verseChooser.backgroundColor = rgb(240, 240, 240)
        
        verseChooser.topToBottom(navigationBar).eqLeading(self.view).eqTrailing(self.view)
        verseDisplay.topToBottom(verseChooser, 20).eqLeading(self.view, 20).eqTrailing(self.view, -20).eqBottom(self.view, -20)
        
        verseDisplay.font = .preferredFont(forTextStyle: .body)
        
        verseDisplay.isScrollEnabled = true
        verseDisplay.isEditable = false
        
        loadBooks()
    }
    
    func loadBooks() {
        BibleService.shared.getBooks(onSuccess: { books in
            self.books = books
            self.verseChooser.reloadComponent(0)
            
            let selectedRow = self.verseChooser.selectedRow(inComponent: 0)
            if selectedRow < self.books.count {
                let book = self.books[selectedRow]
                self.loadChapters(book: book)
            }
        }, onError: { error in
            print(error)
        })
    }
    
    func loadChapters(book: BibleBook) {
        BibleService.shared.getChapters(bookId: book.id, onSuccess: { chapters in
            self.chapters = chapters
            self.chapters.remove(at: 0)
            self.verseChooser.reloadComponent(1)
            
            let selectedRow = self.verseChooser.selectedRow(inComponent: 1)
            if selectedRow < self.chapters.count {
                let chapter = self.chapters[selectedRow]
                self.loadVerses(chapter: chapter)
            }
        }, onError: { error in
            print(error)
        })
    }
    
    func loadVerses(chapter: BibleChapter) {
        BibleService.shared.getVerses(chapterId: chapter.id, onSuccess: { verses in
            self.verses = verses
            self.verseChooser.reloadComponent(2)
            
            let selectedRow = self.verseChooser.selectedRow(inComponent: 2)
            if selectedRow < self.verses.count {
                let verse = self.verses[selectedRow]
                self.displayVerse(verse: verse)
            }
        }, onError: { error in
            printer(error, .error)
        })
    }
    
    func displayVerse(verse: BibleVerse) {
        BibleService.shared.getVerse(verseId: verse.id, onSuccess: { verse in
            self.currentVerse = verse
            self.verseDisplay.text = verse.content
        }, onError: { error in
            printer(error, .error)
        })
    }

    @objc func cancelSelf() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doneButton() {
        if let currentVerse = currentVerse {
            let focus = [
                "focus": currentVerse.content,
                "reference": currentVerse.reference
            ]            
            NotificationCenter.default.post(name: .meditationFocusChanged, object: nil, userInfo: focus)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension ChooseBibleVerseViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return books.count
        } else if component == 1 {
            return chapters.count
        } else if component == 2 {
            return verses.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return self.books[row].name
        } else if component == 1 {
            return self.chapters[row].number
        } else if component == 2 {
            return String(row + 1)
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            if row < self.books.count {
                loadChapters(book: self.books[row])
            }
        } else if component == 1 {
            if row < self.chapters.count {
                loadVerses(chapter: self.chapters[row])
            }
        } else  if component == 2 {
            if row < self.verses.count {
                displayVerse(verse: self.verses[row])
            }
        }
    }
}
