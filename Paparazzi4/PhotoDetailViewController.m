//
//  PhotoDetailViewController.m
//  Paparazzi_3
//
//  Created by Peter Wang on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "Photo.h"

@implementation PhotoDetailViewController

@synthesize photo = _photo;


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

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.photo.image];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    //NSLog(@"Image size WIDTH: %f", [image size].width);
	//NSLog(@"Image size HEIGHT: %f", [image size].height);
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    [scrollView setContentSize: [self.photo.image size]];
    [scrollView setScrollEnabled :YES];
	[scrollView setMaximumZoomScale :2.0f];
	[scrollView setMinimumZoomScale :0.5f];
	[scrollView setZoomScale :2];
	[scrollView setAutoresizesSubviews :YES];
    
    [scrollView addSubview :imageView];
    
    self.view = scrollView;
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
