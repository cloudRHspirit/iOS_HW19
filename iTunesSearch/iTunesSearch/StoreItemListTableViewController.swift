import UIKit

@MainActor
class StoreItemListTableViewController: UITableViewController {
    
    //MARK: - Outlets
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var filterSegmentedControl: UISegmentedControl!
    
    //MARK: - Instances
    let instStoreItemController = StoreItemController()
    
    var items = [StoreItem]()
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    
    let queryOptions = ["movie", "music", "software", "ebook"]
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - Methods
    func fetchMatchingItems() {
        self.items = []
        self.tableView.reloadData()
        
        let searchTerm = searchBar.text ?? ""
        let mediaType = queryOptions[filterSegmentedControl.selectedSegmentIndex]
        
        if !searchTerm.isEmpty {
            let query = [
                "term": searchTerm,
                "media": mediaType
            ]
            
            Task {
                do {
                    let items = try await instStoreItemController.fetchItems(matching: query)
                    self.items = items
                    self.tableView.reloadData()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func configure(cell: ItemCell, forItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        
        cell.name = item.trackName
        cell.artist = item.artistName
        cell.artworkImage = nil
        
        imageLoadTasks[indexPath] = Task {
            
            do {
                let images = try await instStoreItemController.fetchImage(from: item.artworkURL)
                cell.artworkImage = images
            } catch {
                print(error)
            }
        }
        
        imageLoadTasks[indexPath] = nil
    }
    
    //MARK: - Actions
    @IBAction func filterOptionUpdated(_ sender: UISegmentedControl) {
        fetchMatchingItems()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath) as! ItemCell
        configure(cell: cell, forItemAt: indexPath)

        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        imageLoadTasks[indexPath]?.cancel()
    }
}

//MARK: - Extensions
extension StoreItemListTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchMatchingItems()
        searchBar.resignFirstResponder()
    }
}
