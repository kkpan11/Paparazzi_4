//
//  MapViewController.m
//  Paparazzi_3
//
//  Created by Peter Wang on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "RecentsViewController.h"
#import "PhotoDetailViewController.h"
#import "PhotoAnnotation.h"
#import "Photo.h"

@implementation MapViewController

@synthesize photos;

- (void)dealloc
{
    globeMapView.delegate = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)loadAnnotations
{
    self.photos = [RecentsViewController photos];
    mapAnnotations = [[NSMutableArray alloc] init];
    
    for (Photo *photo in self.photos) {
        id <MKAnnotation> photoAnnotation = [[PhotoAnnotation alloc] initWithPhoto:photo];
        [mapAnnotations addObject:photoAnnotation];
    }
    
    [globeMapView addAnnotations:mapAnnotations];
}

- (void)gotoLocation
{
    // start off by default in San Francisco
    MKCoordinateRegion newRegion;
    
    NSSet *photoSet = [NSSet setWithArray:self.photos];
    Photo *photo = [photoSet anyObject];
    
    newRegion.center.latitude = [photo.latitude doubleValue];
    newRegion.center.longitude = [photo.longitude doubleValue];
    
    newRegion.span.latitudeDelta = 0.112872;
    newRegion.span.longitudeDelta = 0.109863;
    
    [globeMapView setRegion:newRegion animated:YES];
}

- (void)reloadAnnotations
{
    if (!globeMapView) {
        globeMapView = [[MKMapView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
        globeMapView.mapType = MKMapTypeStandard;   // also MKMapTypeSatellite or MKMapTypeHybrid
        
        globeMapView.delegate = self;
    }
    [globeMapView removeAnnotations:globeMapView.annotations];
    [self loadAnnotations];
    [self gotoLocation];
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    if (!globeMapView) {
        globeMapView = [[MKMapView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
        globeMapView.mapType = MKMapTypeStandard;   // also MKMapTypeSatellite or MKMapTypeHybrid
        globeMapView.delegate = self;
    }
    
    // create a custom navigation bar button and set it to always says "Back"
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = @"Back";
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    
    self.view = globeMapView;
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark -
#pragma mark MKMapViewDelegate

// mapView:annotationView:calloutAccessoryControlTapped: is called when the user taps on left & right callout accessory UIControls.
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    PhotoDetailViewController *photoDetailViewController = [[PhotoDetailViewController alloc] init];
    Photo *photo = ((PhotoAnnotation *)view.annotation).photo;
    photoDetailViewController.photo = photo;
    photoDetailViewController.title = photo.name;
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:photoDetailViewController animated:YES];
}

// mapView:viewForAnnotation: provides the view for each annotation.
// This method may be called for all or some of the added annotations.
// For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // try to dequeue an existing pin view first
    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    //PhotoAnnotation *pinView = [[PhotoAnnotation alloc] initWithPhoto:[(PhotoAnnotation *)annotation photo]];
    if (!pinView)
    {
        // if an existing pin view was not available, create one
        MKPinAnnotationView* customPinView = [[MKPinAnnotationView alloc]
                                               initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
        customPinView.pinColor = MKPinAnnotationColorPurple;
        customPinView.animatesDrop = YES;
        customPinView.canShowCallout = YES;
        
        // add a detail disclosure button to the callout which will open a new view controller page
        //
        // note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
        //  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
        //
        //UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        //[rightButton addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
        customPinView.rightCalloutAccessoryView = rightButton;
        
        return customPinView;
    }
    else
    {
        pinView.annotation = annotation;
    }
    return pinView;
}

- (void)showDetails:(id)sender
{
    /*
    // the detail view does not want a toolbar so hide it
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    [self.navigationController pushViewController:self.detailViewController animated:YES];
    */
    
    /*
    PhotoDetailViewController *photoDetailViewController = [[PhotoDetailViewController alloc] init];
    // sender's photo
    Photo *photo = [photos objectAtIndex:indexPath.row];
    photoDetailViewController.photo = photo;
    photoDetailViewController.title = photo.name;
    [self.navigationController pushViewController:photoDetailViewController animated:YES];
    [photoDetailViewController release];
     */
}

@end
