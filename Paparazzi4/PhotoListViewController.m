//
//  PhotoListViewController.m
//  Paparazzi_3
//
//  Created by Peter Wang on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoListViewController.h"
#import "PhotoDetailViewController.h"
#import "FlickrFetcher.h"
#import "Person.h"
#import "Photo.h"

@implementation PhotoListViewController

@synthesize person = _person;
//@synthesize fetchedResultsController = _fetchedResultsController;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        flickrFetcher = [FlickrFetcher sharedInstance];
        managedObjectContext = [flickrFetcher managedObjectContext];
        fetchLock = [[NSLock alloc] init];
        isFetchedDone = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    /*
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:managedObjectContext];
    request.entity = entity;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"person=%@", self.person];
    [request setPredicate:predicate];
    
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    
    [request release];
    [sortDescriptor release];
    [sortDescriptors release];
    */
    
    /*
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(150,180,20,10);
    //activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:activityIndicator];
     */
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"person=%@", self.person];
    fetchedResultsController = [flickrFetcher fetchedResultsControllerForEntity:@"Photo" withPredicate:predicate];
    fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    UIBarButtonItem *fetchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(fetch)];
    self.navigationItem.rightBarButtonItem = fetchButton;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (void)fetch
{
    if (isFetchedDone) {
        //[self.tableView reloadData];
        for (Photo *photo in [fetchedResultsController fetchedObjects]) {
            [managedObjectContext deleteObject:photo];
        }
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        //[self.tableView reloadData];
        NSThread *fetchThread = [[NSThread alloc] initWithTarget:self selector:@selector(fetchPhotosForUser) object:nil];
        [fetchThread start];
    }
}

- (void)fetchPhotosForUser
{
    [fetchLock lock];
    if (!isFetchedDone) {
        return;
    }
    isFetchedDone = NO;
    [fetchLock unlock];
    
    // only one thread can run into the method.
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(150,180,20,10);
    [self.view addSubview:activityIndicator];
    activityIndicator.hidden = NO;
    [activityIndicator startAnimating];
    
    NSLog(@"Befor Fetch and Before Remove: %d", [self.person.photos count]);
    for (Photo *photo in self.person.photos) {
        [managedObjectContext deleteObject:photo];
        NSLog(@"delete : %@", photo);
    }
    [self.person removePhotos:self.person.photos];
    NSLog(@"Before Fetch and After Remove : %d", [self.person.photos count]);
    
    NSArray *photos = [flickrFetcher photosForUser:self.person.name];
    NSLog(@"%@", photos);
    
    //    Photo.
    //
    //    farm = 8;
    //    id = 6855463591;
    //    isfamily = 0;
    //    isfriend = 0;
    //    ispublic = 1;
    //    owner = "29101436@N07";
    //    secret = 12f25f4201;
    //    server = 7197;
    //    title = "Flickr API Test_Shot by iMac";
    
    //    Coordinates.
    //
    //    accuracy = 2;
    //    context = 0;
    //    country =     {
    //        "_content" = Taiwan;
    //        "place_id" = FnYzsLVTUb7w3bcfIg;
    //        woeid = 23424971;
    //    };
    //    latitude = "23.59975";
    //    longitude = "121.023811";
    //    "place_id" = 0xv9LNxTUroQrYAIvA;
    //    region =     {
    //        "_content" = "Kaohsiung City";
    //        "place_id" = 0xv9LNxTUroQrYAIvA;
    //        woeid = 20070334;
    //    };
    //    woeid = 20070334;
    
    for (NSDictionary *item in photos) {
        Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:self.person.managedObjectContext];
        NSData *data = [flickrFetcher dataForPhotoID:[item objectForKey:@"id"]  fromFarm:[item objectForKey:@"farm"] onServer:[item objectForKey:@"server"] withSecret:[item objectForKey:@"secret"] inFormat:FlickrFetcherPhotoFormatLarge]; // inFormat:FlickrFetcherPhotoFormatSquare
        
        photo.image = [UIImage imageWithData:data];
        photo.name = [item objectForKey:@"title"];
        
        //int photoID = [[item objectForKey:@"id"] intValue];
        //photo.photoID = [NSNumber numberWithInt:photoID];
        
        NSDictionary *coordinates = [flickrFetcher locationForPhotoID:[item objectForKey:@"id"]];
        //NSLog(@"%@", coordinates);
        if (coordinates) {
            photo.latitude = [coordinates objectForKey:@"latitude"];
            photo.longitude = [coordinates objectForKey:@"longitude"];
        }
        NSLog(@"latitude :%@ | longitude :%@", photo.latitude, photo.longitude);
        
        photo.person = self.person;
        [self.person addPhotosObject:photo];
        //NSLog(@"%@", photo.person);
    }
    
    if ([managedObjectContext hasChanges]) {
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        if (![fetchedResultsController performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    NSLog(@"[self.person.photos count] : %d", [self.person.photos count]);
    NSLog(@"===Done===");
    
    //[self.tableView reloadData];
    
    [activityIndicator stopAnimating];
    [activityIndicator removeFromSuperview];
    
    isFetchedDone = YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSLog(@"%@", sectionInfo.numberOfObjects); // null
    return sectionInfo.numberOfObjects;
    */
    NSInteger numberOfRows = 0;
	
    if ([[fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    Photo *photo = [fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.name;
    cell.imageView.image = photo.image;
    cell.detailTextLabel.text = photo.person.name;
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
     */
    
    // Delete NSManagedObject
    NSManagedObject *object = [fetchedResultsController objectAtIndexPath:indexPath];
    [managedObjectContext deleteObject:object];
    
    // Save Deletion
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    PhotoDetailViewController *photoDetailViewController = [[PhotoDetailViewController alloc] init];
    Photo *photo = [fetchedResultsController objectAtIndexPath:indexPath];
    photoDetailViewController.photo = photo;
    photoDetailViewController.title = photo.name;
    [self.navigationController pushViewController:photoDetailViewController animated:YES];
     */
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    PhotoDetailViewController *photoDetailViewController = [[PhotoDetailViewController alloc] init];
    Photo *photo = [fetchedResultsController objectAtIndexPath:indexPath];
    photoDetailViewController.photo = photo;
    photoDetailViewController.title = photo.name;
    [self.navigationController pushViewController:photoDetailViewController animated:YES];
}

#pragma mark - manipulate changes

/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	UITableView *tableView = self.tableView;
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[self.tableView endUpdates];
}


@end
