//
//  ApplicationState.h
//  arc
//
//  Created by Benedict Liang on 19/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "File.h"
#import "Folder.h"
#import "RootFolder.h"

@interface ApplicationState : NSObject
+ (ApplicationState*)sharedApplicationState;

@property (strong, nonatomic) id<File> currentFileOpened;
@property (strong, nonatomic) id<Folder> currentFolderOpened;

//
// Settings and Preferences
//
// Font Dictionary
@property (nonatomic, strong) NSDictionary* fonts;


// Individual Settings
@property (nonatomic) int fontSize;
@property (nonatomic, strong) NSString* fontFamily;
@property (nonatomic, strong) NSString* colorScheme;
@property (nonatomic) BOOL lineNumbers;
@property (nonatomic) BOOL wordWrap;

// Saves settings to disk.
- (void)saveStateToDisk;

// tmp
// Returns a sample file.
+ (id<File>)getSampleFile;

@end
