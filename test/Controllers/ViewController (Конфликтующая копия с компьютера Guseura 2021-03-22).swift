//
//  ViewController.swift
//  test
//
//  Created by Yurij on 21.03.2021.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Оновлення данних в таблиці
    let tableRefreshControl: UIRefreshControl = {
      let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    //MARK: - Main tableView
    @IBOutlet weak var tableView: UITableView!
    
    //MARK - Search bar to search by ket words
    @IBOutlet weak var searchBar: UISearchBar!
    let newsCellID = "NewsTableViewCell"
    var listOfNews = [News]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.navigationItem.title = "\(self.listOfNews.count) found"
            }
        }
    }
    
    let wkViewController = WKViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        //MARK: - Register Cell
        let nibCell = UINib(nibName: newsCellID, bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: newsCellID)
        
        //MARK: - Refresh action
        tableView.refreshControl = tableRefreshControl
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        tableView.reloadData()
        sender.endRefreshing()
    }
    


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfNews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: newsCellID, for: indexPath) as! NewsTableViewCell
        
        let currentNews = listOfNews[indexPath.row]
        cell.titleLabel?.text = currentNews.title
        cell.descriptionLabel?.text = currentNews.description
        cell.authorLabel?.text = currentNews.author
        cell.sourceLabel?.text = currentNews.source?.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchBarText = searchBar.text else {return}
        let newsRequest = NewsNetwork()
        newsRequest.getTopCountryNews(country: searchBarText) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let news):
                self?.listOfNews = news
            }
            
        }
        
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
