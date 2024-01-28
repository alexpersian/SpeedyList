//
//  DataProvider.swift
//  SpeedyList
//
//  Created by Alex Persian on 1/22/24.
//

import Foundation
import OSLog
import UIKit

enum DataFetchLocation {
    case local
    case remote

    static let choice: DataFetchLocation = .remote
}

enum DataLoadError: Error {
    case dataLoadFailure
    case unimplemented
}

protocol DataProvider {
    func getListData() async -> Result<Data, DataLoadError>
    func getItemData(_ url: String) async -> Result<Data, DataLoadError>
}

// MARK: - Local

final class LocalDataProvider: DataProvider {
    private let logger = Logger()

    func getListData() async -> Result<Data, DataLoadError> {
        guard
            let url = Bundle.main.url(forResource: "mock_pokemon_list", withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else {
            logger.log(level: .error, "Failed to load data from file.")
            return .failure(.dataLoadFailure)
        }
        return .success(data)
    }

    func getItemData(_ url: String) async -> Result<Data, DataLoadError> {
        guard
            let url = Bundle.main.url(forResource: "mock_pokemon_bulbasaur", withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else {
            logger.log(level: .error, "Failed to load item data from remote.")
            return .failure(.unimplemented)
        }
        return .success(data)
    }
}

// MARK: - Remote

final class RemoteDataProvider: DataProvider {
    private let logger = Logger()
    private let session = URLSession.shared

    private let fetchURL: URL = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151&offset=0")!

    func getListData() async -> Result<Data, DataLoadError> {
        guard let (data, _) = try? await session.data(from: fetchURL) else {
            logger.log(level: .error, "Failed to load list data from remote.")
            return .failure(.dataLoadFailure)
        }
        return .success(data)
    }

    func getItemData(_ url: String) async -> Result<Data, DataLoadError> {
        guard
            let formattedURL = URL(string: url),
            let (data, _) = try? await session.data(from: formattedURL)
        else {
            logger.log(level: .error, "Failed to load item data from remote.")
            return .failure(.unimplemented)
        }
        return .success(data)
    }
}
