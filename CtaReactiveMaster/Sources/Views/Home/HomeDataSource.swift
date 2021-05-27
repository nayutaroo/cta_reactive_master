//
//  HomeDataSource.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/05/27.
//

import UIKit

final class HomeDataSource: NSObject, UITableViewDataSource {
    typealias Element = [Article]
    private var items: Element = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(NewsTableViewCell.self , indexPath: indexPath)
        cell.rx.longPressGesture()
            .when(.began)
            .subscribe(onNext: { gesture in
                cell.isFavorited.toggle()
            })
            .disposed(by: cell.disposeBag)
        return cell
    }
}
