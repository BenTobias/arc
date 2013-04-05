//
//  SettingsViewController.h
//  arc
//
//  Created by Yong Michael on 30/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubViewControllerProtocol.h"
#import "ApplicationState.h"

@interface SettingsViewController : UIViewController <SubViewControllerProtocol, UITableViewDelegate, UITableViewDataSource>
@end
