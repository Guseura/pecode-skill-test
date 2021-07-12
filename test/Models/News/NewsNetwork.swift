//
//  NewsNetwork.swift
//  test
//
//  Created by Yurij on 22.03.2021.
//

import Foundation

enum APIError: String, Error {
    case invalidData = "The data received from the server is invalid. Please try again"
    case decodingProblem
    case encodingProblem
    case invalidURL
    case unableToComplete = "Unable to completed your request. Please check your internet connection."
}

private let apiKey = "c1eeb4a365ec4f47aaa69d220dbe946d"
private let newsBaseURL = "https://newsapi.org/v2/"

struct NewsNetwork {
    
    func getNews(page: Int, query: String, category: Category?, country: Country?, completion: @escaping (Result<allNews, APIError>) -> Void) {
        
        let query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let urlString = "\(newsBaseURL)top-headlines?category=\(category?.rawValue.lowercased() ?? "")&country=\(country?.rawValue ?? "")&q=\(query ?? "")&page=\(page)&apiKey=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let newsResponse = try JSONDecoder().decode(allNews.self, from: data)
                completion(.success(newsResponse))
            } catch {
                print(error)
                completion(.failure(.decodingProblem))
            }
            
        }.resume()
        
    }
    
}
