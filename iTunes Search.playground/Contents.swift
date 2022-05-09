//MARK: - Importing frameworks
import UIKit

//MARK: - Variables
var baseURL = URLComponents(string:"https://itunes.apple.com/search")!

//MARK: - Procedures
baseURL.queryItems = [
    "term" : "Venom",
    "media" : "movie"
].map({URLQueryItem(name: $0.key, value: $0.value)})

//MARK: - Closures
Task {
    let (data, response) = try await URLSession.shared.data(from: baseURL.url!)
    
    if let httpResponse = response as? HTTPURLResponse,
       httpResponse.statusCode == 200,
       let string = String(data: data, encoding: .utf8) {
        print(string)
    }
}
