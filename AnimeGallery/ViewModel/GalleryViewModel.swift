//
//  GalleryViewModel.swift
//  AnimeGallery
//
//  Created by 林宏勳 on 2022/6/10.
//

import Foundation
import CoreGraphics

enum OptionType {
    case type
    case filter
}

enum AnimeType: String, CaseIterable {
    case tv = "tv"
    case movie = "movie"
    case ova = "ova"
    case special = "special"
    case ona = "ona"
    case music = "music"
    case all = "all"
}

enum AnimeFilter: String, CaseIterable {
    case airing = "airing"
    case upcoming = "upcoming"
    case bypopularity = "bypopularity"
    case favorite = "favorite"
    case all = "all"
}

enum MangaType: String, CaseIterable {
    case manga = "manga"
    case novel = "novel"
    case lightnovel = "lightnovel"
    case oneshot = "oneshot"
    case doujin = "doujin"
    case manhwa = "manhwa"
    case manhua = "manhua"
    case all = "all"
}

enum MangaFilter: String, CaseIterable {
    case publishing = "publishing"
    case upcoming = "upcoming"
    case bypopularity = "bypopularity"
    case favorite = "favorite"
    case all = "all"
}

final class GalleryViewModel {
    
    typealias handler = () -> Void
    
    var alertMessage: String? {
        didSet {
            self.showAlert?()
        }
    }
    
    var hudMessage: String? {
        didSet {
            self.showHUDMessage?()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    private let categoryTypeList = ["Anime", "Manga", "Favorite"]
    
    var numberOfCategoryTypeList: Int {
        return categoryTypeList.count
    }
    
    var selectedCategory: Int = 0 {
        didSet {
            if selectedCategory == 0 || selectedCategory == 1 {
                self.setOptionTableViewHidden?(false)
            } else {
                self.setOptionTableViewHidden?(true)
            }
            
            self.reloadCategoryCollectionView?()
            self.reloadOptionTableView?()
            self.reloadComicArtTableView?()
        }
    }
    
    private let OptionTypeList = ["Type", "Filter"]
    
    var numberOfOptionTypeList: Int {
        return OptionTypeList.count
    }
    
    var animeType: AnimeType = .all {
        didSet {
            animeOptionChanged()
        }
    }
    
    var animeFilter: AnimeFilter = .all {
        didSet {
            animeOptionChanged()
        }
    }
    
    var mangaType: MangaType = .all {
        didSet {
            mangaOptionChanged()
        }
    }
    
    var mangaFilter: MangaFilter = .all {
        didSet {
            mangaOptionChanged()
        }
    }
    
    var comicArtList: [ComicArt] {
        if selectedCategory == 0 {        //Anime
            return animeList
        } else if selectedCategory == 1 { //Manga
            return mangaList
        } else {                          //Favorite
            return favoriteList
        }
    }
    
    var animeList: [Anime] = [] {
        didSet {
            self.reloadComicArtTableView?()
        }
    }
    
    var mangaList: [Manga] = [] {
        didSet {
            self.reloadComicArtTableView?()
        }
    }
    
    var favoriteList: [ComicArt] = [] {
        didSet {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: favoriteList, requiringSecureCoding: false)
                UserDefaults.standard.set(data, forKey: "favoriteList")
            } catch let err {
                print("Save favorite list to UserDefaults error: \(err.localizedDescription)")
            }
            
            self.reloadComicArtTableView?()
        }
    }
    
    var numberOfComicArts: Int {
        if selectedCategory == 0 {        //Anime
            return animeList.count
        } else if selectedCategory == 1 { //Manga
            return mangaList.count
        } else {
            return favoriteList.count     //Favorite
        }
    }
    
    var isTableViewScrolling = false
    
    var currentPage_anime: Int = 0
    var hasNextPage_anime: Bool = true
    var currentPage_manga: Int = 0
    var hasNextPage_manga: Bool = true
    
    var contentOffset_y_Anime: CGFloat = 0
    var contentOffset_y_Manga: CGFloat = 0
    var contentOffset_y_Favorite: CGFloat = 0
    
    var showAlert: handler?
    var showHUDMessage: handler?
    var updateLoadingStatus: handler?
    var reloadCategoryCollectionView: handler?
    var reloadOptionTableView: handler?
    var reloadComicArtTableView: handler?
    var presentWebView: ((_ url: String, _ title: String) -> Void)?
    var setOptionTableViewHidden: ((_ isHidden: Bool) -> Void)?
    
    init() {
        
    }
    
    func getCategoryType(at indexPath: IndexPath) -> String {
        return categoryTypeList[indexPath.row]
    }
    
    func getOptionType(at indexPath: IndexPath) -> String {
        return OptionTypeList[indexPath.row]
    }
    
    func didSelectCategoryType(at indexPath: IndexPath) {
        self.selectedCategory = indexPath.row
    }
    
    func didSelectAnimeType(_ type: AnimeType) {
        self.animeType = type
    }
    
    func didSelectAnimeFilter(_ filter: AnimeFilter) {
        self.animeFilter = filter
    }
    
    func didSelectMangaType(_ type: MangaType) {
        self.mangaType = type
    }
    
    func didSelectMangaFilter(_ filter: MangaFilter) {
        self.mangaFilter = filter
    }
    
    //MARK: Query Comic Art List
    func queryAnimeList(completion: (() -> Void)?) {
        if !hasNextPage_anime { return }
        
        self.isLoading = true
        RemoteServer.shared.getTopAnimes(type: self.animeType, filter: self.animeFilter, page: self.currentPage_anime + 1) { (result) in
            
            switch result {
            case .failure(let err):
                self.alertMessage = err.localizedDescription
            case .success(let data):
                if let page = data.currentPage {
                    self.currentPage_anime = page
                }
                
                self.hasNextPage_anime = data.hasNextPage
                
                if var list = data.data {
                    list.sort {
                        guard let rank0 = $0.rank, let rank1 = $1.rank else { return false }
                        return rank0 < rank1
                    }
                    self.animeList += list
                }
                
                completion?()
            }
            
            self.isLoading = false
        }
    }
    
    func queryMangaList(completion: (() -> Void)?) {
        if !hasNextPage_manga { return }
        
        self.isLoading = true
        RemoteServer.shared.getTopMangas(type: self.mangaType, filter: self.mangaFilter, page: self.currentPage_manga + 1) { (result) in
            
            switch result {
            case .failure(let err):
                self.alertMessage = err.localizedDescription
            case .success(let data):
                if let page = data.currentPage {
                    self.currentPage_manga = page
                }
                
                self.hasNextPage_manga = data.hasNextPage
                
                if var list = data.data {
                    list.sort {
                        guard let rank0 = $0.rank, let rank1 = $1.rank else { return false }
                        return rank0 < rank1
                    }
                    self.mangaList += list
                }
                
                completion?()
            }
            
            self.isLoading = false
        }
    }
    
    //MARK: Favorite
    func addOrRemoveFavorite(_ comicArt: ComicArt) {
        if self.isInFavoriteList(comicArt) {
            self.favoriteList = self.favoriteList.filter {
                $0.malID != comicArt.malID
            }
            self.hudMessage = "Removed from Favorite list"
        } else {
            self.favoriteList.append(comicArt)
            self.hudMessage = "Added to Favorite list"
        }
    }
    
    func isInFavoriteList(_ comicArt: ComicArt) -> Bool {
        for favorite in self.favoriteList {
            if favorite.malID == comicArt.malID {
                return true
            }
        }
        
        return false
    }
    
    func loadFavoriteList() {
        do {
            guard let data = UserDefaults.standard.object(forKey: "favoriteList") as? Data else { return }
            if let favoriteList = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Array<ComicArt> {
                self.favoriteList = favoriteList
            }
        } catch let err {
            print("Load favorite list from UserDefaults error: \(err.localizedDescription)")
        }
    }
    
    //MARK:  Option Changed
    fileprivate func animeOptionChanged() {
        self.reloadOptionTableView?()
        
        self.animeList = []
        self.currentPage_anime = 0
        self.hasNextPage_anime = true
        
        self.queryAnimeList {
            self.reloadComicArtTableView?()
        }
    }
    
    fileprivate func mangaOptionChanged() {
        self.reloadOptionTableView?()
        
        self.mangaList = []
        self.currentPage_manga = 0
        self.hasNextPage_manga = true
        
        self.queryMangaList {
            self.reloadComicArtTableView?()
        }
    }
}
