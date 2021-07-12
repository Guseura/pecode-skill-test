
import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var bookmarkImageView: UIImageView!
    
    var isFavorite: Bool!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        newsImage.image = nil
        if isFavorite {
            bookmarkImageView.isHidden = false
            bookmarkImageView.image = UIImage(systemName: "bookmark.fill")
        }
        else {
            bookmarkImageView.isHidden = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if isFavorite == false {
            bookmarkImageView.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
}
