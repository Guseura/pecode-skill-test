
import UIKit
import SystemConfiguration
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    let newsCellID = "NewsTableViewCell"
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var memoryNews:[News]?
    
    let wkViewController = WKViewController()
    let newsNetwork = NewsNetwork()
    
    var listOfNews = [NewsJSON]()
    var currentCountry: Country? = .us
    var currentCategory: Category? = .general
    
    var searchQuery: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibCell = UINib(nibName: newsCellID, bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: newsCellID)
        
        tableView.delegate = self
        tableView.refreshControl = tableRefreshControl
        
        if (isConnectedToNetwork()) {
            fetchDataNews()
            deleteNews()
            fetchNews()
        } else {
            fetchDataNews()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isConnectedToNetwork() {
            activityView.startAnimating()
        } else {
            activityView.isHidden = true
        }
    }
    
    func fetchDataNews() {
        do {
            let request = News.fetchRequest() as NSFetchRequest<News>
            let pred = NSPredicate(format: "isFavorite == %@", NSNumber(value: false))
            request.predicate = pred
            self.memoryNews = try context.fetch(request)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch { }
    }
    
    func fetchNews() {
        newsNetwork.getNews(page: 1, query: searchQuery, category: currentCategory, country: currentCountry) { (result) in
            switch result {
            case .success(let newsResponse):
                self.listOfNews = newsResponse.articles
                for news in self.listOfNews {
                    let newNews = News(context: self.context)
                    newNews.title = news.title
                    newNews.descr = news.description
                    newNews.author = news.author
                    newNews.isFavorite = false
                    newNews.source = news.source?.name
                    newNews.webURL = news.url
                    
                    // TODO: - If connected to internet load images to view from web, and loading to data move on foreground to make loading news faster
                    if news.urlToImage != "" && news.urlToImage != nil {
                        let imageData = try? Data(contentsOf: URL(string: news.urlToImage!)!)
                        newNews.image = imageData
                    }
                    do {
                        try self.context.save()
                    }
                    catch { }
                }
                DispatchQueue.main.async {
                    if self.activityView.isAnimating {
                        self.activityView.stopAnimating()
                        self.activityView.isHidden = true
                    }
                }
                self.fetchDataNews()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func deleteNews() {
        if self.memoryNews != nil {
            for item in self.memoryNews! {
                self.context.delete(item)
            }
            do {
                try self.context.save()
            }
            catch { }
            self.fetchDataNews()
        }
    }
    
    public func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    let tableRefreshControl: UIRefreshControl = {
      let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    @objc private func refresh(sender: UIRefreshControl) {
        if isConnectedToNetwork() {
            activityView.isHidden = false
            activityView.startAnimating()
            deleteNews()
            fetchNews()
        }
        self.tableView.reloadData()
        sender.endRefreshing()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if memoryNews == nil{
            return 0
        } else {
            return memoryNews!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: newsCellID, for: indexPath) as! NewsTableViewCell
        
        let currentNews = memoryNews![indexPath.row]

        cell.titleLabel?.text = currentNews.title
        cell.authorLabel?.text = currentNews.author
        cell.sourceLabel?.text = currentNews.source
        cell.isFavorite = false
        if currentNews.image != nil {
            cell.newsImage?.image = UIImage(data: currentNews.image!)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let currentNewsController = storyboard.instantiateViewController(identifier: "CurrentNewsViewController") as? CurrentNewsViewController else { return }
        currentNewsController.currentNews = memoryNews?[indexPath.row]
        show(currentNewsController, sender: nil)
    }
}
