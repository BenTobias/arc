//
//  FileSystem.h
//  arc
//
//  Created by Jerome Cheng on 19/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Folder.h"

@interface FileSystem : NSObject

// Returns the root folder of the entire file system.
- (Folder*) getRootFolder;

@end
