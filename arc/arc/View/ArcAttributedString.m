//
//  ArcAttributedString.m
//  arc
//
//  Created by Yong Michael on 29/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "ArcAttributedString.h"
#import "ApplicationState.h"

@interface ArcAttributedString ()
@property (nonatomic, strong) NSMutableAttributedString *_attributedString;
@property (nonatomic, strong) NSMutableAttributedString *_plainAttributedString;
@property (nonatomic, strong) NSMutableDictionary *_attributesDictionary;
@property (nonatomic, strong) NSMutableDictionary *_appliedAttributesDictionary;

// Font
@property (nonatomic, strong) NSString *fontFamily;
@property (nonatomic) int fontSize;
- (void)updateFontProperties;
@end

@implementation ArcAttributedString
@synthesize string = _string;
@synthesize stringRange = _stringRange;

- (id)initWithString:(NSString*)string
{
    self = [super init];
    if (self) {
        _string = string;
        _stringRange = NSMakeRange(0, _string.length);
        __attributedString = [[NSMutableAttributedString alloc]
                              initWithString:_string];
        
        __plainAttributedString = [[NSMutableAttributedString alloc]
                                  initWithString:_string];
        
        // Used to store(buffer) attributes
        __attributesDictionary = [NSMutableDictionary dictionary];
        __appliedAttributesDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithArcAttributedString:(ArcAttributedString *)arcAttributedString
{
    self = [super init];
    if (self) {
        _string = [arcAttributedString string];
        _stringRange = NSMakeRange(0, _string.length);
        _fontFamily = [arcAttributedString fontFamily];
        _fontSize = [arcAttributedString fontSize];
        __attributedString = [[NSMutableAttributedString alloc]
                              initWithAttributedString:[arcAttributedString attributedString]];
        
        __plainAttributedString = [[NSMutableAttributedString alloc]
                                   initWithAttributedString:[arcAttributedString plainAttributedString]];
        
        // Used to store (buffer attributes)
        __attributesDictionary = [NSMutableDictionary dictionaryWithDictionary:
                                 [arcAttributedString attributesDictionary]];
        __appliedAttributesDictionary = [NSMutableDictionary dictionaryWithDictionary:
                                        [arcAttributedString appliedAttributesDictionary]];
    }
    return self;
}

- (void)removeAttributesForSettingKey:(NSString*)settingKey
{
    NSUInteger *toRemove = 0;
    NSUInteger *toRemain = 0;
    for (NSString *sKey in __appliedAttributesDictionary) {
        if ([sKey isEqualToString:settingKey]) {
            toRemove += [[self settingsAppliedAttributeForSettingsKey:sKey] count];
        } else {
            toRemain += [[self settingsAppliedAttributeForSettingsKey:sKey] count];
        }
    }
    
    if (toRemove > toRemain) {
        __attributedString = [__plainAttributedString mutableCopy];
        for (NSString *sKey in __appliedAttributesDictionary) {
            if ([sKey isEqualToString:settingKey]) {
                continue;
            }

            for (ArcAttribute *attribute in [__attributesDictionary objectForKey:sKey]) {
                if (!attribute.value) {
                    continue;
                }
                
                [__attributedString addAttribute:attribute.type
                                           value:attribute.value
                                           range:attribute.range];
            }            
        }
    } else {
        for (ArcAttribute *attribute in [__appliedAttributesDictionary objectForKey:settingKey]) {
            [__attributedString removeAttribute:attribute.type
                                          range:attribute.range];
        }
    }
    
    // remove object from dictionary
    [__appliedAttributesDictionary removeObjectForKey:settingKey];
}

- (NSAttributedString*)attributedString
{
    NSMutableArray* removedProperties = [NSMutableArray array];
    for (NSString* property in __attributesDictionary) {

        for (ArcAttribute *attribute in [__attributesDictionary objectForKey:property]) {
            if (!attribute.value) {
                continue;
            }
            
            [__attributedString addAttribute:attribute.type
                                       value:attribute.value
                                       range:attribute.range];
        }
        
        // Move attributes to appliedAttributes dictionary
        [[self settingsAppliedAttributeForSettingsKey:property]
            addObjectsFromArray:[self settingsAttributeForSettingsKey:property]];
        [removedProperties addObject:property];
      
    }
    for (NSString* property in removedProperties) {
        [__attributesDictionary removeObjectForKey:property];
    }

    return __attributedString;
}

- (NSAttributedString*)plainAttributedString
{
    return [[NSAttributedString alloc]
            initWithAttributedString:__plainAttributedString];
}

# pragma mark - getters

- (NSDictionary*)attributesDictionary
{
    return [NSDictionary dictionaryWithDictionary:__attributesDictionary];
}


- (NSDictionary*)appliedAttributesDictionary
{
    return [NSDictionary dictionaryWithDictionary:__appliedAttributesDictionary];
}

# pragma mark - AttributedString Mutator Methods

- (void)setForegroundColor:(UIColor *)color
                   OnRange:(NSRange)range
                ForSetting:(NSString*)settingKey
{
    NSMutableArray *settingAttributes =
    [self settingsAttributeForSettingsKey:settingKey];
    
    [settingAttributes addObject:[[ArcAttribute alloc] initWithType:NSForegroundColorAttributeName
                                                          withValue:color
                                                            onRange:range]];
}

- (void)setBackgroundColor:(UIColor *)color
                   OnRange:(NSRange)range
                ForSetting:(NSString *)settingKey
{
    NSMutableArray *settingAttributes =
    [self settingsAttributeForSettingsKey:settingKey];
    
    
    [settingAttributes addObject:[[ArcAttribute alloc] initWithType:NSBackgroundColorAttributeName
                                                          withValue:color
                                                            onRange:range]];
}

# pragma mark - Namespaced Attributes

- (NSMutableArray*)settingsAttributeForSettingsKey:(NSString*)settingKey
{
    NSMutableArray *settingAttributes =
    [__attributesDictionary objectForKey:settingKey];

    if (settingAttributes == nil) {
        settingAttributes = [NSMutableArray array];
        [__attributesDictionary setValue:settingAttributes
                                  forKey:settingKey];
    }

    return settingAttributes;
}

- (NSMutableArray*)settingsAppliedAttributeForSettingsKey:(NSString*)settingKey
{
    NSMutableArray *settingAppliedAttributes =
    [__appliedAttributesDictionary objectForKey:settingKey];
    
    if (settingAppliedAttributes == nil) {
        settingAppliedAttributes = [NSMutableArray array];
        [__appliedAttributesDictionary setValue:settingAppliedAttributes
                                         forKey:settingKey];
    }
    
    return settingAppliedAttributes;
}

# pragma mark - FontSize/Family Methods

- (void)setFontSize:(int)fontSize
{
    _fontSize = fontSize;
    [self updateFontProperties];
    
}

- (void)setFontFamily:(NSString *)fontFamily
{
    _fontFamily = fontFamily;
    [self updateFontProperties];
}

- (void)updateFontProperties
{
    // Remove old font property
    [__attributedString removeAttribute:NSFontAttributeName
                                  range:_stringRange];
    
    [__plainAttributedString removeAttribute:NSFontAttributeName
                                  range:_stringRange];
    
    // update font to new property
    UIFont *font = [UIFont fontWithName:_fontFamily size:_fontSize];
    
    [__attributedString addAttribute:NSFontAttributeName
                               value:font
                               range:_stringRange];

    [__plainAttributedString addAttribute:NSFontAttributeName
                               value:font
                               range:_stringRange];
    
}

#pragma mark - methods used by folding. Deprecated right now

- (NSArray*)rangesFromTransformWithAttribRange:(NSRange)attribRange removedRange:(NSRange)rmRange
{
    NSRange newAttribRange = {NSNotFound,0};
    NSRange newAttribRange1 = {NSNotFound, 0};
    NSArray* res = nil;
    
    //check if attribRange intersects range
    
    if ([Utils isSubsetOf:rmRange arg:attribRange]) {
        //do nothing.
    }
    else if ([Utils isIntersectingWith:rmRange And:attribRange]) {
        // if intersecting keep attribRange /\ !rmRange
        NSArray* cleanedRangeArray = [Utils rangeDifferenceBetween:attribRange And:rmRange];
        
        newAttribRange = NSRangeFromString([cleanedRangeArray objectAtIndex:0]);
        
        if (cleanedRangeArray.count == 2) {
            newAttribRange1 = NSRangeFromString([cleanedRangeArray objectAtIndex:1]);
            res = @[NSStringFromRange(newAttribRange), NSStringFromRange(newAttribRange1)];
        } else {
            res = @[NSStringFromRange(newAttribRange)];
        }
        
    } else {
        res = @[NSStringFromRange(attribRange)];
    }
    NSMutableArray* postTranslateRes = [NSMutableArray array];
    for (NSString* rs in res) {
        NSRange range = NSRangeFromString(rs);
        NSRange translatedRange = range;
        if (range.location >= rmRange.location) {
            translatedRange = NSMakeRange(range.location - rmRange.length, range.length);
        }
        
        [postTranslateRes addObject:NSStringFromRange(translatedRange)];
    }
    
    return postTranslateRes;
}

- (void)produceAttributes:(NSMutableDictionary*)newAttribDict
                     From:(NSDictionary*)attribDict
         WithRemovedRange:(NSRange)rmRange {
    
    for (NSString *property in attribDict) {
        NSMutableArray *attributes = [NSMutableArray array];
        for (NSDictionary* attribute in [attribDict objectForKey:property]) {
            NSRange attribRange = NSRangeFromString([attribute objectForKey:@"range"]);
            NSArray* transformedRanges = [self rangesFromTransformWithAttribRange:attribRange removedRange:rmRange];
            for (NSString* rs in transformedRanges) {
                NSRange iterRange = NSRangeFromString(rs);
                if (iterRange.location < _string.length) {
                    NSMutableDictionary* newAttrib = [NSMutableDictionary dictionaryWithDictionary:attribute];
                    [newAttrib setObject:rs forKey:@"range"];
                    [attributes addObject:newAttrib];
                }
                
            }
        }
        [newAttribDict setObject:attributes forKey:property];
    }
}

- (ArcAttributedString*)arcStringWithRemovedRange:(NSRange)range {
    int rangeEnds = range.location + range.length;
    
    // create str not including range.
    NSMutableString* str = [NSMutableString stringWithString:[_string substringToIndex:range.location]];
    [str appendString:[_string substringFromIndex:rangeEnds]];
    
    // create arcString from str
    ArcAttributedString* rmArcString = [[ArcAttributedString alloc] initWithString:str];
    NSMutableDictionary* rmArcStringAttribDictionary = [NSMutableDictionary dictionary];
    
    // iterate through attributes and transform attributes for the new ranges
    [self produceAttributes:rmArcStringAttribDictionary From:[[NSDictionary alloc] initWithDictionary:__attributesDictionary copyItems:YES] WithRemovedRange:range];
    
    [self produceAttributes:rmArcStringAttribDictionary From:[[NSDictionary alloc] initWithDictionary:__appliedAttributesDictionary copyItems:YES] WithRemovedRange:range];
    
    rmArcString._attributesDictionary = rmArcStringAttribDictionary;
    return rmArcString;
}
@end
