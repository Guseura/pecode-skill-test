//
//  News.swift
//  test
//
//  Created by Yurij on 22.03.2021.
//

import Foundation

struct NewsJSON: Codable {
    let source: NewsSource?
    let title: String?
    let author: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let content: String?
    
    init() {
        self.title = String()
        self.author = String()
        self.description = String()
        self.url = String()
        self.urlToImage = String()
        self.source = NewsSource()
        self.content = String()
    }
}

struct NewsSource: Codable {
    let name: String
    
    init() {
        self.name = String()
    }
}

struct allNews: Codable {
    let articles: [NewsJSON]
    let totalResults: Int

    init() {
        self.articles = [NewsJSON]()
        self.totalResults = Int()
    }
}
