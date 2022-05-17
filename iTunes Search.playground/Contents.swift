//MARK: - Importing frameworks
import UIKit
import Foundation

//MARK: - Extensions
extension Data {
    func prettyPrintedJSONString() {
        guard
            let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
            let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
            let prettyJSONString = String(data: jsonData, encoding: .utf8) else {
            print("Failed to read JSON object")
            return
        }
        print(prettyJSONString)
    }
}

//MARK: - Structures
struct StoreItem: Codable {
    let trackName: String
    let artistName: String
    var kind: String
    var description: String
    var artworkURL: URL
    
    enum CodingKeys: String, CodingKey {
        case trackName = "trackName"
        case artistName = "artistName"
        case kind
        case description = "longDescription"
        case artworkURL = "artworkUrl100"
    }
    
    enum AdditionalKeys: String, CodingKey {
        case longDescription
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        trackName = try values.decode(String.self, forKey: CodingKeys.trackName)
        artistName = try values.decode(String.self, forKey: CodingKeys.artistName)
        kind = try values.decode(String.self, forKey: CodingKeys.kind)
        artworkURL = try values.decode(URL.self, forKey:
           CodingKeys.artworkURL)
        
        if let description = try? values.decode(String.self,
           forKey: CodingKeys.description) {
            self.description = description
        } else {
            let additionalValues = try decoder.container(keyedBy: AdditionalKeys.self)
            description = (try? additionalValues.decode(String.self,forKey: AdditionalKeys.longDescription)) ?? ""
        }
    }
}

struct SearchResponse: Codable {
    let results: [StoreItem]
}

//MARK: - Enumerations
enum StoreItemError: Error, LocalizedError {
    case itemsNotFound
}

//MARK: - Functions
func fetchItems(matching query: [String: String]) async
   throws -> [StoreItem] {
    var baseURL = URLComponents(string: "https://itunes.apple.com/search")!
    baseURL.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
    let (data, response) = try await URLSession.shared.data(from: baseURL.url!)
        guard let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode == 200 else {
        throw StoreItemError.itemsNotFound
    }

    let decoder = JSONDecoder()
    let searchResponse = try decoder.decode(SearchResponse.self, from: data)

    return searchResponse.results
}

//MARK: - Queries
let query = [
    "term": "Apple",
        "media": "ebook",
        "attribute": "authorTerm",
        "lang": "en_us",
        "limit": "10"
]

//MARK: - Closures
Task {
    do {
        let storeItems = try await fetchItems(matching: query)
        storeItems.forEach { item in
            print("""
            Name: \(item.trackName)
            Artist: \(item.artistName)
            Kind: \(item.kind)
            Description: \(item.description)
            Artwork URL: \(item.artworkURL)
            
            """)
        }
    } catch {
        print(error)
    }
}
