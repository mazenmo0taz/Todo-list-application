//
//  Categs.swift
//  ToDo-LIST
//
//  Created by mazen moataz on 05/11/2021.
//

import Foundation
import RealmSwift
class Categs: Object{
    @objc dynamic var name : String = ""
    @objc dynamic var colorHex : String?
    let items = List<Items>()
}
