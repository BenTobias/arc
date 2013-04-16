//
//  SkyDriveFile.m
//  arc
//
//  Created by Jerome Cheng on 14/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "SkyDriveFile.h"

@implementation SkyDriveFile
@synthesize name=_name, identifier=_identifier, size=_size, extension=_extension;

- (id)initWithName:(NSString *)name identifier:(NSString *)identifier size:(float)size
{
    if (self = [super init]) {
        _name = name;
        _identifier = identifier;
        _size = size;
        _extension = [name pathExtension];
    }
    return self;
}


@end
