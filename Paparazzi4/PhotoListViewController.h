//
//  PhotoListViewController.h
//  Paparazzi_3
//
//  Created by Peter Wang on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlickrFetcher;
@class Person;

@interface PhotoListViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    BOOL isFetchedDone;
    NSLock *fetchLock;
    FlickrFetcher *flickrFetcher;
    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *fetchedResultsController;
    NSArray *arrayPhotos;
    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, strong) Person *person;
//@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
