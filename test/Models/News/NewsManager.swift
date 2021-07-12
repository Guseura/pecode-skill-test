//
//  NewsManager.swift
//  test
//
//  Created by Yurij on 22.03.21.
//

import Foundation

class NewsManager {
    
    var newsCurrentPage = 1
    var newsMaxPage = 0
    
    func getCurrentPage() -> Int {
        return newsCurrentPage
    }
    
    func setCurrentPage(page: Int) {
        self.newsCurrentPage = page
    }
}
