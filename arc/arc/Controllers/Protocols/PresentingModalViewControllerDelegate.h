//
//  CloudPickerViewControllerDelegate.h
//  arc
//
//  Created by Jerome Cheng on 16/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PresentingModalViewControllerDelegate <NSObject>
- (void)modalViewControllerDone:(NSDictionary *)options;
@end
