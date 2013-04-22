//
//  DestinationFolderViewController.m
//  arc
//
//  Created by Yong Michael on 21/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "DestinationFolderViewController.h"

@interface DestinationFolderViewController ()
@property (nonatomic, strong) UIBarButtonItem *closeButton;
@end

@implementation DestinationFolderViewController
@synthesize delegate = _delegate;

- (void)viewDidLoad
{
    [self setUpTableView];
    [self setUpNavigationController];
    self.title = self.folder.name;

    _closeButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                  target:self
                                                  action:@selector(shouldClose:)];
    self.navigationItem.rightBarButtonItem = _closeButton;
}

- (void)setUpNavigationController
{
    self.navigationController.toolbarHidden = NO;
    
    UIBarButtonItem *message =
    [[UIBarButtonItem alloc] initWithTitle:@"Choose a destination."
                                     style:UIBarButtonItemStyleDone
                                    target:nil
                                    action:nil];

    // fake label.
    [message setBackgroundImage:[Utils imageWithColor:[UI toolBarColor]]
                       forState:UIControlStateNormal
                     barMetrics:UIBarMetricsDefault];
    
    [message setBackgroundImage:[Utils imageWithColor:[UI toolBarColor]]
                       forState:UIControlStateHighlighted
                     barMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *createFolderButton =
    [[UIBarButtonItem alloc] initWithTitle:@"New Folder"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(newFolder:)];
    UIBarButtonItem *selectFolderButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Select Folder"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(selectFolder:)];
    
    self.toolbarItems = @[
                          message,
                          [Utils flexibleSpace],
                          createFolderButton,
                          selectFolderButton
                          ];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<FileSystemObject> fileSystemObject = [self sectionItem:indexPath];
    
    for (id<FileSystemObject> objectToMove in [self.delegate targetFiles]) {
        if ([[objectToMove identifier] isEqualToString:[fileSystemObject identifier]]) {
            // Do nothing.
            return;
        }
    }
    
    if ([[fileSystemObject class] conformsToProtocol:@protocol(Folder)]) {
        
        DestinationFolderViewController *destinationFolderViewController =
        [[DestinationFolderViewController alloc] initWithFolder:(id<Folder>)fileSystemObject];
        
        destinationFolderViewController.delegate = self.delegate;

        [self.navigationController pushViewController:destinationFolderViewController
                                             animated:YES];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Only folders should be selectable
- (void)tableView:(UITableView *)tableView
  willPresentCell:(FileObjectTableViewCell *)cell
      atIndexPath:(NSIndexPath *)indexPath
{
    if (![[cell.fileSystemObject class] conformsToProtocol:@protocol(Folder)]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return;
    }
    
    if ([[cell.fileSystemObject identifier] isEqualToString:[self.delegate.folder identifier]]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    id<FileSystemObject> cellFileSystemObject = cell.fileSystemObject;
    for (id<FileSystemObject> objectToMove in [self.delegate targetFiles]) {
        if ([[objectToMove identifier] isEqualToString:[cellFileSystemObject identifier]]) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return;
        }
    }
}

- (void)newFolder:(id)sender
{
    AddFolderViewController *addFolderViewController =
    [[AddFolderViewController alloc] init];
    
    addFolderViewController.delegate = self;
    
    UINavigationController *navController =
    [[UINavigationController alloc] initWithRootViewController:addFolderViewController];
    
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    
    [self presentViewController:navController
                       animated:YES
                     completion:nil];
}

- (void)modalViewControllerDone:(FolderCommandObject *)folderCommandObject
{
    if (folderCommandObject.type == kCancelCommand && ![self.presentedViewController isBeingDismissed]) {
        [self dismissViewControllerAnimated:YES completion:^{}];
        return;
    }

    if (folderCommandObject.type == kCreateFolderCommand  && ![self.presentedViewController isBeingDismissed]) {
        NSString *folderName = (NSString *)folderCommandObject.target;
        [self.folder createFolderWithName:folderName];
        [self dismissViewControllerAnimated:YES completion:^{
            [self refreshFolderView];
        }];
    }
    
    if (![self.presentedViewController isBeingDismissed]) {
        // Default
        [self dismissViewControllerAnimated:YES completion:^{
            [self refreshFolderView];
        }];
    }
}

- (void)selectFolder:(id)sender
{
    [self.delegate modalViewControllerDone:
     [FolderCommandObject commandOfType:kMoveFileObjects
                             withTarget:self.folder]];
}

- (void)shouldClose:(id)sender
{
    [self.delegate modalViewControllerDone:
     [FolderCommandObject commandOfType:kCancelCommand
                             withTarget:nil]];
}

@end
