import Foundation
import OSLog

// TODO: Optimize the task grouping and async work here

struct ModelProcessor {

    private let provider: DataProvider
    private let decoder: JSONDecoder
    private let logger = Logger()

    init(provider: DataProvider, decoder: JSONDecoder) {
        self.provider = provider
        self.decoder = decoder
    }

    func populateModels(from data: Data) async -> PokemonContainer {
        var container: PokemonContainer = [:]

        switch DataFetchLocation.choice {
        case .local:
            guard
                let list = try? decoder.decode(PokemonList.self, from: data),
                let item = list.results.first
            else {
                fatalError("Failed to load local resource.")
            }

            let result = await provider.getItemData(item.url)
            switch result {
            case .success(let data):
                if let item = try? decoder.decode(Pokemon.self, from: data) {
                    container[item.id] = item
                }
            case .failure(_):
                logger.log(level: .debug, "Failed to unpack local pokemon data.")
            }

        case .remote:
            if let list = try? decoder.decode(PokemonList.self, from: data) {
                await withTaskGroup(of: Result<Data, DataLoadError>.self) { group in
                    for item in list.results {
                        group.addTask { return await self.provider.getItemData(item.url) } // TODO: self strong-reference
                    }
                    for await result in group {
                        switch result {
                        case .success(let poke):
                            if let item = try? decoder.decode(Pokemon.self, from: poke) {
                                container[item.id] = item
                            }
                        case .failure(_):
                            logger.log(level: .debug, "Failed to unpack remote pokemon data.")
                        }
                    }
                }
            }
        }

        return container
    }
}
