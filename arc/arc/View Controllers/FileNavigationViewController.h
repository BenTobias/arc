//
//  UIFileNavigationController.h
//  arc
//
//  Created by omer iqbal on 19/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Folder.h"
@interface FileNavigationViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic) NSArray* data;


-(id)initWithFiles:(NSArray*)files;

-(id)initWithFolder:(Folder*)folder;
// define delegate property
@property (nonatomic, assign) id delegate;

//TODO: needs update view methods upon adding a) a file b) a folder. Alternatively, it could take in a FileObject.

@end
