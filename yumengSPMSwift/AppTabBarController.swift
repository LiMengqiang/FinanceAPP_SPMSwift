import SwiftUI
import UIKit

final class AppTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor(hex: 0x0F766E)
        tabBar.barTintColor = .white
        configureBarAppearance()

        let swiftNav = UINavigationController(rootViewController: SwiftMarketViewController(style: .plain))
        swiftNav.tabBarItem = UITabBarItem(title: "Swift", image: tabImage("swift"), tag: 0)
        style(navigationController: swiftNav)

        let ocNav = UINavigationController(rootViewController: OCMarketViewController(style: .plain))
        ocNav.tabBarItem = UITabBarItem(title: "OC", image: tabImage("list.bullet"), tag: 1)
        style(navigationController: ocNav)

        let swiftUIViewController = UIHostingController(rootView: SwiftUIMarketView())
        let swiftUINav = UINavigationController(rootViewController: swiftUIViewController)
        swiftUINav.tabBarItem = UITabBarItem(title: "SwiftUI", image: tabImage("chart.bar"), tag: 2)
        style(navigationController: swiftUINav)

        viewControllers = [swiftNav, ocNav, swiftUINav]
    }

    private func tabImage(_ name: String) -> UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: name)
        }
        return nil
    }

    private func style(navigationController: UINavigationController) {
        navigationController.navigationBar.tintColor = UIColor(hex: 0x0F766E)
        navigationController.navigationBar.barTintColor = .white
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor(hex: 0x111827),
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.shadowColor = .clear
            appearance.titleTextAttributes = navigationController.navigationBar.titleTextAttributes ?? [:]
            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance
            navigationController.navigationBar.compactAppearance = appearance
        }
    }

    private func configureBarAppearance() {
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        }
    }
}
