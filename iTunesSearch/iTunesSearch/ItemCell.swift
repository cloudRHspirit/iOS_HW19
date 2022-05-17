import UIKit

class ItemCell: UITableViewCell {
    var name: String? = nil
    {
        didSet {
            if oldValue != name {
                setNeedsUpdateConfiguration()
            }
        }
    }
    var artist: String? = nil
    {
        didSet {
            if oldValue != artist {
                setNeedsUpdateConfiguration()
            }
        }
    }
    var artworkImage: UIImage? = nil
    {
        didSet {
            if oldValue != artworkImage {
                setNeedsUpdateConfiguration()
            }
        }
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        var content = defaultContentConfiguration().updated(for: state)
        content.text = name
        content.secondaryText = artist
        content.imageProperties.reservedLayoutSize = CGSize(width: 100.0, height: 100.0)
        
        if let image = artworkImage {
            content.image = image
        } else {
            content.image = UIImage(systemName: "photo")
            content.imageProperties.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 75.0)
            content.imageProperties.tintColor = .lightGray
        }
        self.contentConfiguration = content
    }
}
