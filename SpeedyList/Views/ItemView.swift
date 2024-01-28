//
//  ItemView.swift
//  SpeedyList
//
//  Created by Alex Persian on 1/26/24.
//

import SwiftUI

// TODO: Investigate warning in logs: "nw_connection_add_timestamp_locked_on_nw_queue [C2] Hit maximum timestamp count, will start dropping events"

struct ItemView: View {
    let model: Pokemon

    var body: some View {
        VStack(alignment: .leading, content: {
            ItemImageView(model: URL(string: model.imageURL))
            Text(model.name.capitalized).font(.headline)
            Text("Num: " + formatNumber(model.id)).font(.caption)
            Text("Type: " + formatTypes(model.types)).font(.caption)
        })
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
    }

    func formatNumber(_ number: Int) -> String {
        return String(format: "%03d", number)
    }

    func formatTypes(_ types: [PokemonType]) -> String {
        var typeStrings: [String] = []
        types
            .sorted(by: { $0.slot < $1.slot })
            .forEach { typeStrings.append($0.name.capitalized) }
        return typeStrings.joined(separator: ", ")
    }
}

struct ItemImageView: View {
    let model: URL?

    var body: some View {
        AsyncImage(
            url: model,
            scale: 3,
            content: { image in image.resizable() },
            placeholder: { ProgressView() }
        )
        .frame(width: 200, height: 200)
    }
}

#Preview {
    ItemView(model: Pokemon(
        id: 1,
        name: "bulbasaur",
        types: [
            .init(slot: 1, name: "grass"),
            .init(slot: 2, name: "poison"),
        ],
        imageURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png"
    ))
}
