//
//  RecentsViewController.h
//  Paparazzi_3
//
//  Created by Peter Wang on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef NSNumber *NSNumberBool;


@class FlickrFetcher, MapViewController;

@interface RecentsViewController : UITableViewController
{
    BOOL canBePinned, isFetchedDone;
    NSLock *fetchLock;
    FlickrFetcher *flickrFetcher;
    NSManagedObjectContext *context;
    NSArray *recentPhotosDescriptions;
    //NSThread *fetchThread;
    //NSMutableArray *photos;
    UIActivityIndicatorView *activityIndicator;
}

//+ (BOOL)canBePinned;
//+ (void)setCanBePinned:(BOOL)canBePinned;
+ (NSArray *)photos;

@property (nonatomic, strong) MapViewController *mapViewController;

@end
