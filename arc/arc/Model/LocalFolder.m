//
//  LocalFolder.m
//  arc
//
//  Created by Jerome Cheng on 1/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "LocalFolder.h"

@implementation LocalFolder

// Synthesize properties from protocol.
@synthesize name=_name, path=_path, parent=_parent;

// Initialises this object with the given name, path, and parent.
- (id)initWithName:(NSString *)name path:(NSString *)path parent:(id<FileSystemObject>)parent
{
    if (self = [super init]) {
        _name = name;
        _path = path;
        _parent = parent;
        _needsRefresh = YES;
    }
    return self;
}

// Returns the contents of this object.
- (id<NSObject>)contents
{
    if (_needsRefresh) {
        return [self refreshContents];
    } else {
        return _contents;
    }
}

// Refreshes the contents of this object, and returns them (for convenience.)
- (id<NSObject>)refreshContents
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error;
    NSArray *retrievedContents = [fileManager contentsOfDirectoryAtPath:_path error:&error];
    
    if (error) {
        NSLog(@"%@", error);
        return nil;
    } else {
        NSMutableArray *contents = [[NSMutableArray alloc] init];
        
        for (NSString *currentPath in retrievedContents) {
            NSString *itemName = [currentPath lastPathComponent];
            
            id<FileSystemObject>retrievedObject;
            if ([[NSURL fileURLWithPath:currentPath] isDirectory]) {
                retrievedObject = [[LocalFolder alloc] initWithName:itemName path:currentPath parent:self];
            } else {
                retrievedObject = [[LocalFile alloc] initWithName:itemName path:currentPath parent:self];
            }
            [contents addObject:retrievedObject];
        }
        _contents = contents;
        _needsRefresh = NO;
        return _contents;
    }
}

// Marks this object as needing to be refreshed.
- (void)markNeedsRefresh
{
    _needsRefresh = YES;
}

// Moves the given FileSystemObject to this Folder.
// The given file must be of the same "type" as this Folder
// (e.g. iOS file system, DropBox, etc.)
// Returns YES if successful, NO otherwise.
- (BOOL)takeFileSystemObject:(id<FileSystemObject>)target
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *newTargetPath = [_path stringByAppendingPathComponent:[[target path] lastPathComponent]];
    
    NSError *error;
    BOOL isMoveSuccessful = [fileManager moveItemAtPath:[target path] toPath:newTargetPath error:&error];
    if (isMoveSuccessful) {
        [self markNeedsRefresh];
        [target setParent:self];
        [target setPath:newTargetPath];
        return YES;
    } else {
        NSLog(@"%@", error);
        return NO;
    }
}

// Returns the FileSystemObject with the given name.
// Will return nil if the object is not found.
- (id<FileSystemObject>)retrieveItemWithName:(NSString*)name
{
    NSArray *contents = (NSArray*)[self contents];
    for (id<FileSystemObject>currentObject in contents) {
        if ([[currentObject name] isEqualToString:name]) {
            return currentObject;
        }
    }
    return nil;
}

// Creates a Folder with the given name inside this one.
// Returns the created Folder object.
- (id<Folder>)createFolderWithName:(NSString*)name
{
    NSString *newFolderPath = [_path stringByAppendingPathComponent:name];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error;
    BOOL isCreateSuccessful = [fileManager createDirectoryAtPath:newFolderPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (isCreateSuccessful) {
        LocalFolder *newFolder = [[LocalFolder alloc] initWithName:name path:newFolderPath parent:self];
        [self markNeedsRefresh];
        return newFolder;
    } else {
        NSLog(@"%@", error);
        return nil;
    }
}

@end
