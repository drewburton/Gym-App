import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        configureAppearance()
    }

    private func setupTabs() {
        // In a real AppCoordinator pattern, these would be initialized by coordinators
        // For now, we'll create placeholder view controllers as per Task 2.1.1
        
        let homeVC = createNav(
            with: HomeViewController(),
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        let exercisesVC = createNav(
            with: ExercisesListViewController(),
            title: "Exercises",
            image: UIImage(systemName: "dumbbell"),
            selectedImage: UIImage(systemName: "dumbbell.fill")
        )
        
        let templatesVC = createNav(
            with: TemplatesListViewController(),
            title: "Templates",
            image: UIImage(systemName: "doc.text"),
            selectedImage: UIImage(systemName: "doc.text.fill")
        )
        
        let historyVC = createNav(
            with: HistoryListViewController(),
            title: "History",
            image: UIImage(systemName: "clock"),
            selectedImage: UIImage(systemName: "clock.fill")
        )
        
        self.setViewControllers([homeVC, exercisesVC, templatesVC, historyVC], animated: false)
    }

    private func createNav(
        with rootVC: UIViewController,
        title: String,
        image: UIImage?,
        selectedImage: UIImage?
    ) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootVC)
        nav.tabBarItem.title = title
        nav.tabBarItem.image = image
        nav.tabBarItem.selectedImage = selectedImage
        rootVC.navigationItem.title = title
        nav.navigationBar.prefersLargeTitles = true
        return nav
    }

    private func configureAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        
        tabBar.standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = tabBarAppearance
        }
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        
        tabBar.tintColor = .systemBlue
    }
}
