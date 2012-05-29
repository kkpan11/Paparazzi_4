//
//  AppDelegate.h
//  Paparazzi4
//
//  Created by  on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlickrFetcher, PersonListViewController, RecentsViewController, MapViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>
{
    UITabBarController *tabBarController;
    UINavigationController *navContactsController;
    UINavigationController *navRecentsController;
    UINavigationController *navMapController;
    FlickrFetcher *flickrFetcher;
    NSManagedObjectContext *managedObjectContext;
    PersonListViewController *personListViewController;
    RecentsViewController *recentsViewController;
    MapViewController *mapViewController;
}

@property (strong, nonatomic) UIWindow *window;

@end
