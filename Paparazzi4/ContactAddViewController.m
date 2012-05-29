//
//  ContactAddViewController.m
//  Paparazzi_4
//
//  Created by  on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactAddViewController.h"
#import "FlickrFetcher.h"
#import "Person.h"

@implementation ContactAddViewController

@synthesize person = _person;

- (void)dealloc
{
    if (personRecord)
        CFRelease(personRecord);
    if (addressBook)
        CFRelease(addressBook);
    //[flickrFetcher release];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //flickrFetcher = [FlickrFetcher sharedInstance];
        //managedObjectContext = [flickrFetcher managedObjectContext];
        addressBook = ABAddressBookCreate();
        personRecord = NULL;
        NSLog(@"ContactAddViewController initWithStyle");
    }
    return self;
}

// managedObjectContext assign
- (void)setManagedObjectContext:(NSManagedObjectContext *)_managedObjectContext
{
    managedObjectContext = _managedObjectContext;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)save
{
    NSLog(@"Name: %@", self.person.name);
    NSLog(@"Record ID: %d", [self.person.recordID integerValue]);
    NSLog(@"Person Record Name :%@", self.person.recordName);
    //if ([self.person.name isEqualToString:@""] || (self.person.recordID == 0)) {
    if ((!self.person.name) || ([self.person.recordID intValue] == 0)) {
        // Show an alert if "Appleseed" is not in Contacts
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"User must requires name & address book record." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alert show];
    } else {
        if ([managedObjectContext hasChanges]) {
            NSError *error = nil;
            if (![managedObjectContext save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, [self.person.recordID intValue]);
        NSString *firstName = (__bridge_transfer NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge_transfer NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        NSLog(@"After Save Name : %@ %@", firstName, lastName);
        self.person.recordName = [firstName stringByAppendingFormat:@" %@", lastName];
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)cancel
{
    if (self.person) {
        [managedObjectContext deleteObject:self.person];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)editPersonRecord
{
    //ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, ABRecordGetRecordID(personRecord));
    ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, [self.person.recordID intValue]);
    if (person) {
        ABPersonViewController *picker = [[ABPersonViewController alloc] init];
        //picker.title = self.person.name;
        picker.personViewDelegate = self;
        picker.displayedPerson = person;
        // Allow users to edit the person’s information
        picker.allowsEditing = YES;
        //pciker.allowsActions = YES;
        [self.navigationController pushViewController:picker animated:YES];
    } else {
        // Show an alert if "Appleseed" is not in Contacts
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not find current person redord in the Contacts application" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[alert show];
    }
}

- (void)establishAddressBookLink
{
    ABRecordRef aContact = ABPersonCreate();
    
    ABUnknownPersonViewController *picker = [[ABUnknownPersonViewController alloc] init];
    picker.title = cell1.detailTextLabel.text;
    picker.unknownPersonViewDelegate = self;
    picker.displayedPerson = aContact;
    picker.allowsAddingToAddressBook = YES;
    picker.allowsActions = YES;
			
    [self.navigationController pushViewController:picker animated:YES];
    
	CFRelease(aContact); 
}

#pragma mark Add data to an existing person

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    NSLog(@"ContactAddViewController viewDidLoad");
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"New Person";
    
    self.tableView.frame = CGRectMake(10, 10, 300, 320);
    
    btnAddressBookLink = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnAddressBookLink.frame = CGRectMake(10, 250, 300, 50);
    [btnAddressBookLink setTitle:@"Establish Address Book Link" forState:UIControlStateNormal];
    [btnAddressBookLink addTarget:self action:@selector(establishAddressBookLink) forControlEvents:UIControlEventTouchDown];
    [self.tableView addSubview:btnAddressBookLink];
    btnEstablishedAddressBookLink = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnEstablishedAddressBookLink.frame = btnAddressBookLink.frame;
    [btnEstablishedAddressBookLink setTitle:@"You should not see that button!" forState:UIControlStateNormal];
    [btnEstablishedAddressBookLink addTarget:self action:@selector(editPersonRecord) forControlEvents:UIControlEventTouchDown];
    [self.tableView addSubview:btnEstablishedAddressBookLink];
    btnEstablishedAddressBookLink.hidden = YES;
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
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
    
    NSLog(@"Name : %@", self.person.name);
    NSLog(@"Record ID : %d", [self.person.recordID integerValue]);
    if ((self.person.name) && ([self.person.recordID intValue] > 0)) {
        ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, [self.person.recordID intValue]);
        NSString *firstName = (__bridge_transfer NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge_transfer NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        [btnEstablishedAddressBookLink setTitle:[@"Edit : " stringByAppendingFormat:@"%@ %@", firstName, lastName] forState:UIControlStateNormal];
    }
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Person";
            //cell.detailTextLabel.text = @"kkpan11";
            cell1 = cell;
            break;
        case 1:
            cell.textLabel.text = @"Created";
            break;
        case 2:
            cell.textLabel.text = @"Changed";
            break;
        default:
            // do nothing
            break;
    }
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

#pragma mark - PersonAddView Delegate

- (void)personAddViewController:(PersonAddViewController *)personAddViewController didAddPerson:(Person *)beSavedPerson
{
    BOOL isDuplicate = NO;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    NSError *error = nil;
    NSArray *persons = [managedObjectContext executeFetchRequest:request error:&error];
    if (!persons) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // reject duplicate person
    int foundedCount = 0;
    for (Person *person in persons) {
        if ([person.name isEqualToString:beSavedPerson.name] ) {
            foundedCount++;
            if (foundedCount == 2)
            {
                isDuplicate = YES;
                break;
            }
            
        }
    }
    
    if (!isDuplicate) {
        // change the cell person name
        //[self.tableView cellForRowAtIndexPath:0].detailTextLabel.text = beSavedPerson.name;
        //[self.tableView reloadRowsAtIndexPaths:<#(NSArray *)#> withRowAnimation:<#(UITableViewRowAnimation)#>];
        cell1.detailTextLabel.text = beSavedPerson.name;
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        // show alert view when user typing the duplicate person name
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not create duplicate user" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    if (indexPath.row == 0) {
        PersonAddViewController *addController = [[PersonAddViewController alloc] init];
        addController.delegate = self;
        
        //self.person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:managedObjectContext];
        addController.person = self.person;
        addController.title = @"Person Name";
        
        //indexPath
        [self.navigationController pushViewController:addController animated:YES];
        
    }
}

#pragma mark ABUnknownPersonViewControllerDelegate methods
// Dismisses the picker when users are done creating a contact or adding the displayed person properties to an existing contact. 
- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownPersonView didResolveToPerson:(ABRecordRef)person
{
    // Do nothing when canceling to create new contact.
    if (person == NULL)
        return;
	// Do something.
    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    self.person.recordID = [NSNumber numberWithInteger:ABRecordGetRecordID(person)];
    self.person.recordName = [firstName stringByAppendingFormat:@" %@", lastName];
    NSLog(@"Assign recird ID to %@", self.person.recordID);
    NSLog(@"Assign record Name to %@", self.person.recordName);
    
    btnAddressBookLink.hidden = YES;
    [self.tableView sendSubviewToBack:btnAddressBookLink];
    btnEstablishedAddressBookLink.hidden = NO;
    [self.tableView bringSubviewToFront:btnEstablishedAddressBookLink];
    [btnEstablishedAddressBookLink setTitle:[@"Edit" stringByAppendingFormat:@" : %@ %@", firstName, lastName] forState:UIControlStateNormal];
    
    // should take care ownership. CFRetain() should help sovling this problem.
    personRecord = CFRetain(person);
    [self dismissModalViewControllerAnimated:YES];
}


// Does not allow users to perform default actions such as emailing a contact, when they select a contact property.
- (BOOL)unknownPersonViewController:(ABUnknownPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person 
						   property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	return NO;
}


#pragma mark ABPersonViewControllerDelegate methods
// Called when the user selects an individual value in the Person view, identifier will be kABMultiValueInvalidIdentifier if a single value property was selected.
// Return NO if you do not want anything to be done or if you are handling the actions yourself.
// Return YES if you want the ABPersonViewController to perform its default action.
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return YES;
}

@end
