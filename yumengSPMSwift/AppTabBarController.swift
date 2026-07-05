import SwiftUI
import UIKit

final class AppTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // tintColor 控制 TabBar 选中项的图标和文字颜色；0x0F766E 是偏青绿色。
        tabBar.tintColor = UIColor(hex: 0x0F766E)
        // barTintColor 控制 TabBar 背景色；这里设置为白色。
        tabBar.barTintColor = .white
        configureBarAppearance()

        // `style: .plain` 表示 UITableViewController 使用普通列表样式；另一种常见样式是 `.grouped` 分组列表。
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

        // SnapKit 页面同样使用普通列表样式。
        let snapKitNav = UINavigationController(rootViewController: SnapKitMarketViewController(style: .plain))
        snapKitNav.tabBarItem = UITabBarItem(title: "SnapKit", image: tabImage("rectangle.grid.1x2"), tag: 3)
        style(navigationController: snapKitNav)

        viewControllers = [swiftNav, ocNav, swiftUINav, snapKitNav]
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
            // 把前面设置的导航栏标题样式同步到 appearance；如果取不到，就用空字典兜底。
            appearance.titleTextAttributes = navigationController.navigationBar.titleTextAttributes ?? [:]
            // standardAppearance：普通状态下的导航栏外观，大多数页面默认使用它。
            navigationController.navigationBar.standardAppearance = appearance
            // scrollEdgeAppearance：滚动视图在顶部边缘时的导航栏外观；不设置可能出现透明或颜色变化。
            navigationController.navigationBar.scrollEdgeAppearance = appearance
            // compactAppearance：紧凑高度场景下的导航栏外观，例如横屏或部分紧凑布局。
            navigationController.navigationBar.compactAppearance = appearance
        }
    }

    private func configureBarAppearance() {
        // iOS 13 开始推荐用 UITabBarAppearance 统一配置 TabBar 外观。
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            // 使用不透明背景，避免 TabBar 默认半透明导致底部内容透出来。
            appearance.configureWithOpaqueBackground()
            // 设置 TabBar 背景为白色。
            appearance.backgroundColor = .white
            // standardAppearance 是普通状态下的 TabBar 外观。
            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                // iOS 15 开始滚动到边缘时会使用 scrollEdgeAppearance；不设置可能出现透明/颜色不一致。
                tabBar.scrollEdgeAppearance = appearance
            }
        }
    }
}
