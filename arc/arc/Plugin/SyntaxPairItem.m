//
//  SyntaxPairItem.m
//  arc
//
//  Created by omer iqbal on 22/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "SyntaxPairItem.h"

@implementation SyntaxPairItem
@synthesize name = _name, capturableScopes = _capturableScopes;

-(id)initWithBegin:(NSString *)begin End:(NSString *)end Name:(NSString *)name CPS:(NSArray *)cps BeginCaptures:(NSDictionary *)beginCaptures EndCaptures:(NSDictionary *)endCaptures ContentName:(NSString *)contentName EmbedPatterns:(id<SyntaxPatternsDelegate>)patterns{
    if (self = [super init]) {
        _begin = begin;
        _end = end;
        _name = name;
        _capturableScopes = cps;
        _beginCaptures = beginCaptures;
        _endCaptures = endCaptures;
        _contentName = contentName;
        _patterns = patterns;
    }
    return self;
}

-(SyntaxMatchStore*)parseContent:(NSString *)content WithRange:(NSRange)range {
    
    SyntaxMatchStore* store = [[SyntaxMatchStore alloc] init];

    [self addCaptures:_beginCaptures
              Pattern:_begin
              toStore:store
              Content:content
                Range:range];
    
    [self addCaptures:_endCaptures
              Pattern:_end
              toStore:store
              Content:content
                Range:range];
    SyntaxParserResult* resName = [[SyntaxParserResult alloc] initWithScope:_name Ranges:[NSMutableArray array] CPS:_capturableScopes];

    NSRegularExpression* beginRegex = [RegexUtils regexForPattern:_begin];
    NSRegularExpression* endRegex = [RegexUtils regexForPattern:_end];
    
    NSRange beginRange = [RegexUtils findFirstPatternWithRegex:beginRegex
                                                         range:range
                                                       content:content];
    if (beginRange.location >= content.length) {
        return store;
    }
    
    NSRange endRange;
    do {
        CFIndex bEnds = beginRange.location + beginRange.length;
        NSRange residue = NSMakeRange(bEnds, content.length - bEnds);
        endRange = [RegexUtils findFirstPatternWithRegex:endRegex
                                                   range:residue
                                                 content:content];
        if (endRange.location >= content.length || NSEqualRanges(endRange, NSMakeRange(0, 0))) {
            break;
        }
        CFIndex eEnds = endRange.location +endRange.length;
           NSRange nameRange = NSMakeRange(beginRange.location, eEnds - beginRange.location);
        if (_name) {
         
            [resName.ranges addObject:[Utils valueFromRange:nameRange]];
        }
        if (_patterns) {
//            [store mergeWithStore:[_patterns parseResultsForContent:content Range:nameRange]];
            
        }
        residue = NSMakeRange(eEnds, content.length - eEnds);
        beginRange = [RegexUtils findFirstPatternWithRegex:beginRegex
                                        range:residue
                                      content:content];
        //NSLog(@"%@ %@",[Utils valueFromRange:beginRange],[Utils valueFromRange:endRange]);
        
    } while (beginRange.location < content.length && !NSEqualRanges(endRange, beginRange));
    if (_name) {
        [store addParserResult:resName];

    }
    return store;
}

-(void)processForBegin:(NSRange)brange End:(NSRange)erange Store:(SyntaxMatchStore*)store {
   
}

-(void)addCaptures:(NSDictionary*)captures
           Pattern:(NSString*)regexPattern
           toStore:(SyntaxMatchStore*)store
           Content:(NSString*)content
             Range:(NSRange)range
{
    if (!captures) {
        return;
    }
    for (NSNumber* k in captures) {
        NSArray* captureMatches = [RegexUtils foundPattern:regexPattern capture:[k intValue] range:range content:content];
        NSDictionary* captureDict = [captures objectForKey:k];
        NSString* scope = [captureDict objectForKey:@"name"];
        NSArray* cps = [captureDict objectForKey:@"capturableScopes"];
        SyntaxParserResult* result = [[SyntaxParserResult alloc] initWithScope:scope Ranges:captureMatches CPS:cps];
        [store addParserResult:result];
    }
}
- (ScopeRange*)forwardParse:(NSString *)content WithResidue:(NSRange)range OverlayScopes:(NSArray *)overlays {
    if ([overlays containsObject:_capturableScopes[0]]) {
        NSRange beginRange = [RegexUtils findFirstPattern:_begin range:range content:content];
        if (beginRange.location >= content.length) {
            return nil;
        }
        CFIndex bEnds = beginRange.location + beginRange.length;
        NSRange bResidue = NSMakeRange(bEnds, content.length - bEnds);
        NSRange endRange = [RegexUtils findFirstPattern:_end range:bResidue content:content];
        if (endRange.location >= content.length || NSEqualRanges(endRange, NSMakeRange(0, 0))) {
            return nil;
        }
        CFIndex eEnds = endRange.location + endRange.length;
        NSRange pairRange = NSMakeRange(beginRange.location, eEnds - beginRange.location);
        return [ScopeRange scope:_name Range:pairRange CPS:_capturableScopes];
    }
    return nil;
}
- (SyntaxMatchStore*)storeForwardParse:(NSString*)content WithResidue:(NSRange)range OverlayScopes:(NSArray*)overlays {
    return nil;
}
@end
