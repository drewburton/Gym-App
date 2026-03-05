import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private var window: UIWindow
    private var mainTabBarController: MainTabBarController?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let tabBarController = MainTabBarController()
        self.mainTabBarController = tabBarController
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
