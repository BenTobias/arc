//
//  BasicFolderViewController.h
//  arc
//
//  Created by Yong Michael on 21/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "File.h"
#import "Folder.h"
#import "FileObjectTableViewCell.h"
#import "FolderViewSectionHeader.h"
#import "FileSystemObjectGroup.h"

@interface BasicFolderViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, FolderDelegate>
// folder to display
- (id)initWithFolder:(id<Folder>)folder;

// method to group folder contents
// default implementation segregates folders and files
- (void)setUpFolderContents;

// create tableView and attaches it to self.view
- (void)setUpTableView;

// hook for back button
// in navigation controller stack
- (void)didPopFromNavigationController;

// reloads tableView
- (void)refreshFolderView;

// readonly properties for more customisation
@property (nonatomic, readonly) id<Folder> folder;
@property (nonatomic, readonly) UITableView *tableView;

// TableView Delegate and Datasource
@property (nonatomic, strong) id<UITableViewDelegate> tableViewDelegate;
@property (nonatomic, strong) id<UITableViewDataSource> tableViewDataSource;

// hook to customise tableView cell before presenting
- (void)tableView:(UITableView *)tableView
  willPresentCell:(FileObjectTableViewCell *)cell
      atIndexPath:(NSIndexPath *)indexPath;

// Data source Accessor Methods
// helpers to interface with data
- (void)setFilesAndFolders:(NSArray *)filesAndFolders;
- (NSInteger)numberOfSections;
- (FileSystemObjectGroup *)sectionObjectGroup:(NSInteger)section;
- (NSString *)sectionHeading:(NSInteger)section;
- (NSArray *)sectionItems:(NSInteger)section;
- (id<FileSystemObject>)sectionItem:(NSIndexPath *)indexPath;

// Constants
extern NSString* const FOLDER_VIEW_FOLDERS;
extern NSString* const FOLDER_VIEW_FILES;
@end
