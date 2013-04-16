//
//  DragPointImageView.m
//  arc
//
//  Created by Benedict Liang on 14/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "DragPointImageView.h"

@implementation DragPointImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *dragPointImage = [UIImage imageNamed:@"leftDragPoint.png"];
        self.image = dragPointImage;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
