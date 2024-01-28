//
//  DataStore.swift
//  SpeedyList
//
//  Created by Alex Persian on 1/22/24.
//

import Foundation
import OSLog

// TODO: DataStore should work with CoreData or NSCache
// TODO: This should handle generic models
// TODO: Potential for race conditions here with multi-threaded access

final class DataStore {

    private let provider: DataProvider
    private let processor: ModelProcessor
    private let logger = Logger()

    private var container: PokemonContainer = [:]

    init(provider: DataProvider, processor: ModelProcessor) {
        self.provider = provider
        self.processor = processor
    }

    func loadData() async {
        let data = await provider.getListData()
        switch data {
        case .success(let data):
            logger.log(level: .info, "Data retrieval successful.")
            container = await processor.populateModels(from: data)
        case .failure(_):
            logger.log(level: .error, "Data retrieval failure.")
        }
    }

    func fetchModel(byId id: Pokemon.ID) -> Pokemon? {
        return container[id]
    }

    func allData() -> PokemonContainer {
        return container
    }
}
