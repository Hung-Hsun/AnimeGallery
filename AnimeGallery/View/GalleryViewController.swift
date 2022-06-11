//
//  GalleryViewController.swift
//  AnimeGallery
//
//  Created by 林宏勳 on 2022/6/10.
//

import UIKit
import SwifterSwift

class GalleryViewController: UIViewController {

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var optionTableView: UITableView!
    @IBOutlet weak var comicArtTableView: UITableView!
    
    lazy var viewModel: GalleryViewModel = {
        return GalleryViewModel()
    }()
    
    let alertUtility = AlertUtility.shared
    let hudUtility = HUDUtility.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
        initViewModel()
    }

    private func setView() {
        title = "My Anime List"
        
        self.categoryCollectionView.register(UINib(nibName: CategoryCell.className, bundle: nil), forCellWithReuseIdentifier: CategoryCell.reusableId)
        self.optionTableView.register(UINib(nibName: OptionCell.className, bundle: nil), forCellReuseIdentifier: OptionCell.reusableId)
        self.comicArtTableView.register(UINib(nibName: ComicArtCell.className, bundle: nil), forCellReuseIdentifier: ComicArtCell.reusableId)
        
        self.comicArtTableView.tableFooterView = UIView()
    }
    
    func initViewModel() {
        viewModel.showAlert = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let msg = self.viewModel.alertMessage {
                    self.alertUtility.showAlert(msg: msg)
                }
            }
        }
        
        viewModel.updateLoadingStatus = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                let isLoading = self.viewModel.isLoading
                if isLoading {
                    self.hudUtility.displayProgressHud(msg: "讀取中")
                } else {
                    self.hudUtility.endHud()
                }
            }
        }
        
        viewModel.reloadCategoryCollectionView = { [weak self] () in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.categoryCollectionView.reloadData()
            }
        }
        
        viewModel.reloadOptionTableView = { [weak self] () in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.optionTableView.reloadData()
            }
        }
        
        viewModel.reloadComicArtTableView = { [weak self] () in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.comicArtTableView.reloadData() {
                    //Sroll to previous position
                    if self.viewModel.selectedCategory == 0 {
                        self.comicArtTableView.contentOffset = CGPoint(x: 0, y: self.viewModel.contentOffset_y_Anime)
                    } else if self.viewModel.selectedCategory == 1 {
                        self.comicArtTableView.contentOffset = CGPoint(x: 0, y: self.viewModel.contentOffset_y_Manga)
                    } else {
                        self.comicArtTableView.contentOffset = CGPoint(x: 0, y: self.viewModel.contentOffset_y_Favorite)
                    }
                }
            }
        }
        
        viewModel.presentWebView = { [weak self] (url, title) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                let vc = WebViewController(url: url, title: title)
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
}

extension GalleryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfCategoryTypeList
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.reusableId, for: indexPath) as! CategoryCell
        let title = viewModel.getCategoryType(at: indexPath)
        let isSelected = indexPath.row == viewModel.selectedCategory ? true : false
        cell.setupCell(title: title, isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectCategoryType(at: indexPath)
    }
}

extension GalleryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == optionTableView {
            if viewModel.selectedCategory == 0 || viewModel.selectedCategory == 1 { //Anime or Manga
                return viewModel.numberOfOptionTypeList
            } else {
                return 0
            }
        } else if tableView == comicArtTableView {
            let rows = viewModel.numberOfComicArts
            
            //No data condition
            if rows == 0 {
                tableView.setEmptyView(iconName: "empty", messages: "Currently No Data")
            } else {
                tableView.restore()
            }
            
            return rows
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == optionTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: OptionCell.reusableId, for: indexPath) as! OptionCell
            if viewModel.selectedCategory == 0 { //Anime
                if indexPath.row == 0 { //Type
                    cell.setupAnimeTypeCell(title: "Type", value: viewModel.animeType)
                } else { //Filter
                    cell.setupAnimeFilterCell(title: "Filter", value: viewModel.animeFilter)
                }
            } else if viewModel.selectedCategory == 1 { //Manga
                if indexPath.row == 0 { //Type
                    cell.setupMangaTypeCell(title: "Type", value: viewModel.mangaType)
                } else { //Filter
                    cell.setupMangaFilterCell(title: "Filter", value: viewModel.mangaFilter)
                }
            } else { //Favorite
                
            }
            
            return cell
        } else if tableView == comicArtTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: ComicArtCell.reusableId, for: indexPath) as! ComicArtCell
            
            let comicArt = viewModel.comicArtList[indexPath.row]
            let imageUrl = comicArt.imageUrl
            let title = comicArt.title
            let start_date = comicArt.start_date?.components(separatedBy: "T")[0]
            let end_date = comicArt.end_date?.components(separatedBy: "T")[0]
            let rank = comicArt.rank
            let isFavorite = false //TODO: 修正！
            
            cell.setupCell(imageUrl: imageUrl, title: title, start_date: start_date, end_date: end_date, rank: rank, isFavorite: isFavorite)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == optionTableView {
            if indexPath.row == 0 {
                self.showOptionSelector(optionType: .type)
            } else if indexPath.row == 1 {
                self.showOptionSelector(optionType: .filter)
            }
        } else if tableView == comicArtTableView {
            let comicArt = viewModel.comicArtList[indexPath.row]
            if let url = comicArt.url {
                let title = comicArt.title ?? ""
                self.showWebView(url: url, title: title)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == comicArtTableView {
            if viewModel.selectedCategory == 0 { //Anime
                viewModel.contentOffset_y_Anime = scrollView.contentOffset.y
            } else if viewModel.selectedCategory == 1 { //Manga
                viewModel.contentOffset_y_Manga = scrollView.contentOffset.y
            } else { //Favorite
                viewModel.contentOffset_y_Favorite = scrollView.contentOffset.y
            }
        }
    }
    
    //Private functions
    fileprivate func showOptionSelector(optionType: OptionType) {
        let ac: UIAlertController
        
        if viewModel.selectedCategory == 0 { //Anime
            if optionType == .type {
                ac = UIAlertController(title: "Select Anime Type", message: nil, preferredStyle: .actionSheet)
                let options = AnimeType.allCases
                for option in options {
                    let action = UIAlertAction(title: option.rawValue, style: .default) { (_) in
                        self.viewModel.animeType = option
                    }
                    ac.addAction(action)
                }
            } else {
                ac = UIAlertController(title: "Select Anime Filter", message: nil, preferredStyle: .actionSheet)
                let options = AnimeFilter.allCases
                for option in options {
                    let action = UIAlertAction(title: option.rawValue, style: .default) { (_) in
                        self.viewModel.animeFilter = option
                    }
                    ac.addAction(action)
                }
            }
        } else { //Manga
            if optionType == .type {
                ac = UIAlertController(title: "Select Manga Type", message: nil, preferredStyle: .actionSheet)
                let options = MangaType.allCases
                for option in options {
                    let action = UIAlertAction(title: option.rawValue, style: .default) { (_) in
                        self.viewModel.mangaType = option
                    }
                    ac.addAction(action)
                }
            } else {
                ac = UIAlertController(title: "Select Manga Filter", message: nil, preferredStyle: .actionSheet)
                let options = MangaFilter.allCases
                for option in options {
                    let action = UIAlertAction(title: option.rawValue, style: .default) { (_) in
                        self.viewModel.mangaFilter = option
                    }
                    ac.addAction(action)
                }
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancel)
        self.present(ac, animated: true, completion: nil)
    }
    
    fileprivate func showWebView(url: String, title: String) {
        let vc = WebViewController(url: url, title: title)
        let nav = UINavigationController(rootViewController: vc)
        nav.setNavigationBarAppearance(.Opaque)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
}
