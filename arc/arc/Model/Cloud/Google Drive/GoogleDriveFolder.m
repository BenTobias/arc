//
//  GoogleDriveFolder.m
//  arc
//
//  Created by Jerome Cheng on 14/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "GoogleDriveFolder.h"

@interface GoogleDriveFolder ()

@property (strong, atomic) NSArray *contents;
@property (strong, atomic) NSArray *operations;
@end

@implementation GoogleDriveFolder
@synthesize name = _name, identifier = _path, parent = _parent, isRemovable = _isRemovable, delegate = _delegate, size = _size;

+ (GoogleDriveFolder *)getRoot
{
    return [[GoogleDriveFolder alloc] initWithName:@"Google Drive" identifier:@"root" parent:nil];
}

- (BOOL)hasOngoingOperations
{
    return [_operations count] > 0;
}

- (float)size
{
    return [_contents count];
}

- (int)ongoingOperationCount
{
    return [_operations count];
}

- (id)initWithName:(NSString *)name identifier:(NSString *)path parent:(id <FileSystemObject>)parent
{
    if (self = [super init]) {
        _name = name;
        _path = path;
        _parent = parent;
        _isRemovable = NO;
        
        _contents = [NSArray array];
        _operations = [NSArray array];
    }
    return self;
}

- (void)cancelOperations
{
    for (GTLServiceTicket *currentTicket in _operations) {
        [currentTicket cancelTicket];
    }
    _operations = [NSArray array];
}

- (void)updateContents
{
    GoogleDriveServiceManager *serviceManager = (GoogleDriveServiceManager *)[GoogleDriveServiceManager sharedServiceManager];
    GTLServiceDrive *driveService = [serviceManager driveService];
    
    GTLQuery *folderContentsQuery = [GTLQueryDrive queryForChildrenListWithFolderId:_path];
    
    [driveService executeQuery:folderContentsQuery delegate:self didFinishSelector:@selector(contentsTicket:children:error:)];
}

// Handles callbacks from a query for a folder's children.
- (void)contentsTicket:(GTLServiceTicket *)ticket children:(GTLDriveChildList *)children error:(NSError *)error
{
    if (!error) {
        GoogleDriveServiceManager *serviceManager = (GoogleDriveServiceManager *)[GoogleDriveServiceManager sharedServiceManager];
        GTLServiceDrive *driveService = [serviceManager driveService];
        
        for (GTLDriveChildReference *currentReference in children) {
            // Get the child's attributes.
            GTLQuery *attributeQuery = [GTLQueryDrive queryForFilesGetWithFileId:[currentReference identifier]];
            GTLServiceTicket *currentTicket = [driveService executeQuery:attributeQuery delegate:self didFinishSelector:@selector(attributesTicket:file:error:)];
            _operations = [_operations arrayByAddingObject:currentTicket];
        }
    } else {
        [self handleError:error];
    }
}

// Handles callbacks from a query for a file/folder's attributes.
- (void)attributesTicket:(GTLServiceTicket *)ticket file:(GTLDriveFile *)file error:(NSError *)error
{
    if (!error) {
        NSString *fileName = [file title];
        NSString *filePath = [file downloadUrl];
        NSNumber *fileSize = [file fileSize];
        NSString *fileType = [file mimeType];
        NSString *fileIdentifier = [file identifier];
        
        NSArray *filteredArray = [_contents filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            if ([[evaluatedObject class] conformsToProtocol:@protocol(Folder)]) {
                return [[evaluatedObject identifier] isEqualToString:fileIdentifier];
            } else {
                return [[evaluatedObject identifier] isEqualToString:filePath];
            }
        }]];
        if ([filteredArray count] == 0) {
            if ([fileType isEqualToString:@"application/vnd.google-apps.folder"]) {
                // This is a folder.
                // Note that folders are retrieved by their identifier, not the download URL.
                GoogleDriveFolder *newFolder = [[GoogleDriveFolder alloc] initWithName:fileName identifier:fileIdentifier parent:self];
                _contents = [_contents arrayByAddingObject:newFolder];
            } else {
                // This must be a file. Add it if we have a download URL.
                if (filePath != nil) {
                    GoogleDriveFile *newFile = [[GoogleDriveFile alloc] initWithName:fileName identifier:filePath size:[fileSize floatValue]];
                    _contents = [_contents arrayByAddingObject:newFile];
                }
            }
            [_delegate folderContentsUpdated:self];
        }
    } else {
        [self handleError:error];
    }
    
    NSMutableArray *newOperations = [NSMutableArray arrayWithArray:_operations];
    [newOperations removeObject:ticket];
    _operations = [NSArray arrayWithArray:newOperations];
}

- (void)handleError:(NSError *)error
{
    int errorCode = [error code];
    switch (errorCode) {
        case 400:
        case 401:
            [_delegate folderReportsAuthFailed:self];
            break;
        default:
            NSLog(@"%@", error);
            break;
    }
}

@end
