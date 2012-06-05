//
//  FeedCommitViewController.m
//  Jackalope
//
//  Created by Peter Terrill on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedCommitViewController.h"
#import "CommitFile.h"
#import "CodeDiffViewController.h"

@implementation FeedCommitViewController

-(id) initWithCommit:(Commit*)commit
{
    self = [super initWithStyle:UITableViewStylePlain];    
    if (self)
    {
        _commit = commit;

        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(CommitUpdateSuccess:)
                   name:NODE_UPDATE_SUCCESS
                 object:commit];    
        
        [nc addObserver:self
               selector:@selector(CommitUpdateFailed:)
                   name:NODE_UPDATE_FAILED
                 object:commit];
        
        _isLoading = YES;
        _isError = NO;
        self.tableView.allowsSelection = NO; // not selectable until we get the content back
        [self.tableView reloadData];
        
        [commit refresh];
    }
    
    return self;
}

-(void)CommitUpdateSuccess:(NSNotification *)note
{
    _isLoading = NO;
    _isError = NO;
    self.tableView.allowsSelection = YES;
    [self.tableView reloadData];    
}

-(void)CommitUpdateFailed:(NSNotification *)note
{
    _isLoading = NO;
    _isError = YES;
    [self.tableView reloadData];    
}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 1;
    
    if (!_isLoading && !_isError)
    {
        rows = _commit.files.count;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellIdentifier = @"fileCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }               
    
    if (_isError) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = @"Error Loading";
    }
    else if (_isLoading)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = @"Loading Files...";
    }
    else {
        CommitFile* file = [_commit.files objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        cell.textLabel.text = file.name;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommitFile* file = [_commit.files objectAtIndex:indexPath.row];
    Code* code = [[Code alloc] init];
    code.fileName = file.name;
    code.plainText = file.patch;
    
    CodeDiffViewController* diffViewer = [[CodeDiffViewController alloc] initWithCode:code]; 
    [self.navigationController pushViewController:diffViewer animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0.f;
    
    if (section == 0)
    {
        height = 50.f;
    }
    
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* header;
    
    if (section == 0)
    {        
        UILabel* labelView = [[UILabel alloc] init];
        labelView.text = _commit.message;
        
        header = labelView;
    }
    
    return header;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
