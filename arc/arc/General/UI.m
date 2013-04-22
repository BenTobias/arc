//
//  UI.m
//  arc
//
//  Created by Yong Michael on 21/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "UI.h"

@implementation UI
+ (void)exec
{
    [UI navigationBarAppearance];
    [UI barButtonItemAppearance];
    [UI toolBarAppearance];
}

+ (UIColor *)navigationBarColor
{
    return [Utils colorWithHexString:@"272821"];
}

+ (UIColor *)navigationBarButtonColor
{
    return [Utils colorWithHexString:@"151512"];
}

+ (UIColor *)toolBarColor
{
    return [Utils colorWithHexString:@"191919"];
}

+ (UIColor *)fontColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)tableViewSectionHeaderColor
{
    return [Utils colorWithHexString:@"CC272821"];
}

+ (NSString *)fontName
{
    return @"Helvetica Neue";
}

+ (NSString *)fontNameBold
{
    return @"Helvetica Neue Bold";
}


+ (void)navigationBarAppearance
{
    [[UINavigationBar appearance] setBackgroundImage:[Utils imageWithColor:[UI navigationBarColor]]
                                       forBarMetrics:UIBarMetricsDefault];
    // NavBar title
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UI fontColor], UITextAttributeTextColor,
                                                          [UIColor colorWithRed:0 green:0 blue:0 alpha:0], UITextAttributeTextShadowColor,
                                                          [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
                                                          [UIFont fontWithName:[UI fontName] size:0.0], UITextAttributeFont,
                                                          nil]];
}

+ (void)barButtonItemAppearance
{
    [[UIBarButtonItem appearance] setBackgroundImage:[Utils imageWithColor:[UI navigationBarButtonColor]]
                                            forState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    
    // NavBar button titles
    [[UIBarButtonItem appearance] setTitleTextAttributes:[UI barButtonTitleTextAttribute]
                                                forState:UIControlStateNormal];
    
    // TODO
    // make back button arrow shaped.
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[Utils imageSized:CGRectMake(0, 0, 36, 36)
                                                                        withColor:[UI navigationBarButtonColor]]
                                                                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)]
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
}

+ (NSDictionary *)barButtonTitleTextAttribute
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [UI fontColor], UITextAttributeTextColor,
            [UIColor colorWithRed:0 green:0 blue:0 alpha:0], UITextAttributeTextShadowColor,
            [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
            [UIFont fontWithName:[UI fontName] size:15.0], UITextAttributeFont,
            nil];
}

+ (void)toolBarAppearance
{
    [[UIToolbar appearance] setBackgroundImage:[Utils imageWithColor:[UI toolBarColor]]
                            forToolbarPosition:UIToolbarPositionAny
                                    barMetrics:UIBarMetricsDefault];
}

+ (UIFont *)toolBarTitleFont
{
    return [UIFont fontWithName:[UI fontName] size:20];
}

+ (NSString *)folderImage
{
    return @"folder.png";
}

+ (NSString *)fileImage
{
    return @"file";
}

+ (NSString *)fileImageHighlighted
{
    return @"file_white";   
}

@end
