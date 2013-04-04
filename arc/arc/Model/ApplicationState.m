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
        // Get the stored settings dictionary.
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentsPath = [[fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil] path];
        NSString *settingsPath = [documentsPath stringByAppendingPathComponent:FILE_APP_STATE];
        NSDictionary *storedState = [NSDictionary dictionaryWithContentsOfFile:settingsPath];
        NSDictionary *storedSettings = [storedState valueForKey:KEY_SETTINGS_ROOT];
    
        // Restore settings from the dictionary.
        _fontFamily = [storedSettings valueForKey:KEY_FONT_FAMILY];
        _fontSize = [(NSNumber*)[storedSettings valueForKey:KEY_FONT_SIZE] intValue];
        _wordWrap = (BOOL)[storedSettings valueForKey:KEY_WORD_WRAP];
        _lineNumbers = (BOOL)[storedSettings valueForKey:KEY_LINE_NUMBERS];
        
        // Restore application state.
        _currentFolderOpened = [RootFolder sharedRootFolder];
        _currentFileOpened = nil;
        _fonts = [storedState valueForKey:KEY_FONTS];
    }
    return self;
}

// Returns a sample file.
+ (id<File>)getSampleFile
{
    return (id<File>)[[RootFolder sharedRootFolder] retrieveItemWithName:@"GameObject.h"];
}

@end
