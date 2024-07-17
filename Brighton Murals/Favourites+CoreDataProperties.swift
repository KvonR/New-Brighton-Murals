//
//  Favourites+CoreDataProperties.swift
//  Brighton Murals
//
//  Created by Kevon Rahimi on 12/12/2022.
//
//

import Foundation
import CoreData


extension Favourites {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favourites> {
        return NSFetchRequest<Favourites>(entityName: "Favourites")
    }

    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var artist: String?
    @NSManaged public var info: String?
    @NSManaged public var hasFavourited: Bool

}
