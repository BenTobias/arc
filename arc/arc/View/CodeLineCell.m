//
//  CodeLineCell.m
//  arc
//
//  Created by Yong Michael on 31/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "CodeLineCell.h"

#define LINENUMBER_PADDING 10

@interface CodeLineCell ()
@property (nonatomic, strong) UIColor *foregroundColor;
@property (nonatomic, strong) NSString *fontFamily;
@property (nonatomic) int fontSize;
//@property (nonatomic, strong) CodeLine *codeLine;
@property (nonatomic, strong) UILabel *codeLine;
@property (nonatomic, strong) UILabel *lineNumberLabel;
@end

@implementation CodeLineCell
@synthesize line = _line;
@synthesize lineNumberWidth = _lineNumberWidth;
@synthesize lineNumber = _lineNumber;
@synthesize showLineNumber = _showLineNumber;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        // defaults
        _lineNumberWidth = 30;
        _showLineNumber = YES;
        
        _lineNumberLabel = [[UILabel alloc] init];
        _lineNumberLabel.backgroundColor = [UIColor clearColor];
        _lineNumberLabel.textAlignment = NSTextAlignmentRight;
        _lineNumberLabel.numberOfLines = 1;
        [self.contentView addSubview:_lineNumberLabel];
        
        _codeLine = [[UILabel alloc] init];
        _codeLine.backgroundColor = [UIColor clearColor];
        _codeLine.numberOfLines = 1;
        [self.contentView addSubview:_codeLine];
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setForegroundColor:(UIColor*)foregroundColor
{
    _foregroundColor = foregroundColor;
    _lineNumberLabel.textColor = _foregroundColor;
}

- (void)setFontFamily:(NSString*)fontFamily FontSize:(int)fontSize
{
    _fontFamily = fontFamily;
    _fontSize = fontSize;
    _lineNumberLabel.font = [UIFont fontWithName:_fontFamily size:_fontSize];
}

- (void)setLine:(NSAttributedString *)line
{
    _line = line;
    _codeLine.attributedText = _line;
    _lineNumberLabel.text = @"";
}

+ (int)calcLineNumberWidthForMaxLineNumber:(int)lineNumber
                                FontFamily:(NSString *)fontFamily
                                  FontSize:(int)fontSize
{
    CGSize textSize = [[NSString stringWithFormat:@"%d", lineNumber]
                       sizeWithFont:[UIFont fontWithName:fontFamily size:fontSize]];
    return ceil(textSize.width);
}

- (void)setLineNumberWidth:(int)lineNumberWidth
{
    // min line width 30 with margin = 5
    if (lineNumberWidth < 30) {
        lineNumberWidth = 30;
    }

    // margin
    _lineNumberWidth = lineNumberWidth + 5;
}

- (void)setLineNumber:(int)lineNumber
{
    _lineNumber = lineNumber;
    _lineNumberLabel.text = [NSString stringWithFormat:@"%d", _lineNumber];
}

- (void)layoutSubviews
{
    self.contentView.frame = self.bounds;
    _lineNumberLabel.frame =
    CGRectMake(0, 0, _lineNumberWidth, self.contentView.bounds.size.height);

    _codeLine.frame =
    CGRectMake(_lineNumberWidth + LINENUMBER_PADDING, 0,
               self.contentView.bounds.size.width - _lineNumberWidth - LINENUMBER_PADDING,
               self.contentView.bounds.size.height);

    [_codeLine sizeToFit];
}

- (UIView *)backgroundView
{
    return nil;
}

@end
