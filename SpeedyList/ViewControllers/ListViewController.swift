//
//  ViewController.swift
//  SpeedyList
//
//  Created by Alex Persian on 1/20/24.
//

import UIKit
import SwiftUI

class ListViewController: UIViewController {

    private let dataStore: DataStore

    private var listView: ItemListView!
    private var listDataSource: UICollectionViewDiffableDataSource<Section.ID, Pokemon.ID>!

    init(dataStore: DataStore) {
        self.dataStore = dataStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureDataSource()
        
        // TODO: This should be better regulated
        Task {
            await dataStore.loadData()
            await reloadList()
        }
    }

    private func setupView() {
        listView = ItemListView(frame: view.bounds)
        view = listView
    }

    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Pokemon> { cell, indexPath, item in
            let config = UIHostingConfiguration { ItemView(model: item) }
            cell.contentConfiguration = config
        }

        listDataSource = UICollectionViewDiffableDataSource(
            collectionView: listView.list
        ) { collectionView, indexPath, itemIdentifier -> UICollectionViewCell in
            let item = self.dataStore.fetchModel(byId: itemIdentifier)
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }

    private func reloadList() async {
        let itemIDs = dataStore.allData()
            .sorted { p1, p2 in p1.value.id < p2.value.id }
            .map { $0.key }

        var snapshot = NSDiffableDataSourceSnapshot<Section.ID, Pokemon.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(itemIDs)
        await listDataSource.applySnapshotUsingReloadData(snapshot)
    }
}
