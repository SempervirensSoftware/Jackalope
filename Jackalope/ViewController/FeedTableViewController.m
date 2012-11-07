//
//  FeedViewController.m
//  Jackalope
//
//  Created by Peter Terrill on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedTableViewController.h"
#import "SBJSON.h"
#import "EventFactory.h"
#import "Commit.h"
#import "PushEventCell.h"
#import "FeedCommitViewController.h"

NSString* const _cellIdentifier     = @"FeedCell";
NSInteger const _cellHeight         = 50;

@interface FeedTableViewController ()
-(void)customInit;
@end

@implementation FeedTableViewController

-(void)customInit
{
    self.tabBarItem = [[UITabBarItem alloc]
                       initWithTitle:@"Feed"
                       image:[UIImage imageNamed:@"166-newspaper.png"] 
                       tag:APP_TAB_FEED]; 
    
    self.tableView.rowHeight = _cellHeight;    
    self.tableView.allowsSelection = NO;
    
    self.title = @"Feed";
    _feed = [[NSMutableArray alloc] init];
    _isLoading  = YES;
    _isError    = NO;
    _notifyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notify"];
    
    _navController = [[UINavigationController alloc] initWithRootViewController:self];
    
    // Refresh view
    if (_refreshHeaderView == nil) {
        
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];

        view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
    }
    //  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
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
                 [_feed addObject:[EventFactory createEventForDictionary:feedItemDictionary]];
             }
         }

         _isLoading = NO;
         [self.tableView reloadData];
     }];
    
    NSLog(@"refreshFeed@%@", urlString);
}

-(void) showCommit:(Commit*)commit
{
    FeedCommitViewController* feedVC = [[FeedCommitViewController alloc] initWithCommit:commit];
    [self.navigationController pushViewController:feedVC animated:YES];
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
    if (_isError)
    {
        _notifyCell.textLabel.text = @"Error loading feed.";
        return _notifyCell;
    }
    else if (_isLoading)
    {
        _notifyCell.textLabel.text = @"Loading...";
        return _notifyCell;
    }
    
    
    Event* feedEvent = [_feed objectAtIndex:[indexPath row]];
    
    PushEventCell* cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    if (cell == nil) {
        cell = [[PushEventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_cellIdentifier];
        cell.frame = CGRectMake(0.0, 0.0, cell.frame.size.width, _cellHeight);
        cell.feedController = self;
    }               
     
    cell.event = (EventPush*)feedEvent;
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isError || _isLoading)
    {
        return _cellHeight;
    }    
    
    Event* feedEvent = [_feed objectAtIndex:[indexPath row]];
    
    return [PushEventCell heightForEvent:(EventPush*)feedEvent];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event* feedEvent = [_feed objectAtIndex:[indexPath row]];
    NSLog(@"actor:%@",feedEvent.actorLogin);
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_isReloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_isReloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _isReloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}


@end
