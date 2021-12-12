//
//  Items.swift
//  ToDo-LIST
//
//  Created by mazen moataz on 05/11/2021.
//

import Foundation
import RealmSwift
class Items: Object{
    @objc dynamic var done : Bool = false
    @objc dynamic var title : String?
    @objc dynamic var dateCreated: Date?
    var parentCateg = LinkingObjects(fromType:Categs.self , property: "items")
}
