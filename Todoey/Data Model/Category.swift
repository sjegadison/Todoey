//
//  Category.swift
//  Todoey
//
//  Created by Sivaguru Jegadison on 2/27/19.
//  Copyright © 2019 Sivaguru Jegadison. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
