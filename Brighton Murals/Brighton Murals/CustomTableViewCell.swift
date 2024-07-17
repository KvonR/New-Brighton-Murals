//
//  CustomTableViewCell.swift
//  Brighton Murals
//
//  Created by Kevon Rahimi on 12/12/2022.
//

import UIKit
class CustomTableViewCell: UITableViewCell {

    var link: MuralTVC?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Setup of button
        let favButton = UIButton(type: .system)
        favButton.setImage(UIImage(named: "filledStar.png"), for: .normal)
        favButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        favButton.tintColor = .yellow
        favButton.addTarget(self, action: #selector(handleMarkAsFavourite), for: .touchUpInside)

        accessoryView = favButton
    }
    

// Link to MuralTVC
    @objc func handleMarkAsFavourite(){
        link?.linkMethod(cell: self)
    }
    
// For the layout of the cell
    override func layoutSubviews() {
        super.layoutSubviews()
        // Customize imageView like you need
        self.imageView?.frame = CGRectMake(10,0,45,45)
        self.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        // Customize other elements
        self.textLabel?.frame = CGRectMake(60, 0, self.frame.width - 45, 20)
        self.detailTextLabel?.frame = CGRectMake(60, 20, self.frame.width - 45, 15)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
