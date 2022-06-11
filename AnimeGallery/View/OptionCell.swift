//
//  OptionCell.swift
//  AnimeGallery
//
//  Created by 林宏勳 on 2022/6/10.
//

import UIKit

class OptionCell: UITableViewCell {

    let optionType: OptionType = .type
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupAnimeTypeCell(title: String, value: AnimeType) {
        self.title.text = title
        self.subtitle.text = value.rawValue
    }
    
    func setupAnimeFilterCell(title: String, value: AnimeFilter) {
        self.title.text = title
        self.subtitle.text = value.rawValue
    }
    
    func setupMangaTypeCell(title: String, value: MangaType) {
        self.title.text = title
        self.subtitle.text = value.rawValue
    }
    
    func setupMangaFilterCell(title: String, value: MangaFilter) {
        self.title.text = title
        self.subtitle.text = value.rawValue
    }
}
