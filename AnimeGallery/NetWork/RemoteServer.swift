//
//  RemoteServer.swift
//  AnimeGallery
//
//  Created by 林宏勳 on 2022/6/11.
//

import UIKit

protocol NetworkSession {
    func loadData(from request: URLRequest,
                  completionHandler: @escaping (Data?, Error?) -> Void)
}

protocol QueryComicArtProtocol {
    func getTopAnimes(type: AnimeType, filter: AnimeFilter, page: Int, limit: Int, completion: @escaping (Result<AnimeTransferData, Error>) -> Void)
    func getTopMangas(type: MangaType, filter: MangaFilter, page: Int, limit: Int, completion: @escaping (Result<MangaTransferData, Error>) -> Void)
}

class RemoteServer: NSObject, QueryComicArtProtocol {
    
    static let shared = RemoteServer()
    private let session: NetworkSession
    
    let alertUtility = AlertUtility.shared
    
    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }
    
    enum ServerUrl: String {
        
        case topAnime = "top/anime"
        case topManga = "top/manga"
        
        func url() -> String {
            let baseUrl = "https://api.jikan.moe/v4/"
            return baseUrl + self.rawValue
        }
    }
    
    func getTopAnimes(type: AnimeType, filter: AnimeFilter, page: Int, limit: Int = 20, completion: @escaping (Result<AnimeTransferData, Error>) -> Void) {
        
        let urlString = ServerUrl.topAnime.url()
        let para = ["type": type.rawValue, "filter": filter.rawValue, "page": String(page), "limit": String(limit)]
        
        guard var urlComponents = URLComponents(string: urlString) else { return }
        urlComponents.queryItems = self.queryItems(withParameters: para)
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.httpMethod = "GET"
        
        session.loadData(from: request) { data, error in
            if error == nil {
                if let data = data {
                    
                    guard let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments), let dict = jsonObj as? [String: AnyObject] else {
                        return
                    }
                    
                    let transferData = AnimeTransferData()
                    
                    if let pagination = dict["pagination"] as? [String: AnyObject] {
                        let hasNextPage = pagination["has_next_page"] as? Bool ?? false
                        let currentPage = pagination["current_page"] as? Int
                        transferData.hasNextPage = hasNextPage
                        transferData.currentPage = currentPage
                    }
                    
                    if let items = dict["data"] as? [[String: AnyObject]] {
                        
                        var animeList: [Anime] = []
                        
                        for item in items {
                            let anime = Anime()
                            anime.malID = item["mal_id"] as? Int
                            anime.url = item["url"] as? String
                            
                            if let images = item["images"] as? [String: AnyObject], let jpg = images["jpg"] as? [String: AnyObject] {
                                anime.imageUrl = jpg["image_url"] as? String
                                anime.smallImageUrl = jpg["small_image_url"] as? String
                                anime.largeImageUrl = jpg["large_image_url"] as? String
                            }
                            
                            anime.title = item["title"] as? String
                            anime.rank = item["rank"] as? Int
                            
                            if let aired = item["aired"] as? [String: AnyObject] {
                                anime.start_date = aired["from"] as? String
                                anime.end_date = aired["to"] as? String
                            }
                            
                            animeList.append(anime)
                        }
                        
                        transferData.data = animeList
                        completion(.success(transferData))
                    }
                }
            } else {
                self.alertUtility.showAlert(msg: "Load anime list failed. Please try again later.")
                completion(.failure(error!))
            }
        }
    }
    
    func getTopMangas(type: MangaType, filter: MangaFilter, page: Int, limit: Int = 20, completion: @escaping (Result<MangaTransferData, Error>) -> Void) {
        
        let urlString = ServerUrl.topManga.url()
        let para = ["type": type.rawValue, "filter": filter.rawValue, "page": String(page), "limit": String(limit)]
        
        guard var urlComponents = URLComponents(string: urlString) else { return }
        urlComponents.queryItems = self.queryItems(withParameters: para)
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.httpMethod = "GET"
        
        session.loadData(from: request) { data, error in
            if error == nil {
                if let data = data {
                    
                    guard let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments), let dict = jsonObj as? [String: AnyObject] else {
                        return
                    }
                    
                    let transferData = MangaTransferData()
                    
                    if let pagination = dict["pagination"] as? [String: AnyObject] {
                        let hasNextPage = pagination["has_next_page"] as? Bool ?? false
                        let currentPage = pagination["current_page"] as? Int
                        transferData.hasNextPage = hasNextPage
                        transferData.currentPage = currentPage
                    }
                    
                    if let items = dict["data"] as? [[String: AnyObject]] {
                        
                        var mangaList: [Manga] = []
                        
                        for item in items {
                            let manga = Manga()
                            manga.malID = item["mal_id"] as? Int
                            manga.url = item["url"] as? String
                            
                            if let images = item["images"] as? [String: AnyObject], let jpg = images["jpg"] as? [String: AnyObject] {
                                manga.imageUrl = jpg["image_url"] as? String
                                manga.smallImageUrl = jpg["small_image_url"] as? String
                                manga.largeImageUrl = jpg["large_image_url"] as? String
                            }
                            
                            manga.title = item["title"] as? String
                            manga.rank = item["rank"] as? Int
                            
                            if let published = item["published"] as? [String: AnyObject] {
                                manga.start_date = published["from"] as? String
                                manga.end_date = published["to"] as? String
                            }
                            
                            mangaList.append(manga)
                        }
                        
                        transferData.data = mangaList
                        completion(.success(transferData))
                    }
                }
            } else {
                self.alertUtility.showAlert(msg: "Load manga list failed. Please try again later.")
                completion(.failure(error!))
            }
        }
    }
    
    //Private functions
    fileprivate func queryItems(withParameters dict: [String: String]?) -> [URLQueryItem]? {
        if (dict?.count ?? 0) > 0 {
            var items: [URLQueryItem] = []
            for key in dict!.keys {
                let item = URLQueryItem(name: key, value: dict![key])
                items.append(item)
            }

            return items
        }

        return nil
    }
}

extension URLSession: NetworkSession {
    func loadData(from request: URLRequest,
                  completionHandler: @escaping (Data?, Error?) -> Void) {
        let task = dataTask(with: request) { (data, _, error) in
            completionHandler(data, error)
        }

        task.resume()
    }
}
