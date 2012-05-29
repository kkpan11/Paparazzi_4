//
//  ContactAddViewController.h
//  Paparazzi_4
//
//  Created by  on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonAddViewController.h"

@class FlickrFetcher, Person;

@interface ContactAddViewController : UITableViewController <PersonAddDelegate, ABPersonViewControllerDelegate, ABUnknownPersonViewControllerDelegate>
{
    //FlickrFetcher *flickrFetcher;
    NSManagedObjectContext *managedObjectContext;
    UITableViewCell *cell1, *cell2, *cell3;
    UIButton *btnAddressBookLink, *btnEstablishedAddressBookLink;
    ABRecordRef personRecord;
    ABAddressBookRef addressBook;
}

@property (nonatomic, strong) Person *person;

- (void)setManagedObjectContext:(NSManagedObjectContext *)_managedObjectContext;

@end