//
//  FeedCommitViewController.m
//  Jackalope
//
//  Created by Peter Terrill on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedCommitViewController.h"
#import "CommitFile.h"
#import "FeedCommitCell.h"
#import "FeedCommitSectionFooter.h"

NSInteger const _infoCellHeight         = 80;
NSInteger const _notifyCellHeight       = 20;
NSInteger const _sectionHeaderHeight    = 40;
NSInteger const _sectionFooterHeight    = 1;
NSInteger const _fileCellHeight         = 250;
NSString* const _fileCellIdentifier     = @"fileCell";
NSString* const _infoCellIdentifier     = @"infoCell";


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
        
        _notifyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notify"];
        _notifyCell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        
        self.title = @"Jackalope";
        self.tableView.allowsSelection = NO; // not selectable until we get the content back
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView reloadData];
        
        [commit refresh];
    }
    
    return self;
}

-(void)CommitUpdateSuccess:(NSNotification *)note
{
    _isLoading = NO;
    _isError = NO;
    [_infoCell refresh];
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
    NSInteger sections = 1; // first section is the summary info or status message
    
    if (!_isLoading && !_isError)
    {
        sections += _commit.files.count;
    }
    
    return sections;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section > 0) {
        CommitFile* file = [_commit.files objectAtIndex:(section-1)];
        
        if (file.diffExpanded)
        {
            return 1;
        }
        else {
            return 0;
        }
    }
    else {
        return 1;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isError || _isLoading)
    {
        return _notifyCellHeight;
    }
    else if (indexPath.section == 0)
    {
        return _infoCellHeight;
    }
    else {
        return _fileCellHeight;
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
    else if (indexPath.section == 0)
    {
        if (_infoCell == nil) {
            _infoCell = [[FeedCommitInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_infoCellIdentifier];
            _infoCell.commit = _commit;
        }
        return _infoCell;
    }
    else {

        FeedCommitCell* cell = [tableView dequeueReusableCellWithIdentifier:_fileCellIdentifier];
        if (cell == nil) {
            cell = [[FeedCommitCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_fileCellIdentifier cellHeight:_fileCellHeight];
        }               
        
        NSInteger fileIndex = (indexPath.section - 1); //factor out the initial header section
        CommitFile* file = [_commit.files objectAtIndex:fileIndex];
        [cell setDiff:file.patch forFileName:file.name];
        
        return cell;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CommitFile* file = [_commit.files objectAtIndex:indexPath.row];
//    Code* code = [[Code alloc] init];
//    code.fileName = file.name;
//    code.plainText = file.patch;
//    
//    CodeDiffViewController* diffViewer = [[CodeDiffViewController alloc] initWithCode:code]; 
//    [self.navigationController pushViewController:diffViewer animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0.f;

    if (section > 0)
    {
        height = _sectionHeaderHeight;
    }
    
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section > 0)
    {        
        CGRect frame = CGRectMake(0, 0, tableView.frame.size.width, _sectionHeaderHeight);
        CommitFile* file = [_commit.files objectAtIndex:(section-1)];
        FeedCommitSectionHeader* fileHeader = [[FeedCommitSectionHeader alloc] initWithFrame:frame title:file.name section:section delegate:self];
        fileHeader.disclosureButton.selected = file.diffExpanded;
        return fileHeader;
    }
    else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return _sectionFooterHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    CGRect frame = CGRectMake(0, 0, tableView.frame.size.width, _sectionFooterHeight);
    FeedCommitSectionFooter* footer = [[FeedCommitSectionFooter alloc] initWithFrame:frame];
    return footer;
}

-(void) fileSectionOpened:(NSInteger)section
{
    CommitFile* file = [_commit.files objectAtIndex:(section-1)];
    file.diffExpanded = YES;
    
    NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:section];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationTop];
}

-(void) fileSectionClosed:(NSInteger)section
{
    CommitFile* file = [_commit.files objectAtIndex:(section-1)];
    file.diffExpanded = NO;

    NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:section];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationTop];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
