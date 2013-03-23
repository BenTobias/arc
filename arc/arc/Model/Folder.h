//
//  Folder.h
//  arc
//
//  Created by Jerome Cheng on 19/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "FileObject.h"
#import "File.h"

@interface Folder : FileObject

// Renames the folder to the given name.
// Returns YES if successful, NO otherwise.
- (BOOL)rename:(NSString*)name;

// Creates a folder with the given name in this folder.
// Returns YES if successful, NO otherwise.
- (BOOL)createFolder:(NSString*)name;

@end
