//
//  RecentsViewController.m
//  Paparazzi_3
//
//  Created by Peter Wang on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecentsViewController.h"
#import "PhotoDetailViewController.h"
#import "MapViewController.h"
#import "FlickrFetcher.h"
#import "Photo.h"
#import "Person.h"

@implementation RecentsViewController

static NSMutableArray *photos = nil;

@synthesize mapViewController = _mapViewController;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        NSLog(@"RecentsViewController initWithStyle");
        flickrFetcher = [FlickrFetcher sharedInstance];
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:[flickrFetcher persistentStoreCoordinator]];
        //photos = [[NSMutableArray alloc] init];
        fetchLock = [[NSLock alloc] init];
        isFetchedDone =YES;
        canBePinned = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

+ (NSArray *)photos
{
    return photos;
}

- (void)fetchRecentGeoTaggedPhotos
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
    //activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:activityIndicator];
    //[self.view bringSubviewToFront:activityIndicator];
    activityIndicator.hidden = NO;
    [activityIndicator startAnimating];
    
    
    //FlickrFetcher flickrFetcher = [FlickrFetcher sharedInstance];
    //context = [[NSManagedObjectContext alloc] init];
    //[context setPersistentStoreCoordinator:[flickrFetcher persistentStoreCoordinator]];
    
    recentPhotosDescriptions = [flickrFetcher recentGeoTaggedPhotos];
    NSLog(@"%@", recentPhotosDescriptions);
    
    for (NSDictionary *item in recentPhotosDescriptions) {
        Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        
        //data = [flickrFetcher dataForPhotoID:[item objectForKey:@"id"]  fromFarm:[item objectForKey:@"farm"] onServer:[item objectForKey:@"server"] withSecret:[item objectForKey:@"secret"] inFormat:FlickrFetcherPhotoFormatSquare];
        //FlickrFetcherPhotoFormatLarge
        NSData *data = [flickrFetcher dataForPhotoID:[item objectForKey:@"id"]  fromFarm:[item objectForKey:@"farm"] onServer:[item objectForKey:@"server"] withSecret:[item objectForKey:@"secret"] inFormat:FlickrFetcherPhotoFormatLarge];
        
        photo.image = [UIImage imageWithData:data];
        photo.name = [item objectForKey:@"title"];
        //photo.recentTagged = [[NSNumber alloc]initWithBool:YES];
        
        //int photoID = [[item objectForKey:@"id"] intValue];
        //photo.photoID = [NSNumber numberWithInt:photoID];
        
        NSDictionary *coordinates = [flickrFetcher locationForPhotoID:[item objectForKey:@"id"]];
        //NSLog(@"%@", coordinates);
        if (coordinates) {
            
            if ([[coordinates objectForKey:@"latitude"] isKindOfClass:[NSNumber class]] && [[coordinates objectForKey:@"longitude"] isKindOfClass:[NSNumber class]]) {
                photo.latitude = [coordinates objectForKey:@"latitude"];
                photo.longitude = [coordinates objectForKey:@"longitude"];
            }
            
            //int latitude = [[item objectForKey:@"latitude"] intValue];
            //photo.latitude = [NSNumber numberWithInt:latitude];
            //int longitude = [[item objectForKey:@"longitude"] intValue];
            //photo.longitude = [NSNumber numberWithInt:longitude];
            
        }
        
        NSLog(@"latitude :%@ | longitude :%@", photo.latitude, photo.longitude);
        
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", [item objectForKey:@"owner"]];
        
        //[request setFetchBatchSize:20];
        
        [request setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *persons = [context executeFetchRequest:request error:&error];
        if (!persons) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        Person *person;
        
        if ([persons count] > 0) {
            person = [persons objectAtIndex:0];
        } else {
            person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:context];
        }
        
        [person addPhotosObject:photo];
        person.name = [flickrFetcher usernameForUserID:[item objectForKey:@"owner"]];
        photo.person = person;
        
        
        [photos addObject:photo];
    }
    //return photos;
    NSLog(@"===Fetch Done.===");
    
    [self.tableView reloadData];
    canBePinned = YES;
    [activityIndicator stopAnimating];
    [activityIndicator removeFromSuperview];
    
    isFetchedDone = YES;
    [self.mapViewController reloadAnnotations];
}

- (void)refresh
{
    if (isFetchedDone) {
        [photos removeAllObjects];
        [self.tableView reloadData];
        [context undo];
        NSThread *refreshThread = [[NSThread alloc] initWithTarget:self selector:@selector(fetchRecentGeoTaggedPhotos) object:nil];
        [refreshThread start];
    }
    
    //[self fetchRecentGeoTaggedPhotos];
    
    //[self.tableView reloadData];
    // can be pinned in the map view after refresh photos.
    //canBePinned = YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    NSLog(@"RecentsViewController viewDidLoad");
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    
    photos = [[NSMutableArray alloc] init];
    
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(150,180,20,10);
    //activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:activityIndicator];
    
    NSThread *fetchThread = [[NSThread alloc] initWithTarget:self selector:@selector(fetchRecentGeoTaggedPhotos) object:nil];
    [fetchThread start];
    
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
    return [photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    /*
    NSDictionary *photoItem = [recentPhotos objectAtIndex:indexPath.row];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Photo"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", [photoItem objectForKey:@"title"]];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *photos = [managedObjectContext executeFetchRequest:request error:&error];
    Photo *photo;
    
    if (!photos) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [request release];
    
    if ([photos count] > 0) {
        photo = [photos objectAtIndex:0];
        cell.textLabel.text = photo.name;
        cell.detailTextLabel.text = photo.person.name;
        cell.imageView.image = photo.image;
    }
    */
    
    Photo *photo = [photos objectAtIndex:indexPath.row];
    cell.textLabel.text = photo.name;
    cell.detailTextLabel.text = photo.person.name;
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

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
    PhotoDetailViewController *photoDetailViewController = [[PhotoDetailViewController alloc] init];
    Photo *photo = [photos objectAtIndex:indexPath.row];
    photoDetailViewController.photo = photo;
    photoDetailViewController.title = photo.name;
    [self.navigationController pushViewController:photoDetailViewController animated:YES];
}

@end
