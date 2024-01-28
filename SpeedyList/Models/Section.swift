//
//  Item.swift
//  SpeedyList
//
//  Created by Alex Persian on 1/21/24.
//

import UIKit

struct Section: Identifiable {
    enum Identifier: Int {
        case main = 0
    }

    var id: Identifier
    var items: [Pokemon]
}
