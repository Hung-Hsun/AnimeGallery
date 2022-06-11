//
//  CategoryCell.swift
//  AnimeGallery
//
//  Created by 林宏勳 on 2022/6/10.
//

import UIKit

class CategoryCell: UICollectionViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupCell(title: String, isSelected: Bool) {
        self.title.text = title
        
        //Select status
        if isSelected {
            self.title.textColor = UIColor.white
            self.backView.backgroundColor = UIColor(red: 50/255, green: 156/255, blue: 255/255, alpha: 1)
            self.backView.layer.borderWidth = 1
            self.backView.layer.borderColor = UIColor.clear.cgColor
        } else {
            self.title.textColor = UIColor.black
            self.backView.backgroundColor = UIColor.clear
            self.backView.layer.borderWidth = 1
            self.backView.layer.borderColor = UIColor.black.cgColor
        }
    }
}
