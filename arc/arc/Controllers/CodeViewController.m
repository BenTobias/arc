//
//  CodeViewController.m
//  arc
//
//  Created by Benedict Liang on 19/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//
#import <CoreText/CoreText.h>
#import "CodeViewController.h"
#import "CoreTextUIView.h"
#import "ArcAttributedString.h"
#import "BasicStyles.h"
#import "SyntaxHighlight.h"
@interface CodeViewController ()
@property id<File> currentFile;
@property CodeView *codeView;
@property CoreTextUIView *coreTextView;
@property ArcAttributedString *arcAttributedString;
- (void)refreshSubViewSizes;
@end

@implementation CodeViewController
@synthesize delegate = _delegate;

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add a toolbar
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:
        CGRectMake(0, 0, self.view.bounds.size.width, SIZE_TOOLBAR_HEIGHT)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _codeView = [[CodeView alloc] init];
    _codeView.frame = CGRectMake(0, SIZE_TOOLBAR_HEIGHT,
        self.view.bounds.size.width, self.view.bounds.size.height - SIZE_TOOLBAR_HEIGHT);
    _codeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    _coreTextView = [[CoreTextUIView alloc] init];
    _coreTextView.frame = _codeView.bounds;
    [_codeView addSubview:_coreTextView];
    
    [self.view addSubview:toolbar];
    [self.view addSubview:_codeView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self refreshSubViewSizes];
}

- (void)refreshSubViewSizes
{
    [_coreTextView refresh];

    // Resize codeView (parent) Content Size
    _codeView.contentSize = _coreTextView.bounds.size;
}

- (void)showFile:(id<File>)file
{
    // Update Current file
    _currentFile = file;
    [self loadFile:_currentFile];


    // Middleware to Style Attributed String
    [BasicStyles arcAttributedString:_arcAttributedString
                              OfFile:_currentFile
                            delegate:self];
    [SyntaxHighlight arcAttributedString:_arcAttributedString
                                  OfFile:_currentFile
                                delegate:self];

    // Render Code to screen
    [self render];
    
    // Update Sizes of SubViews
    [self refreshSubViewSizes];
}

- (void)loadFile:(id<File>)file
{
    _arcAttributedString = [[ArcAttributedString alloc]
                            initWithString:(NSString *)[_currentFile contents]];
}

- (void)mergeAndRenderWith:(ArcAttributedString*)aas forFile:(id<File>)file
{
    //TODO merge aas with _arcAttributedString.
    if ([file isEqual:_currentFile]) {
        _arcAttributedString = aas;
        [self render];
    }
}
- (void)render
{
    [_coreTextView setAttributedString:_arcAttributedString.attributedString];
}
@end
