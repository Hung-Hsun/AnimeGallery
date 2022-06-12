//
//  ComicArt.swift
//  AnimeGallery
//
//  Created by 林宏勳 on 2022/6/10.
//

import UIKit

class ComicArt: NSObject, NSCoding {
    
    var malID: Int?
    var url: String?
    var imageUrl: String?
    var smallImageUrl: String?
    var largeImageUrl: String?
    var title: String?
    var rank: Int?
    var start_date: String?
    var end_date: String?
    
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        self.malID = aDecoder.decodeInteger(forKey: "malID")
        self.url = aDecoder.decodeObject(forKey: "url") as? String
        self.imageUrl = aDecoder.decodeObject(forKey: "imageUrl") as? String
        self.smallImageUrl = aDecoder.decodeObject(forKey: "smallImageUrl") as? String
        self.largeImageUrl = aDecoder.decodeObject(forKey: "largeImageUrl") as? String
        self.title = aDecoder.decodeObject(forKey: "title") as? String
        self.rank = aDecoder.decodeInteger(forKey: "rank")
        self.start_date = aDecoder.decodeObject(forKey: "start_date") as? String
        self.end_date = aDecoder.decodeObject(forKey: "end_date") as? String
    }

    func encode(with coder: NSCoder) {
        let malID = malID ?? 0
        let url = url ?? ""
        let imageUrl = imageUrl ?? ""
        let smallImageUrl = smallImageUrl ?? ""
        let largeImageUrl = largeImageUrl ?? ""
        let title = title ?? ""
        let rank = rank ?? 0
        let start_date = start_date ?? ""
        let end_date = end_date ?? ""
        
        coder.encode(malID, forKey: "malID")
        coder.encode(url, forKey: "url")
        coder.encode(imageUrl, forKey: "imageUrl")
        coder.encode(smallImageUrl, forKey: "smallImageUrl")
        coder.encode(largeImageUrl, forKey: "largeImageUrl")
        coder.encode(title, forKey: "title")
        coder.encode(rank, forKey: "rank")
        coder.encode(start_date, forKey: "start_date")
        coder.encode(end_date, forKey: "end_date")
    }
}
