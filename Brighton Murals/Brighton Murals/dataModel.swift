//
//  dataModel.swift
//  Brighton Murals
//
//  Created by Kevon Rahimi on 05/12/2022.
//

import Foundation

struct Murals: Codable
{
    var newbrighton_murals: [newBrightonMural]
}

struct newBrightonMural: Codable {
    let id: String
    let title: String
    let artist: String?
    let info: String?
    let thumbnail: String?
    let lat: String
    let lon: String
    let enabled: String
    let lastModified:String?
    let images:[Image]?
    var distance: Double?
    var hasFavourited: Bool?
}

struct Image: Codable
{
    let id: String?
    let filename: String?
}
