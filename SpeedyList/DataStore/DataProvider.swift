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
    case imageLoadFailure
    case unimplemented
}

protocol DataProvider {
    func getListData() async -> Result<Data, DataLoadError>
    func getItemData(url: String, name: String) async -> Result<Data, DataLoadError>
    func getImageData(url: String) async -> Result<UIImage, DataLoadError>
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

    func getItemData(url: String, name: String) async -> Result<Data, DataLoadError> {
        guard
            let url = Bundle.main.url(forResource: "mock_pokemon_bulbasaur", withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else {
            logger.log(level: .error, "Failed to load item data from remote.")
            return .failure(.unimplemented)
        }
        return .success(data)
    }

    func getImageData(url: String) async -> Result<UIImage, DataLoadError> {
        return .failure(.unimplemented)
    }
}

// MARK: - Remote

final class RemoteDataProvider: DataProvider {
    private let logger = Logger()
    private let session = URLSession.shared

    private let fetchURL: URL = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151&offset=0")!

    private let fileStore = FileStore()
    private let imageCache = ImageCache()

    func getListData() async -> Result<Data, DataLoadError> {
        // check for presence of list file
        if let listData = fileStore.fetchList() {
            // if file exists, load file and populate date object to return
            return .success(listData)
        } else {
            // if file doesn't exist, fetch file from remote
            guard let (data, _) = try? await session.data(from: fetchURL) else {
                logger.log(level: .error, "Failed to load list data from remote.")
                return .failure(.dataLoadFailure)
            }
            // store returned data into local file
            fileStore.storeList(data)
            return .success(data)
        }
    }

    func getItemData(url: String, name: String) async -> Result<Data, DataLoadError> {
        // check for presence of item file
        if let itemData = fileStore.fetchItem(id: name) {
            // if file exists, load file and populate date object to return
            return .success(itemData)
        } else {
            // if file doesn't exist, fetch file from remote
            guard
                let formattedURL = URL(string: url),
                let (data, _) = try? await session.data(from: formattedURL)
            else {
                logger.log(level: .error, "Failed to load item data from remote.")
                return .failure(.dataLoadFailure)
            }
            // store returned data into local file
            fileStore.storeItem(data, id: name)
            return .success(data)
        }
    }

    func getImageData(url: String) async -> Result<UIImage, DataLoadError> {
        // check for presence of image file
        if let image = imageCache.fetchImage(for: url) {
            // if image exists, return it
            return .success(image)
        } else {
            // if image doesn't exist, fetch image from remote
            guard
                let formattedURL = URL(string: url),
                let (data, _) = try? await session.data(from: formattedURL),
                let image = UIImage(data: data)
            else {
                logger.log(level: .error, "Failed to load image data from remote.")
                return .failure(.imageLoadFailure)
            }
            // store returned image into imagecache
            imageCache.storeImage(Asset(id: url, image: image))
            return .success(image)
        }
    }
}
