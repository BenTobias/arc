//
//  ResultsTableViewController.m
//  arc
//
//  Created by Benedict Liang on 7/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "ResultsTableViewController.h"
#import "SearchResultCell.h"

@interface ResultsTableViewController ()

@end

@implementation ResultsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_resultsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[SearchResultCell alloc] init];
    }
    
    if (cell) {
        NSNumber *lineNumber = (NSNumber*)[_resultsArray objectAtIndex:indexPath.row];
        
        cell.lineNumber = [lineNumber intValue];
        cell.textLabel.text = [NSString stringWithFormat:@"Line %d", cell.lineNumber];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    SearchResultCell *cell = (SearchResultCell*)[tableView cellForRowAtIndexPath:indexPath];
    int lineNumber = cell.lineNumber;
    
    [_codeViewController scrollToLineNumber:lineNumber];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
