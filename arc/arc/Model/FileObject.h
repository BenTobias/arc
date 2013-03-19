//
//  FileObject.h
//  arc
//
//  Created by Jerome Cheng on 19/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileObject : NSObject

// The name of this object.
@property (strong, nonatomic) NSString* name;

// The full file path of this object.
@property (strong, nonatomic) NSString* path;

// The parent of this object (if any.)
@property (strong, nonatomic) FileObject* parent;

// Whether this object is a folder or not.
@property bool isFolder;

@end
