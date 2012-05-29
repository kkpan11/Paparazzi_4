//
//  VirtualKeyboardViewController.m
//  Paparazzi_3
//
//  Created by Peter Wang on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PersonAddViewController.h"
#import "ContactAddViewController.h"
#import "FlickrFetcher.h"
#import "Person.h"
#import "Photo.h"

@implementation PersonAddViewController

@synthesize nameTextField = _nameTextField;
@synthesize person = _person;
@synthesize delegate;


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
    flickrFetcher = [FlickrFetcher sharedInstance];
    managedObjectContext = [flickrFetcher managedObjectContext];
    fetchedResultsController = [flickrFetcher fetchedResultsControllerForEntity:@"Person" withPredicate:nil];
    
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30,30,100,30)];
    label.text = @"User Name:";
    
    [view addSubview:label];
    
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(130,30,180,30)];
    self.nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.nameTextField.returnKeyType = UIReturnKeyDone;
    self.nameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.nameTextField.delegate = self;
    self.nameTextField.placeholder = @"Name";
    
    [view addSubview:self.nameTextField];
    
    [self.nameTextField becomeFirstResponder];
    
    self.view = view;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Check if there are many TextField in the view.
	if (textField == self.nameTextField) {
		[self.nameTextField resignFirstResponder];
		[self save];
	}
	return YES;
}

/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return NO;
}
*/



/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    self.nameTextField = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)save
{
    // if there is a duplicate person appearing then display alert view to reject add person
    self.person.name = self.nameTextField.text;
    [self.delegate personAddViewController:self didAddPerson:self.person];
}

- (void)cancel
{
    //[self dismissModalViewControllerAnimated:YES];
    //self.navigationController 
}

@end
