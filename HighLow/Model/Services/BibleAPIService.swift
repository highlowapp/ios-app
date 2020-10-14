//
//  BibleAPIService.swift
//  HighLow
//
//  Created by Caleb Hester on 8/21/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import Foundation
import Alamofire

class BibleService {
    static let shared = BibleService()
    
    let bibleId: String = "de4e12af7f28f599-02"
    
    var apiKey: String {
        get {
            return getBibleAPIKey()
        }
    }
    
    let base_url: String = "https://api.scripture.api.bible"
    
    func urlFromMap(_ url: String, _ params: [String: Any]?) -> String {
        if params == nil {
            return base_url + url
        }
        
        var completeUrl = base_url + url
        
        var i = 0
        
        for (key, value) in params! {
            if i == 0 {
                completeUrl += "?"
            } else {
                completeUrl += "&"
            }
            
            if let val = value as? String {
                completeUrl += key + "=" + val
            } else if let val = value as? Bool {
                completeUrl += key + "=" + String(val)
            } else if let val = value as? Int {
                completeUrl += key + "=" + String(val)
            }
            
            i += 1
        }
        
        return completeUrl
    }
    
    func authenticatedRequest(_ url: String, method: HTTPMethod, params: [String: Any]?, onSuccess: @escaping (_ json: Data) -> Void, onError: @escaping (_ error: String) -> Void) {
        var completeUrl = ""
        
        var finalParams: [String: Any] = [:]
        
        if params != nil {
            finalParams.merge(params!, uniquingKeysWith: { (current, _) in current })
        }
                
        if method == .get {
            completeUrl = urlFromMap(url, finalParams)
        } else {
            completeUrl = base_url + url
        }
        
        let headers: HTTPHeaders = [
            "api-key": apiKey
        ]
        
        AF.request(completeUrl, method: method, parameters: (method == .delete ? nil:finalParams), encoding: (method == .get ? URLEncoding.queryString:URLEncoding.httpBody), headers: headers).responseData { response in
            switch response.result {
            case .success(let result):
                onSuccess(result)
                break
            case .failure(let error):
                printer(error, .error)
                onError(error.errorDescription ?? "unknown-error")
                break
            }
        }
    }

    func getBooks(onSuccess: @escaping (_ books: [BibleBook]) -> Void, onError: @escaping (_ error: String) -> Void) {
        authenticatedRequest("/v1/bibles/" + bibleId + "/books", method: .get, params: nil, onSuccess: { json in
            let decoder = JSONDecoder()
            do {
                let booksResponse = try decoder.decode(BibleBooksResponse.self, from: json)
                let books = booksResponse.data
                onSuccess(books)
            } catch {
                onError("Could not decode")
            }
            
        }, onError: onError)
    }
    
    func getChapters(bookId: String, onSuccess: @escaping (_ chapters: [BibleChapter]) -> Void, onError: @escaping (_ error: String) -> Void) {
        authenticatedRequest("/v1/bibles/" + bibleId + "/books/" + bookId + "/chapters", method: .get, params: nil, onSuccess: { json in
            let decoder = JSONDecoder()
            
            do {
                let chaptersResponse = try decoder.decode(BibleChaptersResponse.self, from: json)
                let chapters = chaptersResponse.data
                onSuccess(chapters)
            } catch {
                onError("Could not decode")
            }
        }, onError: onError)
    }
    
    func getVerses(chapterId: String, onSuccess: @escaping (_ verses: [BibleVerse]) -> Void, onError: @escaping (_ error: String) -> Void) {
        authenticatedRequest("/v1/bibles/" + bibleId + "/chapters/" + chapterId + "/verses", method: .get, params: nil, onSuccess: { json in
            let decoder = JSONDecoder()
            
            do {
                let versesResponse = try decoder.decode(BibleVersesResponse.self, from: json)
                let verses = versesResponse.data
                onSuccess(verses)
            } catch {
                onError("Could not decode")
            }
        }, onError: onError)
    }
    
    func getChapterText(chapterId: String, onSuccess: @escaping (_ chapter: BibleChapterText) -> Void, onError: @escaping (_ error: String) -> Void) {
        authenticatedRequest("/v1/bibles/" + bibleId + "/chapters/" + chapterId, method: .get, params: nil, onSuccess: { json in
            let decoder = JSONDecoder()
            
            do {
                let chapterResponse = try decoder.decode(BibleChapterTextResponse.self, from: json)
                let chapter = chapterResponse.data
                onSuccess(chapter)
            } catch {
                onError("Could not decode")
            }
        }, onError: onError)
    }
    
    func getVerse(verseId: String, onSuccess: @escaping (_ verse: BibleVerseWithContent) -> Void, onError: @escaping (_ error: String) -> Void) {
        authenticatedRequest("/v1/bibles/" + bibleId + "/verses/" + verseId + "?content-type=text", method: .get, params: nil, onSuccess: { json in
            let decoder = JSONDecoder()
            do {
                let verseResponse = try decoder.decode(BibleVerseResponse.self, from: json)
                let verse = verseResponse.data
                onSuccess(verse)
            } catch {
                onError("Could not decode")
            }
        }, onError: onError)
    }
}
