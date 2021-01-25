import Foundation
import UIKit

class CarouselPageViewController: UIPageViewController {
    fileprivate var items: [UIViewController] = []
    var currentTutorialPageIndex = NSInteger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        decoratePageControl()
        
        populateItems()
        if let firstViewController = items.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("NextTutorialView"), object: nil)

        
    }
    @objc func methodOfReceivedNotification(notification: Notification) {
        self.MoveToNextPage()
    }

    
    fileprivate func decoratePageControl() {
        let pc = UIPageControl.appearance(whenContainedInInstancesOf: [CarouselPageViewController.self])
        pc.currentPageIndicatorTintColor = UIColor(red: 45.0/255.0, green: 140.0/255.0, blue: 234.0/255.0, alpha: 1.0)
        pc.pageIndicatorTintColor = .gray
    }
    func MoveToNextPage()
    {
//        if let currentViewController = items.first {
//            if let nextPage = dataSource?.pageViewController(self, viewControllerAfter: currentViewController) {
//                setViewControllers([nextPage], direction: .forward, animated: true, completion: nil)
//            }
//        }
        
        self.goToNextPage()

        
//        self.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
    }
    
    fileprivate func populateItems() {
        let text = ["Scan your way to success", "Live shipment updates", "Get notified every step", "Get instantly paid!"]
        let descText = ["Scanning the QR code rewards you and your business", "Know the exact location and status of your shipment", "Receive instant notifications at every goods handover point", "Once the buyer receives the goods, funds are instantly in your account."]

        let imagesNamestext = ["tutorialImage1", "tutorialImage2", "tutorialImage3", "tutorialImage4"]

        let backgroundColor:[UIColor] = [.white, .white, .white, .white]
        
        for (index, t) in text.enumerated() {
            let c = createCarouselItemControler(with: t, with: backgroundColor[index], imageName: imagesNamestext[index], descText: descText[index])
            items.append(c)
        }
    }
    
    fileprivate func createCarouselItemControler(with titleText: String?, with color: UIColor?, imageName: String?, descText: String?) -> UIViewController {
        let c = UIViewController()
        c.view = CarouselItem(titleText: titleText, background: color, imageName: imageName, descText: descText)

        return c
    }
}

// MARK: - DataSource

extension CarouselPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = items.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return items.last
        }
        
        guard items.count > previousIndex else {
            return nil
        }
        currentTutorialPageIndex = previousIndex

        return items[previousIndex]
    }
    
    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = items.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        guard items.count != nextIndex else {
            return items.first
        }
        
        guard items.count > nextIndex else {
            return nil
        }
        
        currentTutorialPageIndex = nextIndex
        return items[nextIndex]
    }
    
    func presentationCount(for _: UIPageViewController) -> Int {
        return items.count
    }
    
    func presentationIndex(for _: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = items.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
}
extension UIPageViewController {
    func goToNextPage(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        if let currentViewController = viewControllers?[0] {
            if let nextPage = dataSource?.pageViewController(self, viewControllerAfter: currentViewController) {
                setViewControllers([nextPage], direction: .forward, animated: animated, completion: completion)
            }
        }
    }
}
