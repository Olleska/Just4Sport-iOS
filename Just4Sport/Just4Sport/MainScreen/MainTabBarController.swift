import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupTabBar()
    }
    
    private func setupTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "colorTabBarBackground")
        
        let inactiveColor = UIColor(named: "colorTabBarIcon")
        appearance.stackedLayoutAppearance.normal.iconColor = inactiveColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor:inactiveColor as Any,
            .font: UIFont.Regular.footnote as Any
        ]
        
        let activeColor = UIColor(named: "redColor")
        appearance.stackedLayoutAppearance.selected.iconColor = activeColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: activeColor as Any,
            .font: UIFont.Regular.footnote as Any
        ]
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        let mainVC = MainViewController()
        let mainNavController = UINavigationController(rootViewController: mainVC)
        mainNavController.tabBarItem = UITabBarItem(
            title: "Главная",
            image: UIImage(named: "mainTabBar"),
            selectedImage: UIImage(named: "mainTabBar")
        )
        
        let createVC = CreateViewController()
        createVC.tabBarItem = UITabBarItem(
            title: "Создать",
            image: UIImage(named: "createTabBar"),
            selectedImage: UIImage(named: "createTabBar")
        )
        
        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(
            title: "Профиль",
            image: UIImage(named: "profileTabBar"),
            selectedImage: UIImage(named: "profileTabBar")
        )
        
        let imageInsets = UIEdgeInsets(top: 3, left: 0, bottom: -3, right: 0)
        let allItems = [mainNavController.tabBarItem, createVC.tabBarItem, profileVC.tabBarItem]
        allItems.forEach { item in
            item!.imageInsets = imageInsets
        }
        
        viewControllers = [mainNavController, createVC, profileVC]
    }
}
