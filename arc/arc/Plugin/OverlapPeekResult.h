//
//  OverlapPeekResult.h
//  arc
//
//  Created by omer iqbal on 22/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
 enum SyntaxType{
     kNone,
    kSyntaxPair,
     kSyntaxSingle}
typedef SyntaxType;

@interface OverlapPeekResult : NSObject
@property NSRange beginRange;
@property NSRange endRange;
@property NSDictionary* syntaxItem;
@property NSRange matchRange;
@property SyntaxType type;
+(OverlapPeekResult*)resultWithBeginRange:(NSRange)br EndRange:(NSRange)er SyntaxItem:(NSDictionary*)si;
+ (OverlapPeekResult*)resultWithMatchRange:(NSRange)m SyntaxItem:(NSDictionary*)si;
@end
