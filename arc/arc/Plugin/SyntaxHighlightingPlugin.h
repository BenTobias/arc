//
//  SyntaxHighlightingPlugin.h
//  arc
//
//  Created by Yong Michael on 6/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginDelegate.h"
#import "ArcAttributedString.h"
#import "TMBundleHeader.h"
#import "CodeViewControllerDelegate.h"
#import "File.h"

@interface SyntaxHighlightingPlugin : NSObject<PluginDelegate> {
    __block NSDictionary *nameMatches;
    __block NSDictionary *captureMatches;
    __block NSDictionary *beginCMatches;
    __block NSDictionary *endCMatches;
    __block NSDictionary *pairMatches;
    __block NSDictionary *contentNameMatches;
    __block NSDictionary *overlapMatches;
}
@property NSDictionary* theme;
@property (readonly) id<CodeViewControllerDelegate> delegate;
@property (readonly) id<File> currentFile;
@property (readonly) NSString* content;
@property (readonly) NSDictionary* bundle;
@property NSArray* overlays;

@end
