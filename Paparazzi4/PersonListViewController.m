//
//  PersonListViewController.m
//  Paparazzi_3
//
//  Created by Peter Wang on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PersonListViewController.h"
#import "Corefoundation/CoreFoundation.h"
#import "PhotoListViewController.h"
#import "ContactAddViewController.h"
#import "FlickrFetcher.h"
#import "Person.h"
#import "Photo.h"

@implementation PersonListViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    NSLog(@"PersonListViewController initWithStyle");
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        NSLog(@"PersonListViewController initWithStyle After [Super initWithStyle:style]");
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)add
{
    ContactAddViewController *contactAddViewController = [[ContactAddViewController alloc] initWithStyle:UITableViewStyleGrouped];
    contactAddViewController.person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:managedObjectContext];
    [contactAddViewController setManagedObjectContext:managedObjectContext];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:contactAddViewController];
    
    [self presentModalViewController:navigationController animated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    NSLog(@"PersonListViewController viewDidLoad");
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"Contacts";
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
    self.navigationItem.leftBarButtonItem = addButton;
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    
    flickrFetcher = [FlickrFetcher sharedInstance];
    managedObjectContext = [flickrFetcher managedObjectContext];
    
    fetchedResultsController = [flickrFetcher fetchedResultsControllerForEntity:@"Person" withPredicate:nil];

    fetchedResultsController.delegate = self;
    if ([flickrFetcher databaseExists]) {
        NSLog(@"Database exists.");
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{   
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*
    NSInteger numberOfRows = 0;
    
    if (self.tabBarController.selectedIndex == 0) {
        if ([[fetchedResultsController sections] count] > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
            numberOfRows = [sectionInfo numberOfObjects];
        }
    }
    NSLog(@"Row : %d", numberOfRows);
    return numberOfRows;
     */
    NSLog(@"PersonListViewController numberOfRowsInSection : %d", [[fetchedResultsController fetchedObjects] count]);
    return [[fetchedResultsController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        // The style UITableViewCellStyleDefault doesn't support detailTextLabel.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    
    Person *person = [fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = person.name;
    cell.detailTextLabel.text = person.recordName;
    
    NSSet *photoSet = person.photos;
    Photo *photo = [photoSet anyObject];
    cell.imageView.image = photo.image;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
		[managedObjectContext deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
		
		// Save the context.
		NSError *error;
		if (![managedObjectContext save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}   
}

#pragma mark - Manipulate
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
            //[tableView reloadData];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
    /*
    PhotoListViewController *photoListViewController = [[PhotoListViewController alloc] initWithStyle:UITableViewStylePlain];
    Person *person = [fetchedResultsController objectAtIndexPath:indexPath];
    photoListViewController.title = [person.name stringByAppendingString:@"'s Photos"];
    photoListViewController.person = person;
    [self.navigationController pushViewController:photoListViewController animated:YES];
     */
    //[tableView cellForRowAtIndexPath:indexPath].selected = NO;
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"accessoryButtonTappedForRowWithIndexPath");
    PhotoListViewController *photoListViewController = [[PhotoListViewController alloc] initWithStyle:UITableViewStylePlain];
    Person *person = [fetchedResultsController objectAtIndexPath:indexPath];
    photoListViewController.title = [person.name stringByAppendingString:@"'s Photos"];
    photoListViewController.person = person;
    [self.navigationController pushViewController:photoListViewController animated:YES];
}

@end