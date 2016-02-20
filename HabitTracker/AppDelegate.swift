//
//  AppDelegate.swift
//  HabitTracker
//
//  Created by Logan Allen on 1/17/16.
//  Copyright © 2016 Logan Allen. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var dataController: DataController!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Set up Core Data.
        dataController = DataController()

        // Basic UI initialization
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self

        // Override point for customization after application launch.
        if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))) {
            // let notificationCategory:UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
            // notificationCategory.identifier = "TRIGGER_CATEGORY"
            // notificationCategory .setActions([replyAction], forContext: UIUserNotificationActionContext.Default)

            // registering for the notification.
            application.registerUserNotificationSettings(
                UIUserNotificationSettings(forTypes:[.Sound, .Alert, .Badge], categories: nil)
            )
        } else {
            print("SOMETHING IS FUCKED UP")
        }

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    // MARK: - Local Notifications

    func application(application: UIApplication,
        didReceiveLocalNotification notification: UILocalNotification) {
            // this means it is time for the user to add an entry today, and they haven't yet
            // applicationIconBadgeNumber = number of habits with needAction as true

            if let userInfo = notification.userInfo, let habitURI = userInfo["habit"] as? NSURL {
                if let habitObjectID = dataController.managedObjectContext.persistentStoreCoordinator?
                    .managedObjectIDForURIRepresentation(habitURI) {

                        dataController.setHabitNeedsAction(habitObjectID)
                        self.setIconBadgeNumber()

                }
            }
    }

    func setIconBadgeNumber() {
        // iterate through habits and set applicationIconBadgeNumber
        // TODO: Don't just iterate the number!
        let app = UIApplication.sharedApplication()
        var appIconBadgeNumber = 0
        dataController.fetchAllHabits { habits in
            habits?.forEach { habit in
                appIconBadgeNumber = appIconBadgeNumber + Int(habit.needsAction)
            }
            app.applicationIconBadgeNumber = appIconBadgeNumber
        }
    }

    func application(application: UIApplication,
        handleActionWithIdentifier identifier: String?,
        forLocalNotification notification: UILocalNotification,
        completionHandler: () -> Void) {
            // this is for custom actions

    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? HabitDetailViewController else { return false }
        if topAsDetailController.habit == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }


    // MARK: - iCloud
    // This handles the updates to the data via iCloud updates

    func registerCoordinatorForStoreNotifications(coordinator : NSPersistentStoreCoordinator) {
        let nc : NSNotificationCenter = NSNotificationCenter.defaultCenter();

        nc.addObserver(self, selector: "handleStoresWillChange:",
            name: NSPersistentStoreCoordinatorStoresWillChangeNotification,
            object: coordinator)

        nc.addObserver(self, selector: "handleStoresDidChange:",
            name: NSPersistentStoreCoordinatorStoresDidChangeNotification,
            object: coordinator)

        nc.addObserver(self, selector: "handleStoresWillRemove:",
            name: NSPersistentStoreCoordinatorWillRemoveStoreNotification,
            object: coordinator)

        nc.addObserver(self, selector: "handleStoreChangedUbiquitousContent:",
            name: NSPersistentStoreDidImportUbiquitousContentChangesNotification,
            object: coordinator)
    }

    func handleStoresWillChange(notification: NSNotification) {
        print("will change")
        // will change occurs when iCloud is first set up, and when an account transition happens. each should be handled differently, based on userInfo in notification

        if (notification.userInfo?.indexForKey(NSAddedPersistentStoresKey) != nil) {
            // iCloud first time setup
            dataController.managedObjectContext.performBlock {
                self.dataController.managedObjectContext.reset()
            }
        } else if (notification.userInfo?.indexForKey(NSPersistentStoreUbiquitousTransitionTypeKey) != nil) {
            // iCloud account transition
            dataController.managedObjectContext.performBlock {
                self.dataController.managedObjectContext.reset()
            }
            // disable UI
            // basically go back to onboarding screen?
        }
        print(notification)
    }

    func handleStoresDidChange(notification: NSNotification) {
        print("did change")
        dataController.managedObjectContext.performBlock {
            self.dataController.managedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
            NotificationController.resetLocalNotifications(self.dataController)
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.fetchTableData, object: nil)
            
        }
        print(notification)
    }

    func handleStoresWillRemove(notification: NSNotification) {
        print("will remove")
        print(notification)
        NotificationController.cancelLocalNotifications()
    }

    func handleStoreChangedUbiquitousContent(notification: NSNotification) {
        print("changed ubiquitous content")
        dataController.managedObjectContext.performBlock {
            // decide whether to merge in memory or just refetch
            self.dataController.managedObjectContext.mergeChangesFromContextDidSaveNotification(notification) // merge in memory
            NotificationController.resetLocalNotifications(self.dataController)
        }
        print(notification)
    }

}

