//
//  Constants.h
//  arc
//
//  Created by Yong Michael on 23/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject
// Sizes
extern const float SIZE_LEFTBAR_WIDTH;
extern const float SIZE_TOOLBAR_HEIGHT;
extern const CGSize SIZE_POPOVER;
extern const float SIZE_TOOLBAR_ICON_WIDTH;

// Defaults
extern const CGColorRef* DEFAULT_TEXT_COLOR;

// App State
extern NSString* const FILE_APP_STATE;
extern NSString* const KEY_CURRENT_FOLDER;
extern NSString* const KEY_CURRENT_FILE;
extern NSString* const KEY_FONTS;
// Settings
extern NSString* const KEY_SETTINGS_ROOT;
extern NSString* const KEY_FONT_FAMILY;
extern NSString* const KEY_FONT_SIZE;
extern NSString* const KEY_LINE_NUMBERS;
extern NSString* const KEY_WORD_WRAP;

// Values
extern const int THRESHOLD_LONG_SETTING_LIST;

// Default Folder Names
extern NSString* const FOLDER_EXTERNAL_APPLICATIONS;
extern NSString* const FOLDER_ROOT;
extern NSString* const FOLDER_DROPBOX_ROOT;

// API Keys
extern NSString* const CLOUD_DROPBOX_KEY;
extern NSString* const CLOUD_DROPBOX_SECRET;
extern NSString* const CLOUD_SKYDRIVE_KEY;

// SkyDrive scopes
extern NSString* const SKYDRIVE_SCOPE_SIGNIN;
extern NSString* const SKYDRIVE_SCOPE_READ_ACCESS;

// Syntaxes File List
extern NSString* const SYNTAXES_FILE_LIST;

// Bundle Conf
extern NSString* const BUNDLE_CONF;


// Tabs
extern const int TAB_DROPBOX;
extern const int TAB_DOCUMENTS;
extern const int TAB_SETTINGS;
@end
