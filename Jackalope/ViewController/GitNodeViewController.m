//
//  MasterViewController.m
//  Touch Code
//
//  Created by Peter Terrill on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GitNodeViewController.h"
#import "RepoViewController.h"
#import "CodeViewController.h"

#import "RootNode.h"
#import "BranchNode.h"

@implementation GitNodeViewController

@synthesize detailViewController = _detailViewController;
@synthesize node = _node;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Master", @"Master");
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        
        _isLoading = YES;
        _isError = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
}

- (void) setNode:(GitNode *)node
{
    _node = node;
    self.title = node.name;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];    
    [nc addObserver:self
           selector:@selector(NodeUpdateSuccess:)
               name:NODE_UPDATE_SUCCESS
             object:node];    

    [nc addObserver:self
           selector:@selector(NodeUpdateFailed:)
               name:NODE_UPDATE_FAILED
             object:node];

    [node refreshData];
}

-(void)NodeUpdateSuccess:(NSNotification *)note
{
    _isLoading = NO;
    _isError = NO;
    [self.tableView reloadData];    
}

-(void)NodeUpdateFailed:(NSNotification *)note
{
    _isLoading = NO;
    _isError = YES;
    [self.tableView reloadData];    
}

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
        return [_node.children count];
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
        GitNode* childNode = [_node.children objectAtIndex:[indexPath row]];
        cellText = childNode.name;
        
        if ([childNode.type isEqualToString:NODE_TYPE_TREE])
        {
            cellAccessory = UITableViewCellAccessoryDisclosureIndicator;
            cellIcon = [UIImage imageNamed:@"folder.png"];
        }
        else if ([childNode.type isEqualToString:NODE_TYPE_BLOB])
        {
            cellIcon = [UIImage imageNamed:@"file.png"];
        }
    }

    cell.accessoryType = cellAccessory;
    [[cell textLabel] setText: cellText];
    [[cell imageView] setImage:cellIcon];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GitNode *selectedNode = [_node.children objectAtIndex:[indexPath row]];
    [[RepoViewController getInstance] showNode:selectedNode withParent:self.node];
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
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

@end
