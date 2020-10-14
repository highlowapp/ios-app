//
//  BibleBook.swift
//  HighLow
//
//  Created by Caleb Hester on 8/21/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation

struct BibleBooksResponse: Decodable {
    let data: [BibleBook]
}

struct BibleChaptersResponse: Decodable {
    let data: [BibleChapter]
}

struct BibleVersesResponse: Decodable {
    let data: [BibleVerse]
}

struct BibleVerseResponse: Decodable {
    let data: BibleVerseWithContent
}

struct BibleBook: Decodable {
    let id: String
    let bibleId: String
    let abbreviation: String
    let name: String
    let nameLong: String
}

struct BibleChapter: Decodable {
    let id: String
    let bibleId: String
    let bookId: String
    let number: String
    let reference: String
}

struct BibleVerse: Decodable {
    let id: String
    let orgId: String
    let bookId: String
    let chapterId: String
    let bibleId: String
    let reference: String
}

struct BibleVerseWithContent: Decodable {
    let id: String
    let orgId: String
    let bookId: String
    let chapterId: String
    let bibleId: String
    let reference: String
    let content: String
    let copyright: String
}

struct BibleChapterTextResponse: Decodable {
    let data: BibleChapterText
}

struct BibleChapterText: Decodable {
    let id: String
    let bibleId: String
    let number: String
    let bookId: String
    let reference: String
    let copyright: String
    let content: String
}

