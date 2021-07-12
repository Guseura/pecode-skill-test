
import UIKit

class CurrentNewsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var readMoreButton: UIButton!
    
    var currentNews: News!
    let wkViewController = WKViewController()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var memoryNews:[News]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = currentNews?.title
        contentLabel.text = currentNews?.descr
        if currentNews?.image != nil {
            newsImageView.image = UIImage(data: (currentNews?.image)!)
        }
        
        if currentNews.source != "" {
            title = currentNews.source
        }
        else {
            title = "News"
        }
        
        do {
            self.memoryNews = try context.fetch(News.fetchRequest())
        }
        catch { }
        if ((currentNews?.isFavorite)!) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: .init(systemName: "bookmark.fill"), style: .plain, target: self, action: #selector(bookmarkClicked))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: .init(systemName: "bookmark"), style: .plain, target: self, action: #selector(bookmarkClicked))
        }
    }
    
    override func viewWillLayoutSubviews() {
        readMoreButton.layer.cornerRadius = 12
    }
    
    @objc
    func bookmarkClicked(){
        if currentNews.isFavorite {
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "bookmark")
        } else {
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "bookmark.fill")
        }
        currentNews.isFavorite = !currentNews.isFavorite
        do {
            try self.context.save()
        }
        catch {}
    }
    
    @IBAction func readMoreButtonClicked(_ sender: Any) {
        if let urlString = currentNews?.webURL {
            wkViewController.urlString = urlString
            navigationController?.pushViewController(wkViewController, animated: true)
        }
    }
    
}
