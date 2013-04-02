//
//  ApplicationState.m
//  arc
//
//  Created by Benedict Liang on 19/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "ApplicationState.h"

@interface ApplicationState ()
@property NSMutableDictionary *_settings;
@end

static ApplicationState *sharedApplicationState = nil;

@implementation ApplicationState
@synthesize _settings = __settings;
@synthesize currentFileOpened = _currentFileOpened;
@synthesize currentFolderOpened = _currentFolderOpened;

+ (ApplicationState*)sharedApplicationState
{
    if (sharedApplicationState == nil) {
        sharedApplicationState = [[super allocWithZone:NULL] init];
    }
    return sharedApplicationState;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Defaults || Get Previous State from plist
        _currentFolderOpened = [RootFolder sharedRootFolder];
        _currentFileOpened = nil;
        _fontFamily = DEFAULT_FONT_FAMILY;
        _fontSize = DEFAULT_FONT_SIZE;
    }
    return self;
}

- (NSDictionary*)settings
{
    return [NSDictionary dictionaryWithDictionary:__settings];
}

// Returns a sample file.
+ (id<File>)getSampleFile
{
    return (id<File>)[[RootFolder sharedRootFolder] retrieveItemWithName:@"GameObject.h"];
}

@end
