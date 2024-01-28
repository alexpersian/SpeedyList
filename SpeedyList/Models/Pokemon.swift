//
//  Pokemon.swift
//  SpeedyList
//
//  Created by Alex Persian on 1/21/24.
//

import Foundation
import UIKit

// TODO: These models are real messy to handle Codable. See if there's a better way.

typealias PokemonContainer = [Pokemon.ID: Pokemon]

struct Pokemon: Codable, Identifiable {
    let id: Int
    let name: String
    let types: [PokemonType]
    let imageURL: String

    enum CodingKeys: CodingKey {
        case id
        case name
        case types
        case sprites
    }

    enum ImageKeys: String, CodingKey {
        case other
        case officialArtwork = "official-artwork"
        case frontDefault = "front_default"
    }

    init(id: Int, name: String, types: [PokemonType], imageURL: String) {
        self.id = id
        self.name = name
        self.types = types
        self.imageURL = imageURL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let imageContainer = try container
            .nestedContainer(keyedBy: ImageKeys.self, forKey: .sprites)
            .nestedContainer(keyedBy: ImageKeys.self, forKey: .other)
            .nestedContainer(keyedBy: ImageKeys.self, forKey: .officialArtwork)

        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.types = try container.decode([PokemonType].self, forKey: .types)
        self.imageURL = try imageContainer.decode(String.self, forKey: .frontDefault)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var spritesContainer = container.nestedContainer(keyedBy: ImageKeys.self, forKey: .sprites)
        var otherContainer = spritesContainer.nestedContainer(keyedBy: ImageKeys.self, forKey: .other)
        var artworkContainer = otherContainer.nestedContainer(keyedBy: ImageKeys.self, forKey: .officialArtwork)

        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.types, forKey: .types)
        try artworkContainer.encode(self.imageURL, forKey: .frontDefault)
    }
}

struct PokemonType: Codable, Hashable {
    let slot: Int
    let name: String

    enum OuterKeys: String, CodingKey {
        case slot
        case type
    }

    enum InnerKeys: String, CodingKey {
        case name
        case url
    }

    init(slot: Int, name: String) {
        self.slot = slot
        self.name = name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OuterKeys.self)
        let inner = try container.nestedContainer(keyedBy: InnerKeys.self, forKey: .type)

        self.slot = try container.decode(Int.self, forKey: .slot)
        self.name = try inner.decode(String.self, forKey: .name)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: OuterKeys.self)
        var inner = container.nestedContainer(keyedBy: InnerKeys.self, forKey: .type)

        try container.encode(self.slot, forKey: .slot)
        try inner.encode(self.name, forKey: .name)
    }
}

struct PokemonList: Codable {
    let results: [PokemonLookup]
}

struct PokemonLookup: Codable, Hashable {
    let name: String
    let url: String
}
