//
//  SyntaxPatterns.h
//  arc
//
//  Created by omer iqbal on 22/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyntaxItemProtocol.h"
#import "SyntaxPairItem.h"
#import "SyntaxSingleItem.h"
#import "SyntaxIncludeItem.h"
#import "SyntaxPatternItem.h"
#import "SyntaxPatternsDelegate.h"
@interface SyntaxPatterns : NSObject<SyntaxPatternsDelegate>

- (id)initWithBundlePatterns:(NSArray*)bundlePatterns Repository:(NSDictionary*)repo;

- (id)initWithBundlePatterns:(NSArray *)bundlePatterns Parent:(SyntaxPatterns*)p;

- (SyntaxMatchStore*)parseResultsForContent:(NSString*)content Range:(NSRange)range;

- (SyntaxMatchStore*)forwardParseForContent:(NSString *)content Range:(NSRange)range;

@property NSArray* patterns;
@property NSDictionary* repository;
@property SyntaxPatterns* parent;
@end
