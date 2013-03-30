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

#pragma mark - Triggered by CodeViewController

// Show/hide LeftBar
- (void)showLeftBar;
- (void)hideLeftBar;

#pragma mark - Triggered by LeftBarViewController
- (void)fileObjectSelected:(FileObject*)fileObject;
@end
