//
//  LeftViewControllerProtocol.h
//  arc
//
//  Created by Yong Michael on 1/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Folder.h"

@protocol LeftViewControllerProtocol <NSObject>
@property (nonatomic, readonly) NSString *title;
- (void)showFolder:(id<Folder>)folder;


// tmp
- (void)forceFolder:(id<Folder>)folder;
@end
