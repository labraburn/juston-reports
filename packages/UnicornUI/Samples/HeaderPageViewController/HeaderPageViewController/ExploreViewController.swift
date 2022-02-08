//
//  ExploreViewController.swift
//  HeaderPageViewController
//
//  Created by Anton Spivak on 10.12.2021.
//

import UIKit
import UnicornUI

class ExploreViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Explore"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        100
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let headerViewController = HeaderViewController()

        let pageViewController = PageViewController(navigationOrientation: .horizontal, options: nil)
        pageViewController.setHeaderViewController(
            headerViewController,
            with: .bottomStretchable(pinTopSafeArea: false)
        )

        navigationController?.pushViewController(pageViewController, animated: true)
    }
}
