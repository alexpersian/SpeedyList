import Foundation
import OSLog

final class FileStore {
    
    private let fileManager: FileManager
    private let logger = Logger()

    private var documentsURL: URL!
    private var pokemonListURL: URL!
    private var pokemonItemsURL: URL!

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        setupFileStore()
    }

    private func setupFileStore() {
        documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        pokemonListURL = documentsURL.appending(path: "pokemon_list")
        pokemonItemsURL = documentsURL.appending(path: "pokemon_items")

        do {
            try fileManager.createDirectory(at: pokemonListURL, withIntermediateDirectories: true)
            try fileManager.createDirectory(at: pokemonItemsURL, withIntermediateDirectories: true)
        } catch {
            logger.log(level: .error, "Error when initalizing file store: \(error)")
        }
    }

    // MARK: - Storing

    func storeList(_ data: Data) {
        let url = pokemonListURL.appending(path: "list.json")
        do {
            try data.write(to: url)
        } catch {
            logger.log(level: .error, "Failed to write list file: \(error)")
        }
    }

    func storeItem(_ data: Data, id: String) {
        let url = pokemonItemsURL.appending(path: "\(id).json")
        do {
            try data.write(to: url)
        } catch {
            logger.log(level: .error, "Failed to write item file: \(error)")
        }
    }

    // MARK: - Fetching

    func fetchList() -> Data? {
        let url = pokemonListURL.appending(path: "list.json")
        do {
            return try Data(contentsOf: url)
        } catch {
            logger.log(level: .error, "Failed to retrieve list file: \(error)")
            return nil
        }
    }

    func fetchItem(id: String) -> Data? {
        let url = pokemonItemsURL.appending(path: "\(id).json")
        do {
            return try Data(contentsOf: url)
        } catch {
            logger.log(level: .error, "Failed to retrieve item file: \(error)")
            return nil
        }
    }
}
