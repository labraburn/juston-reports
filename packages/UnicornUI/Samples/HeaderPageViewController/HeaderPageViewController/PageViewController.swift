//
//  PageViewController.swift
//  HeaderPageViewController
//
//  Created by Anton Spivak on 10.12.2021.
//

import UIKit
import UnicornUI

class PageViewController: HeaderPageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        setViewControllers([TableViewController()], direction: .forward, animated: false, completion: nil)
    }
}

extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        TableViewController()
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        TableViewController()
    }
}
