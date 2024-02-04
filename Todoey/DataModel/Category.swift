//
//  Category.swift
//  Todoey
//
//  Created by Ayanesh Sarkar on 04/02/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @Persisted var name: String = ""
    @Persisted var items: List<Item>
}
