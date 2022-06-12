//
//  ComicArtCell.swift
//  AnimeGallery
//
//  Created by 林宏勳 on 2022/6/10.
//

import UIKit
import Kingfisher

protocol ComicArtCellDelegate: AnyObject {
    func likeButtonClicked(comicArt: ComicArt)
}

class ComicArtCell: UITableViewCell {

    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var pic: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var rankLabel: UILabel!
    
    weak var delegate: ComicArtCellDelegate?
    var comicArt: ComicArt?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(comicArt: ComicArt, isFavorite: Bool) {
        
        self.comicArt = comicArt
        
        let imageUrl = comicArt.imageUrl
        let title = comicArt.title
        let start_date = "Start: " + (comicArt.start_date?.components(separatedBy: "T")[0] ?? "-")
        let end_date = "End: " + (comicArt.end_date?.components(separatedBy: "T")[0] ?? "-")
        let rank = comicArt.rank
        
        self.pic.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage(named: "picture"))
        self.title.text = title
        self.startDateLabel.text = start_date
        self.endDateLabel.text = end_date
        
        if let rank = rank {
            self.rankLabel.text = String(rank)
        } else {
            self.rankLabel.text = ""
        }
        
        if isFavorite {
            self.likeButton.setImage(UIImage(named: "likeSelect"), for: .normal)
        } else {
            self.likeButton.setImage(UIImage(named: "likeUnselect"), for: .normal)
        }
    }
    
    @IBAction func like(_ sender: Any) {
        guard let comicArt = comicArt else { return }
        delegate?.likeButtonClicked(comicArt: comicArt)
    }
}
