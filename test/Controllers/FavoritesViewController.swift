
import UIKit
import CoreData

class FavoritesViewController: UIViewController {

    @IBOutlet weak var tableIView: UITableView!
    
    let newsCellID = "NewsTableViewCell"
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var favoritesNews: [News]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nibCell = UINib(nibName: newsCellID, bundle: nil)
        tableIView.register(nibCell, forCellReuseIdentifier: newsCellID)
        
        tableIView.dataSource = self
        tableIView.delegate = self
        
        fetchNews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchNews()
        tableIView.reloadData()
    }
    
    func fetchNews() {
        do {
            let request = News.fetchRequest() as NSFetchRequest<News>
            let pred = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
            request.predicate = pred
            self.favoritesNews = try context.fetch(request)
        }
        catch {}
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesNews!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: newsCellID, for: indexPath) as! NewsTableViewCell
        
        let currentNews = favoritesNews![indexPath.row]
        
        cell.titleLabel?.text = currentNews.title
        cell.authorLabel?.text = currentNews.author
        cell.sourceLabel?.text = currentNews.source
        cell.isFavorite = currentNews.isFavorite
        if currentNews.image != nil {
            cell.newsImage?.image = UIImage(data: currentNews.image!)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let currentNewsController = storyboard.instantiateViewController(identifier: "CurrentNewsViewController") as? CurrentNewsViewController else { return }
        currentNewsController.currentNews = favoritesNews?[indexPath.row]

        show(currentNewsController, sender: nil)
    }
}
