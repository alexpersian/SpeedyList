//
//  Item.swift
//  SpeedyList
//
//  Created by Alex Persian on 1/21/24.
//

import UIKit

struct Recipe: Identifiable, Codable {
    var id: Int

    let name: String
    let image: String
    let ingredients: String
    let instructions: String

    init(id: Int, name: String, image: String, ingredients: String, instructions: String) {
        self.id = id
        self.name = name
        self.image = image
        self.ingredients = ingredients
        self.instructions = instructions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.image = try container.decode(String.self, forKey: .image)
        self.ingredients = try container.decode([String].self, forKey: .ingredients).joined(separator: "\n")
        self.instructions = try container.decode([String].self, forKey: .instructions).joined(separator: "\n")
    }

    enum CodingKeys: CodingKey {
        case id
        case name
        case image
        case ingredients
        case instructions
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.image, forKey: .image)
        try container.encode(self.ingredients, forKey: .ingredients)
        try container.encode(self.instructions, forKey: .instructions)
    }
}
