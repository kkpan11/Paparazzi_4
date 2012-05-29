//
//  PersonListViewController.h
//  Paparazzi_3
//
//  Created by Peter Wang on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Addressbook/Addressbook.h>
#import <AddressbookUI/AddressbookUI.h>
#import "PersonAddViewController.h"
#import "ContactAddViewController.h"

@class FlickrFetcher;

@interface PersonListViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    FlickrFetcher *flickrFetcher;
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}

@end
