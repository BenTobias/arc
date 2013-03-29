//
//  CoreTextUIView.m
//  arc
//
//  Created by Yong Michael on 24/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "CoreTextUIView.h"
#import <CoreText/CoreText.h>

@interface CoreTextUIView ()

@end

@implementation CoreTextUIView
@synthesize attributedString = _attributedString;

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


- (void)setAttributedString:(NSAttributedString *)attributedString
{
    _attributedString = attributedString;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (_attributedString != nil) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // Flip the coordinate system
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, self.bounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        // Generate the path for the text
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, self.bounds);
        
        CTFramesetterRef framesetter =
        CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_attributedString);
        CTFrameRef frame =
            CTFramesetterCreateFrame(framesetter,
                CFRangeMake(0, 0), path, NULL);

        CTFrameDraw(frame, context);
        CFRelease(frame);
        CFRelease(path);
        CFRelease(framesetter);
    }
}

@end
