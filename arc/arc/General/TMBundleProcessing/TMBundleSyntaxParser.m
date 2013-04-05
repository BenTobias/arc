//
//  TMBundleSyntaxParser.m
//  arc
//
//  Created by Benedict Liang on 26/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "TMBundleSyntaxParser.h"

@implementation TMBundleSyntaxParser

#pragma mark - Initializers

+ (NSDictionary*)syntaxPList:(NSString*)TMBundleName {
    
    NSURL *syntaxFileURL = [[NSBundle mainBundle] URLForResource:TMBundleName withExtension:nil];
   
    return [NSDictionary dictionaryWithContentsOfURL:syntaxFileURL];
}

+ (NSDictionary*)fileTypesToBundles {
    NSURL* bundleConf = [[NSBundle mainBundle] URLForResource:@"BundleConf.plist" withExtension:nil];
    
    NSDictionary* extToBundle = [NSDictionary dictionaryWithContentsOfURL:bundleConf];
    
    return [extToBundle objectForKey:@"fileTypes"];
}

+ (NSDictionary*)plistForExt:(NSString *)fileExt {
    
    NSArray* legitBundles = [[TMBundleSyntaxParser fileTypesToBundles] objectForKey:fileExt];
    
    if (legitBundles) {
    
        NSString* bundleName = [legitBundles objectAtIndex:0];
        
        return [TMBundleSyntaxParser syntaxPList:bundleName];
    
    } else {
        NSLog(@"Appropriate bundle not found");
        
        return nil;
    }
}
@end
