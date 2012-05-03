//
//  FeedViewController.m
//  Jackalope
//
//  Created by Peter Terrill on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedViewController.h"
#import "SBJSON.h"
#import "FeedItem.h"

@interface FeedViewController ()
-(void)customInit;
@end

@implementation FeedViewController

-(void)customInit
{
    self.tabBarItem = [[UITabBarItem alloc]
                       initWithTitle:@"Feed"
                       image:[UIImage imageNamed:@"166-newspaper.png"] 
                       tag:APP_TAB_FEED]; 
    
    _feed = [[NSMutableArray alloc] init];
    _isLoading  = YES;
    _isError    = NO;
    _notifyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notify"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserLoggedIn:) name:APPUSER_LOGIN object:nil];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserLoggedOut:) name:APPUSER_LOGOUT object:nil];    
    
    [self refreshFeed];
}

- (id) init
{
    return [self initWithStyle:UITableViewStylePlain];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)refreshFeed
{
    NSString* urlString = [NSString stringWithFormat:@"%@/feed.json", kServerRootURL];
    urlString = [CurrentUser appendAuthTokenToUrlString:urlString];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse* response, NSData* data, NSError* error) 
     {
         if (error)
         {
             _isError = YES;
             NSLog(@"Error loading feed@%@ : %@", [req.URL absoluteString], [error localizedDescription]);
         }
         else
         {             
             NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             
             SBJSON *jsonParser = [SBJSON new];
             id responseObject = [jsonParser objectWithString:responseString];
             
             if (![responseObject isKindOfClass:[NSArray class]])
             {  return; }

             NSArray* feedItems = (NSArray*) responseObject; 
             [_feed removeAllObjects];
             for (NSDictionary* feedItemDictionary in feedItems) {
                 [_feed addObject:[[FeedItem alloc] initWithDictionary:feedItemDictionary]];
             }
         }

         _isLoading = NO;
         [self.tableView reloadData];
     }];
    
    NSLog(@"refreshFeed@%@", urlString);

}

-(void) UserLoggedIn:(NSNotification*) note
{
    [self refreshFeed];
}

-(void) UserLoggedOut:(NSNotification*) note
{
    _feed = [[NSMutableArray alloc] init];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isLoading || _isError)
    {
        return 1;
    }
    else
    {
        return _feed.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UIImage* cellIcon = nil;
    NSString* cellText;
    UITableViewCellAccessoryType cellAccessory = UITableViewCellAccessoryNone;
    
    if (_isError)
    {
        cellText = @"Error loading files.";
    }
    else if (_isLoading)
    {
        cellText = @"Loading...";
    }
    else
    {
        FeedItem* feedItem = [_feed objectAtIndex:[indexPath row]];
        cellText = [NSString stringWithFormat:@"%@", feedItem.message];
    }
    
    cell.accessoryType = cellAccessory;
    [[cell textLabel] setText: cellText];
    [[cell imageView] setImage:cellIcon];
    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
