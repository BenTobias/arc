//
//  SettingsViewDelegate.h
//  arc
//
//  Created by Yong Michael on 6/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginDelegate.h"

@protocol SettingsViewDelegate <NSObject>
- (void)registerPlugin:(id<PluginDelegate>)plugin;
@end
