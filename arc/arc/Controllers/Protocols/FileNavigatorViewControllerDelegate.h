//
//  FileNavigatorViewControllerDelegate.h
//  arc
//
//  Created by Yong Michael on 1/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Folder.h"

@protocol FileNavigatorViewControllerDelegate <NSObject>
- (void)navigateTo:(id<Folder>)folder;
@end
