//
//  ListView.swift
//  SpeedyList
//
//  Created by Alex Persian on 1/21/24.
//

import UIKit

final class ItemListView: UIView {
    private(set) lazy var list: UICollectionView = {
        return UICollectionView(
            frame: self.frame,
            collectionViewLayout: createLayout()
        )
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureLayout() {
        list.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        list.backgroundColor = .systemBackground
        addSubview(list)
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout() { index, environment in
            // include any custom layout for different sections required
            let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)
            return section
        }
        return layout
    }
}
