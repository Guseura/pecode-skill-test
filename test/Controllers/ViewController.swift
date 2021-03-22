//
//  ViewController.swift
//  test
//
//  Created by Yurij on 21.03.2021.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Main tableView
    @IBOutlet weak var tableView: UITableView!
    
    //MARK - Search bar to search by ket words
    @IBOutlet weak var searchBar: UISearchBar!
    
    let newsCellID = "NewsTableViewCell"
    
    var listOfNews = [News]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    let wkViewController = WKViewController()
    let newsManager = NewsManager()
    let newsNetwork = NewsNetwork()
    
    var searchQuery: String = "" {
        didSet {
            fetchNews()
        }
    }
    var currentCountry: Country? = .de {
        didSet {
            fetchNews()
        }
    }
    var currentCategory: Category? = .business {
        didSet {
            fetchNews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        //MARK: - Register Cell
        let nibCell = UINib(nibName: newsCellID, bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: newsCellID)
        
        fetchNews()
        
        tableView.delegate = self
        
        //MARK: - Refresh action
        tableView.refreshControl = tableRefreshControl
    }
    
    func fetchNews() {
        newsNetwork.getNews(page: 1, query: searchQuery, category: currentCategory, country: currentCountry) { (result) in
            switch result {
            case .success(let newsResponse):
                self.listOfNews = newsResponse.articles
                self.newsManager.newsMaxPage = Int(ceil(Double(newsResponse.totalResults) / 20))
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchNewsPage() {
        newsNetwork.getNews(page: newsManager.getCurrentPage() , query: searchQuery, category: currentCategory, country: currentCountry) { (result) in
            switch result {
            case .success(let newsResponse):
                self.listOfNews.append(contentsOf: newsResponse.articles)
                self.newsManager.newsMaxPage = Int(ceil(Double(newsResponse.totalResults) / 20))
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //MARK: - Оновлення данних в таблиці
    let tableRefreshControl: UIRefreshControl = {
      let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    @objc private func refresh(sender: UIRefreshControl) {
        fetchNews()
        self.tableView.reloadData()
        sender.endRefreshing()
    }
    


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfNews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: newsCellID, for: indexPath) as! NewsTableViewCell
        
        let currentNews = listOfNews[indexPath.row]
        cell.activityIndicator.startAnimating()
        cell.titleLabel?.text = currentNews.title
        cell.descriptionLabel?.text = currentNews.description
        cell.authorLabel?.text = currentNews.author
        cell.sourceLabel?.text = currentNews.source?.name
        if let imageUrlString = currentNews.urlToImage {
            if let url = URL(string: imageUrlString) {
                cell.newsImage?.load(url: url, activityIndicator: cell.activityIndicator)
            }
        } else {
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let urlString = listOfNews[indexPath.row].url {
            wkViewController.urlString = urlString
            navigationController?.pushViewController(wkViewController, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == listOfNews.count - 2, newsManager.getCurrentPage() < newsManager.newsMaxPage {
            newsManager.setCurrentPage(page: newsManager.getCurrentPage() + 1)
            fetchNewsPage()
        }
    }
    
    
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchBarText = searchBar.text else {return}
        searchQuery = searchBarText
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery = searchText
    }
}

extension UIImageView {
    func load(url: URL, activityIndicator: UIActivityIndicatorView) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                        activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
}
