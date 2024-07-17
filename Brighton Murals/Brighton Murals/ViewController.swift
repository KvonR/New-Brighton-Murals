//
//  ViewController.swift
//  Brighton Murals
//
//  Created by Kevon Rahimi on 05/12/2022.
//

import UIKit

class ViewController: UIViewController {
    var muralTitle: String?
    var muralArtist: String?
    var muralInfo: String?
    var muralImage: String?
    var baseURL = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/nbm_images/"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = muralTitle
        artistLabel.text = muralArtist
        infoLabel.text = muralInfo
        let urlString = baseURL+muralImage!
        let url = URL(string: urlString)!
                 if let data = try? Data(contentsOf: url) {
                     imageView.image = UIImage(data: data)
                 }
    }


}

