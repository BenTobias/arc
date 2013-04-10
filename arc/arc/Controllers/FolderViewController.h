//
//  UIFileNavigationController.h
//  arc
//
//  Created by omer iqbal on 19/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Folder.h"
#import "SubViewControllerDelegate.h"
#import "FolderViewControllerDelegate.h"
#import "CreateFolderViewController.h"

@interface FolderViewController : UIViewController <SubViewControllerDelegate,
    UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, readonly) id<Folder> folder;
@property (nonatomic, weak) id<FolderViewControllerDelegate> folderViewControllerDelegate;
- (id)initWithFolder:(id<Folder>)folder;
- (void)triggerAddFolder;
- (void)refreshFolderContents;
- (void)editActionTriggeredAnimate:(BOOL)animate;
@end
