//
//  MainViewControllerDelegate.h
//  arc
//
//  Created by Benedict Liang on 19/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "File.h"
#import "Folder.h"

@protocol MainViewControllerDelegate// <NSObject>

// Shows the file using the CodeViewController
- (void)showFile:(File*)file;

// Updates the FileNavigatorViewController view after adding a folder
- (void)updateAddFolderView:(Folder*)folder;

// Updates the FileNavigatorViewController view after adding a file
- (void)updateAddFileView:(File*)file;

// Updates the global view upon changing settings
//- (void)updateSettings;

@end
