//
//  FoldTree.m
//  arc
//
//  Created by omer iqbal on 13/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "FoldTree.h"

@implementation FoldTree

- (id)initWithSortedNodes:(NSArray*)sn Node:(FoldNode*)node
{
    if (self = [super init]) {
        _node = node;
        _children = [NSMutableArray array];
        [self consWithSorted:sa];
    }
    return self;
}
- (id)initWithNodes:(NSArray *)nodes RootRange:(NSRange)range
{
    RootFoldNode* root = [[RootFoldNode alloc] initWithContentRange:range];
    
    return [self initWithSortedNodes:[FoldNode sortNodeArray:nodes] Node:root];
}

- (void)consWithSorted:(NSArray*)sortedNodes {
    
    NSMutableArray *accum = [NSMutableArray array];
//    NSRange r;
    FoldNode* elder;
    //NSLog(@"sortedRanges: %@",sortedRanges);
    if (sortedNodes.count > 0) {
        elder = [sortedNodes objectAtIndex:0];
        
        for (int i = 1; i < sortedNodes.count; i++) {
            FoldNode* node = [sortedNodes objectAtIndex:i];
            
            if ([Utils isSubsetOf:elder.contentRange arg:node.contentRange]) {
                [accum  addObject:node];
            }
            else {
                
                FoldTree* subTree = [[FoldTree alloc] initWithSortedNodes:[[NSArray alloc] initWithArray:accum copyItems:YES]
                                                                     Node:elder];
               // [[FoldTree alloc] initWithContentRange:elder sortedRanges:[[NSArray alloc] initWithArray:accum copyItems:YES]];
                [_children addObject:subTree];
                elder = node;
                [accum removeAllObjects];
            }

        }
        FoldTree* last = [[FoldTree alloc] initWithSortedNodes:[[NSArray alloc] initWithArray:accum copyItems:YES]
                                                          Node:elder];

//        [[FoldTree alloc] initWithContentRange:elder ranges:[FoldTree rangeArrayCopy:accum]];
        [_children addObject:last];
    
    }
}

-(NSString*)description {
    NSMutableString* str = [NSMutableString stringWithFormat:@"Node: %@ children=> { \n",_node];
    for (FoldTree* subTree in _children) {
        [str appendString:@"    "];
        [str appendString:[subTree description]];
        [str appendString:@"\n"];
    }
    [str appendString:@" } \n"];
    return str;
}

//+(NSArray*)nodeArrayCopy:(NSArray*)arr {
//    NSMutableArray *tmp = [NSMutableArray array];
//    for (FoldNode *v in arr) {
//        [tmp addObject:];
//    }
//    return tmp;
//}

-(NSRange)lowestNodeWithIndex:(CFIndex)index {
    if ([Utils isContainedByRange:_contentRange Index:index]) {
            NSRange leafRange = _contentRange;
            for (FoldTree* subTree in _children) {
                NSRange childRange = [subTree lowestNodeWithIndex:index];
                if (childRange.location!= NSNotFound) {
                    leafRange = childRange;
                }
            }
            return leafRange;

    } else {
        return NSMakeRange(NSNotFound, 0);
    }
}

@end
