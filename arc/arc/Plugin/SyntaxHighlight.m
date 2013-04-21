//
//  SyntaxHighlight.m
//  arc
//
//  Created by omer iqbal on 7/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "SyntaxHighlight.h"
#define SYNTAX_KEY @"sh"

@interface SyntaxHighlight ()
@property (nonatomic) BOOL isAlive;
@property (nonatomic) BOOL matchesDone;
@property ParcoaParser* pairParsers;
@property NSMutableArray* parserAccum;
@end

@implementation SyntaxHighlight
@synthesize factory = _factory;
@synthesize delegate = _delegate;

- (id)initWithFile:(id<File>)file andDelegate:(id<CodeViewControllerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _currentFile = file;
        _overlays = @[@"string",@"comment"];
        _bundle = [TMBundleSyntaxParser plistForExt:[file extension]];
        
        _isAlive = YES;
        _matchesDone = NO;
        
        if ([[file contents] isKindOfClass:[NSString class]]) {
            _content = (NSString*)[file contents];
            _splitContent = [_content componentsSeparatedByString:@"\n"];
        }
        
        //reset ranges
        nameMatches = [NSDictionary dictionary];
        captureMatches = [NSDictionary dictionary];
        beginCMatches = [NSDictionary dictionary];
        endCMatches = [NSDictionary dictionary];
        pairMatches = [NSDictionary dictionary];
        contentNameMatches = [NSDictionary dictionary];
        overlapMatches = [NSDictionary dictionary];
        _parserAccum = [NSMutableArray array];
    }
    return self;
}
- (NSRegularExpression *)regexForPattern:(NSString *)pattern {
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                  options:NSRegularExpressionUseUnixLineSeparators|NSRegularExpressionAnchorsMatchLines
                                  error:&error];
    return regex;
}

- (NSArray*)foundPattern:(NSString*)pattern
                   range:(NSRange)range
{
    
    return [self foundPattern:pattern
                      capture:0
                        range:range];
}

- (NSRange)findFirstPatternWithRegex:(NSRegularExpression *)regex
                      range:(NSRange)range
{   
    return [self findFirstPatternWithRegex:regex range:range content:_content];
}

- (NSRange)findFirstPatternWithRegex:(NSRegularExpression *)regex
                               range:(NSRange)range
                             content:(NSString*)content
{
    if ((range.location + range.length <= [content length]) &&
        (range.length > 0) &&
        (range.length <= [content length]))
    {
        return [regex rangeOfFirstMatchInString:content
                                        options:0
                                          range:range];
    } else {
        return NSMakeRange(NSNotFound, 0);
    }
}
- (NSRange)findFirstPattern:(NSString*)pattern
                      range:(NSRange)range
                    content:(NSString*)content
{
    
    NSRegularExpression *regex = [self regexForPattern:pattern];
    
    if ((range.location + range.length <= [content length]) &&
        (range.length > 0) &&
        (range.length <= [content length]))
    {
        //NSLog(@"findFirstPattern:   %d %d",r.location,r.length);
        return [regex rangeOfFirstMatchInString:content
                                        options:0
                                          range:range];
    } else {
        NSLog(@"index out of bounds in regex. findFirstPatten:%@",[Utils valueFromRange:range]);
        return NSMakeRange(NSNotFound, 0);
    }
    
}

- (NSArray*)foundPattern:(NSString*)pattern
                 capture:(int)capture
                   range:(NSRange)range
{
    NSMutableArray* results = [[NSMutableArray alloc] init];
    NSRegularExpression *regex = [self regexForPattern:pattern];
    
    if (range.location + range.length <= [_content length]) {
        
        NSArray* matches = [regex matchesInString:_content
                                          options:0
                                            range:range];
        
        for (NSTextCheckingResult *match in matches) {
            if (capture < [match numberOfRanges]) {
                NSRange range = [match rangeAtIndex:capture];
                
                if (range.location != NSNotFound) {
                    NSValue* v = [NSValue value:&range
                                   withObjCType:@encode(NSRange)];
                    [results addObject:v];
                }
            }
            
        }
        
    } else {
        NSLog(@"index error in capture:%d %d", range.location, range.length);
    }
    
    return results;
}

- (void)styleOnRange:(NSRange)range
              fcolor:(UIColor*)fcolor
              output:(ArcAttributedString*)output
{
    [output setForegroundColor:fcolor
                       OnRange:range
                    ForSetting:SYNTAX_KEY];
}

- (NSArray*)capturableScopes:(NSString*)name
{
    NSArray *splitScopes = [name componentsSeparatedByString:@"."];
    NSString *accum = nil;
    NSMutableArray *scopes = [NSMutableArray array];
    
    for (NSString*  s in splitScopes) {
        if (!accum) {
            accum = s;
        } else {
            accum = [accum stringByAppendingFormat:@".%@",s];
        }
        [scopes addObject:accum];
    }
    return scopes;
}

- (void)applyStyleToScope:(NSString*)name
                    range:(NSRange)range
                   output:(ArcAttributedString*)output
                     dict:(NSObject*)dict
                    theme:(NSDictionary*)theme
               capturableScopes:(NSArray*)cpS
{

  
    for (NSString *s in cpS) {
        NSDictionary* style = [(NSDictionary*)[theme objectForKey:@"scopes"] objectForKey:s];
        if (![dict isEqual:(NSObject*)overlapMatches] && [_overlays containsObject:s]) {
            [self addRange:range
                                      scope:s
                                       dict:overlapMatches
                           capturableScopes:@[s]];
        }
        
        if (style) {
            UIColor *fg = [style objectForKey:@"foreground"];
            [self styleOnRange:range
                        fcolor:fg
                        output:output];
        }
    }
}

- (NSDictionary*)findCaptures:(NSDictionary*)captures
                      pattern:(NSString*)match
                        range:(NSRange)range
{
    
    // Original Code
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    NSArray *captureM = nil;
    for (id k in captures) {
        int i = [k intValue];
        captureM = [self foundPattern:match capture:i range:range];
        NSDictionary* capturedSyntaxItem = [captures objectForKey:k];
        NSString* scope = [capturedSyntaxItem objectForKey:@"name"];
        NSArray* capturableScopes = [capturedSyntaxItem objectForKey:@"capturableScopes"];
        NSDictionary *scopeData = @{@"ranges":captureM, @"capturableScopes":capturableScopes};
        [dict setObject:scopeData forKey:scope];
        
    }

    return dict;
}

- (void)applyStylesTo:(ArcAttributedString*)output
           withRanges:(NSDictionary*)pairs
            withTheme:(NSDictionary*)theme
{
    if (pairs) {
        for (NSString* scope in pairs) {
            NSArray* ranges = [[pairs objectForKey:scope] objectForKey:@"ranges"];
            NSArray* capturableScopes = [[pairs objectForKey:scope] objectForKey:@"capturableScopes"];
            for (NSValue *v in ranges) {
                NSRange range;
                [v getValue:&range];
                [self applyStyleToScope:scope
                                  range:range
                                 output:output
                                   dict:pairs
                                  theme:theme
                       capturableScopes:capturableScopes];
            }
        }
    }
    
}

- (void)merge:(NSDictionary*)dictionary1
                withDictionary:(NSMutableDictionary*)dictionary2
{   
    for (id k in dictionary1) {
        [dictionary2 setValue:[dictionary1 objectForKey:k]
               forKey:k];
    }

}

- (void) addRange:(NSRange)range
            scope:(NSString*)scope
             dict:(NSMutableDictionary*)matchesStore
 capturableScopes:(NSArray*)cpS
{
    
    NSMutableArray* ranges = [[matchesStore objectForKey:scope] objectForKey:@"ranges"];
    if (ranges) {
        [ranges addObject:[Utils valueFromRange:range]];
    } else {
        if (scope) {
            NSMutableDictionary* vals = [NSMutableDictionary dictionary];
            [vals setObject:cpS forKey:@"capturableScopes"];
            [vals setObject:[NSMutableArray arrayWithObject:[Utils valueFromRange:range]] forKey:@"ranges"];
            
            [matchesStore setObject:vals
                             forKey:scope];
        }
    }

}

- (id)repositoryRule:(NSString*)rule
{
    NSDictionary* repo = [_bundle objectForKey:@"repository"];
    return [repo objectForKey:rule];
}

- (NSArray*)externalInclude:(NSString*)name
{
    NSDictionary *includedBundle = [TMBundleSyntaxParser plistByName:name];
    return [includedBundle objectForKey:@"patterns"];
}

- (NSArray*)resolveInclude:(NSString*)include
{
    //NSLog(@"%@",include);
    if ([include isEqualToString:@"$base"]) {
        //returns top most pattern
        return [_bundle objectForKey:@"patterns"];
    } else if ([include characterAtIndex:0] == '#') {
        // Get rule from repository
        NSString *str = [include substringFromIndex:1];
        
        if ([str isEqualToString:@"comment"]) {
            NSLog(@"%@", [self repositoryRule:str]);
        }
        
        id rule = [self repositoryRule:str];
        
        if (rule) {
            return [NSArray arrayWithObject:rule];
        } else {
            return nil;
        }
    } else {
        //TODO: find scope name of another language
        return [self externalInclude:include];
    }
    
}
- (BOOL)isEscapedOnRange:(NSRange)range {
    if ([Utils isContainedByRange:NSMakeRange(0, _content.length) Index:range.location-1]) {
        unichar c =  [_content characterAtIndex:range.location-1];
        return c=='\\';
    }
    return NO;
}

- (ParcoaParser*)parserForRegex:(NSRegularExpression*)regex WithName:(NSString*)name WithScope:(NSString*)scope {
    return [ParcoaParser parserWithBlock:^ParcoaResult*(NSString *input){
        NSRange beginRange = [self findFirstPatternWithRegex:regex
                                                       range:NSMakeRange(0, input.length)
                                                     content:input];
        if (beginRange.location >= _content.length || beginRange.length == 0) {
            return [ParcoaResult failWithRemaining:input expected:input];
        } else {
            CFIndex bEnds = beginRange.location+beginRange.length+1;
            NSString* remaining = [input substringFromIndex:bEnds];
            NSString* key = nil;
            if (!scope) {
                key = @"unknown";
            } else {
                key = scope;
            }
            return [ParcoaResult ok:@{@"scope":key,@"range":[Utils valueFromRange:beginRange]} residual:remaining expected:[ParcoaExpectation unsatisfiable]];
        }
    } name:name summary:nil];
}
- (void)parsePairsForInput:(NSString*)input {
    ParcoaParser* pairs = [Parcoa many:[SyntaxHighlight chooseBetween:_parserAccum]];
    NSLog(@"%@",_parserAccum);
    ParcoaResult* result = [pairs parse:input];
    NSLog(@"results:%@", result.value);
    
}

//chooses from an array of parsers, which pair parser returns the smallest location
//pairParser = beginParser >> endParser
//chooseBetween = minRange([pairParsers])
//
+ (ParcoaParser*)chooseBetween:(NSArray*)parsers {
    return [ParcoaParser parserWithBlock:^ParcoaResult* (NSString* input){
        NSRange first = NSMakeRange(NSNotFound, 0);
        NSArray* val = nil;
        for (ParcoaParser* parser in parsers) {
            ParcoaResult* result = [parser parse:input];
            if (result.isOK) {
                NSArray* pair = result.value;
                NSRange resRange = [Utils rangeFromValue:[(NSDictionary*)pair[0] objectForKey:@"range"]];
                if (resRange.location < first.location) {
                    first = resRange;
                    val = result.value;
                }
            }
        }
        if (!val || first.location == NSNotFound || first.location > input.length || first.length == 0) {
            return [ParcoaResult failWithRemaining:input expected:[ParcoaExpectation unsatisfiable]];
        }
        return [ParcoaResult ok:val residual:[input substringFromIndex:first.location] expected:[ParcoaExpectation unsatisfiable]];
    } name:@"chooseBetween" summary:nil];
}

- (ParcoaParser*)manyChoose:(ParcoaParser*)chooseBetween {
    return [ParcoaParser parserWithBlock:^ParcoaResult* (NSString* input) {
        NSMutableArray* accum = [NSMutableArray array];
        ParcoaResult* result = [chooseBetween parse:input];
        CFIndex offset = 0;
        
        while (result.isOK && offset < _content.length) {
            
            NSArray* pair = result.value;
            NSRange resBeginRange = [Utils rangeFromValue:[(NSDictionary*)pair[0] objectForKey:@"range"]];
            resBeginRange.location+=offset;
            offset+= resBeginRange.location +resBeginRange.length;
            NSRange resEndRange = [Utils rangeFromValue:[(NSDictionary*)pair[1] objectForKey:@"range"]];
            resEndRange.location+=offset;
            offset+= resEndRange.location +resEndRange.length;
            NSString* scope = [(NSDictionary*)pair[0] objectForKey:@"scope"];
            [accum addObject:@{@"begin":[Utils valueFromRange:resBeginRange], @"end":[Utils valueFromRange:resEndRange], @"scope":scope}];
            //NSLog(@"%@",accum);
            result = [chooseBetween parse:result.residual];
        }
        return [ParcoaResult ok:accum residual:result.residual expected:[ParcoaExpectation unsatisfiable]];
    } name:@"manyChoose" summary:nil];
}


- (NSDictionary*)peekMinForItems:(NSArray*)syntaxItems WithRange:(NSRange)range {
    NSRange min = NSMakeRange(_content.length-1, 0);
    NSDictionary* minSyntax = nil;
    for (NSDictionary* syntaxItem  in syntaxItems) {
        NSString* begin = [syntaxItem objectForKey:@"begin"];
       
        NSRange result = [self findFirstPattern:begin range:range content:_content];
        if (min.location > result.location) {
            min = result;
            minSyntax = syntaxItem;
        }
    }
    return minSyntax;
}

- (void)handleOverlaps:(NSArray*)overlaps {
    NSDictionary* syntaxItem = [self peekMinForItems:overlaps WithRange:NSMakeRange(0, _content.length)];
    if (syntaxItem) {
         NSString* name = [syntaxItem objectForKey:@"name"];
        NSString* begin = [syntaxItem objectForKey:@"begin"];
        NSString* end = [syntaxItem objectForKey:@"end"];
        
    }
}
- (void)processPairRange:(NSRange)contentRange
                    item:(NSDictionary*)syntaxItem
                  output:(ArcAttributedString*)output
{
    /*
     Algo finds a begin match and an end match (from begin to content's end),
     reseting the next begin to after end, until no more matches are found or end > content
     Also applies nested patterns recursively
     */
    NSString* begin = [syntaxItem objectForKey:@"begin"];
    NSString* end = [syntaxItem objectForKey:@"end"];
    NSString* name = [syntaxItem objectForKey:@"name"];
    
    NSRegularExpression *beginRegex = [self regexForPattern:begin];

    NSRegularExpression *endRegex = [self regexForPattern:end];
    
    NSRange brange = [self findFirstPatternWithRegex:beginRegex
                                      range:contentRange];
    NSArray* capturableScopes = [syntaxItem objectForKey:@"capturableScopes"];
    
    
    NSRange erange;
    do {
        // NSLog(@"traversing while brange:%@ erange:%@",
        // [NSValue value:&brange withObjCType:@encode(NSRange)],
        // [NSValue value:&erange withObjCType:@encode(NSRange)]);
        // using longs because int went out of range as NSNotFound returns MAX_INT, which fucks arithmetic
        long bEnds = brange.location + brange.length;
        if (contentRange.length > bEnds) {
            //HACK BELOW. BLAME TEXTMATE FOR THIS SHIT. IT MAKES COMMENTS WORK THOUGH
            //if ([self fixAnchor:end]) {
            //erange = NSMakeRange(bEnds, contentRange.length - bEnds);
            //} else {
            erange = [self findFirstPatternWithRegex:endRegex
                                               range:NSMakeRange(bEnds, contentRange.length - bEnds - 1)];
            //}
        } else {
            //if bEnds > contentRange.length, skip
            break;
        }
        
        long eEnds = erange.location + erange.length;
        NSArray *embedPatterns = [syntaxItem objectForKey:@"patterns"];
        
        //if there are characters between begin and end, and brange and erange are valid results
        if (eEnds > brange.location &&
            brange.location != NSNotFound &&
            erange.location != NSNotFound &&
            eEnds - brange.location< contentRange.length) {
            
            if (name) {
                [self addRange:NSMakeRange(brange.location, eEnds - brange.location)
                                       scope:name
                                        dict:pairMatches
                            capturableScopes:capturableScopes];
            }
            
            if ([syntaxItem objectForKey:@"contentName"]) {
                 [self addRange:NSMakeRange(bEnds, eEnds - bEnds)
                                              scope:name
                                               dict:contentNameMatches
                                   capturableScopes:capturableScopes];
            }
            
            if (embedPatterns &&
                contentRange.length < [_content length]) {
                //recursively apply iterPatterns to embedded patterns inclusive of begin and end
                // [self logs];
                // NSLog(@"recurring with %d %ld", brange.location, eEnds - brange.location);
                [self iterPatternsForRange:NSMakeRange(brange.location, eEnds - brange.location)
                                  patterns:embedPatterns
                                    output:output];
            }
        }
        
        brange = [self findFirstPatternWithRegex:beginRegex
                                           range:NSMakeRange(eEnds, contentRange.length - eEnds)];
        
    } while ([self whileCondition:brange e:erange cr:contentRange]);
    
    
}
- (void)iterPatternsForRange:(NSRange)contentRange
                    patterns:(NSArray*)patterns
                      output:(ArcAttributedString*)output
{
    for (int i =0; i < patterns.count; i++) {
        
    
    //  NSLog(@"patterns: %@",patterns);
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
//    dispatch_group_t group = dispatch_group_create();
//    
//    
//    dispatch_apply([patterns count], queue, ^(size_t i){
//        dispatch_group_async(group, queue, ^{
            if (_isAlive) {
                NSDictionary* syntaxItem = [patterns objectAtIndex:i];
                NSString *name = [syntaxItem objectForKey:@"name"];
                NSString *match = [syntaxItem objectForKey:@"match"];
                NSString *begin = [syntaxItem objectForKey:@"begin"];
                NSDictionary *beginCaptures = [syntaxItem objectForKey:@"beginCaptures"];
                NSString *end = [syntaxItem objectForKey:@"end"];
                NSDictionary *endCaptures = [syntaxItem objectForKey:@"endCaptures"];
                NSDictionary *captures = [syntaxItem objectForKey:@"captures"];
                NSString *include = [syntaxItem objectForKey:@"include"];
                NSArray* embedPatterns = [syntaxItem objectForKey:@"patterns"];
                NSArray* capturableScopes = [syntaxItem objectForKey:@"capturableScopes"];
                //case name, match
                if (name && match) {
                    NSArray *a = [self foundPattern:match
                                              range:contentRange];
                    [self merge:@{name: @{@"ranges":a, @"capturableScopes":capturableScopes}}
                                       withDictionary:nameMatches];
                }
                
                if (captures && match) {
                    [self merge:[self findCaptures:captures
                                                            pattern:match
                                                              range:contentRange]
                                          withDictionary:captureMatches];
                }
                
                if (beginCaptures && begin) {
                    [self merge:[self findCaptures:beginCaptures
                                                           pattern:begin
                                                             range:contentRange]
                         withDictionary:beginCMatches];
                }
                
                if (endCaptures && end) {
                    [self merge:[self findCaptures:endCaptures
                                                         pattern:end
                                                           range:contentRange]
                                       withDictionary:endCMatches];
                }
                
                //matching blocks
                if (begin && end) {
                    [self processPairRange:contentRange
                                      item:syntaxItem
                                    output:output];
                } else if (embedPatterns) {
                    [self iterPatternsForRange:contentRange patterns:embedPatterns output:output];
                }
                if (include) {
                    id includes = [self resolveInclude:include];
                    //NSLog(@"recurring for include: %@ with %d %d name:%@",includes, contentRange.location, contentRange.length, name);
                    if (contentRange.length <= [_content length] &&
                        includes) {
//                        [self iterPatternsForRange:contentRange
//                                          patterns:includes
//                                            output:output];
                    }
                }
            }
//        });
//    });
//    
//    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    }
    [self parsePairsForInput:[_content substringWithRange:contentRange]];
}

- (BOOL)whileCondition:(NSRange)brange e:(NSRange)erange cr:(NSRange)contentRange
{
    return (brange.location != NSNotFound &&
            erange.location + erange.length < contentRange.length &&
            erange.location > 0 &&
            !(NSEqualRanges(brange, NSMakeRange(0, 0)) &&
              (NSEqualRanges(erange, NSMakeRange(0, 0)))) &&
            (erange.location < contentRange.length - 1));
}

- (BOOL)fixAnchor:(NSString*)pattern
{
    //return [pattern stringByReplacingOccurrencesOfString:@"\\G" withString:@"\uFFFF"];
    // TODO: pattern for \\z : @"$(?!\n)(?<!\n)"
    return ([pattern rangeOfString:@"\\G"].location != NSNotFound ||
            [pattern rangeOfString:@"\\A"].location != NSNotFound);
}

- (void)updateView:(ArcAttributedString*)output
         withTheme:(NSDictionary*)theme
{
    if (self.delegate) {
        [self.delegate mergeAndRenderWith:output
                                  forFile:_currentFile
                                WithStyle:[theme objectForKey:@"global"]
                                  AndTree:_foldTree];
    }
}

- (void)logs
{
    NSLog(@"nameMatches: %@",nameMatches);
    NSLog(@"captureM: %@",captureMatches);
    NSLog(@"beginM: %@",beginCMatches);
    NSLog(@"endM: %@",endCMatches);
    NSLog(@"pairM: %@",pairMatches);
}

- (void)applyForeground:(ArcAttributedString*)output withTheme:(NSDictionary*)theme
{
    NSDictionary* global = [theme objectForKey:@"global"];
    UIColor* foreground = [global objectForKey:@"foreground"];
    if (foreground) {
        [self styleOnRange:NSMakeRange(0, [_content length])
                    fcolor:foreground
                    output:output];
    }
}

- (void)applyStylesTo:(ArcAttributedString*)output
            withTheme:(NSDictionary*)theme
{
    [output removeAttributesForSettingKey:SYNTAX_KEY];
    [self applyForeground:output withTheme:theme];
    [self applyStylesTo:output withRanges:pairMatches withTheme:theme];
    [self applyStylesTo:output withRanges:nameMatches withTheme:theme];
    [self applyStylesTo:output withRanges:captureMatches withTheme:theme];
    [self applyStylesTo:output withRanges:beginCMatches withTheme:theme];
    [self applyStylesTo:output withRanges:endCMatches withTheme:theme];
    [self applyStylesTo:output withRanges:contentNameMatches withTheme:theme];
    [self applyStylesTo:output withRanges:overlapMatches withTheme:theme];
}

- (void)execOn:(NSDictionary*)options
{
    _isAlive = YES;
    ArcAttributedString *output = [options objectForKey:@"attributedString"];
    _finalOutput = output;
    NSDictionary* theme = [options objectForKey:@"theme"];
    overlapMatches = [NSDictionary dictionary];

    if (!_matchesDone) {
        NSMutableArray* patterns = [NSMutableArray arrayWithArray:[_bundle objectForKey:@"patterns"]];
        NSDictionary* repo = [_bundle objectForKey:@"repository"];
        for (id k in repo) {
            [patterns addObject:[repo objectForKey:k]];
        }
        
        [self iterPatternsForRange:NSMakeRange(0, [_content length])
                          patterns:patterns
                            output:output];
    
        NSString* foldStart = [_bundle objectForKey:@"foldingStartMarker"];
        NSString* foldEnd = [_bundle objectForKey:@"foldingStopMarker"];

        
        if (foldStart && foldEnd) {
            _foldTree = [CodeFolding foldTreeForContent:_content
                                              foldStart:foldStart
                                                foldEnd:foldEnd
                                             skipRanges:[self rangeArrayForMatches:overlapMatches]
                                               delegate:self];
        }

        _matchesDone = YES;
    }
    
    // tell SH factory to remove self from thread pool.
    [_factory removeFromThreadPool:self];

    [self applyStylesTo:output withTheme:theme];
    [self updateView:output withTheme:theme];
}

- (void)kill
{
    _isAlive = NO;
    _matchesDone = NO;
}

- (void)testFoldsOnFoldRanges:(NSArray*)fR
                   foldStarts:(NSArray*)fS
                     foldEnds:(NSArray*)fE
{
 
    for (NSValue*v in fR) {
        NSRange r;
        [v getValue:&r];
        [self styleOnRange:r fcolor:[UIColor yellowColor] output:_finalOutput];
    }
    //NSLog(@"_foldStarts: %@",_foldStarts);
    for (NSValue* v in fS) {
        NSRange r;
        [v getValue:&r];
        [self styleOnRange:r fcolor:[UIColor redColor] output:_finalOutput];
    }
    
    //NSLog(@"_foldEnds: %@",_foldEnds);
    for (NSValue*v in fE) {
        NSRange r;
        [v getValue:&r];
        [self styleOnRange:r fcolor:[UIColor greenColor] output:_finalOutput];
    }
    
}

- (NSArray *)rangeArrayForMatches:(NSDictionary*)matches
{
    NSMutableArray* res = [NSMutableArray array];
    
    for (NSString* scope in matches) {
        NSArray* ranges = [(NSDictionary*)[matches objectForKey:scope] objectForKey:@"ranges"];
        [res addObjectsFromArray:ranges];
    }
    return res;
}


@end
