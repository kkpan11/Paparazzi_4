//
//  VirtualKeyboardViewController.h
//  Paparazzi_3
//
//  Created by Peter Wang on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@protocol PersonAddDelegate;

@class Person, FlickrFetcher;

@interface PersonAddViewController : UIViewController <UITextFieldDelegate>
{
    FlickrFetcher *flickrFetcher;
    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *fetchedResultsController;
    @private
        //Person *person;
        //id <PersonAddDelegate> delegate;
        //UITextField *nameTextField;
}

@property(nonatomic, strong) UITextField *nameTextField;
@property(nonatomic, strong) Person *person;
@property(nonatomic, unsafe_unretained) id <PersonAddDelegate> delegate;

- (void)save;
- (void)cancel;

@end

@protocol PersonAddDelegate <NSObject>

- (void)personAddViewController:(PersonAddViewController *)personAddViewController didAddPerson:(Person *)beSavedPerson;

@end