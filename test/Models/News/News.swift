//
//  News.swift
//  test
//
//  Created by Yurij on 22.03.2021.
//

import Foundation

struct News: Codable {
    let source: NewsSource?
    let title: String?
    let author: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    
    init() {
        self.title = String()
        self.author = String()
        self.description = String()
        self.url = String()
        self.urlToImage = String()
        self.source = NewsSource()
        
    }
}

struct NewsSource: Codable {
    let name: String
    
    init() {
        self.name = String()
    }
}

struct allNews: Codable {
    let articles: [News]
    let totalResults: Int

    init() {
        self.articles = [News]()
        self.totalResults = Int()
    }
}
