import Foundation
import OSLog

// TODO: Optimize the task grouping and async work here
// TODO: This probably shouldn't be obfuscating the remote request

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

            let result = await provider.getItemData(url: item.url, name: item.name)
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
                        // TODO: self strong-reference
                        group.addTask { return await self.provider.getItemData(url: item.url, name: item.name) }
                    }
                    for await result in group {
                        switch result {
                        case .success(let poke):
                            if let item = try? decoder.decode(Pokemon.self, from: poke) {

                                // Very inefficient use of in-memory image cache.
                                // Results in block until all images are downloaded.
                                // Was an experiment since AsyncImage doesn't handle offline
                                // out of the box.
//                                let image = await provider.getImageData(url: item.imageURL)
//                                switch image {
//                                case .success(let image):
//                                    var copy = item
//                                    copy.image = image
//                                    container[item.id] = copy
//                                case .failure(_):
//                                    container[item.id] = item
//                                }

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
