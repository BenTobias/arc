//
//  LeftBarViewController.h
//  arc
//
//  Created by omer iqbal on 25/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileNavigationViewController.h"
#import "SubViewController.h"
#import "Constants.h"

@interface LeftBarViewController : UIViewController<SubViewController>
@property FileNavigationViewController* fileNav;
@property UINavigationController* navController;
- (id)initWithFolder:(Folder*)folder delegate:(id)del;

@end
