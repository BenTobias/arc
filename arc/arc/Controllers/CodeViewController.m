//
//  CodeViewController.m
//  arc
//
//  Created by Benedict Liang on 19/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//
#import <CoreText/CoreText.h>
#import "CodeViewController.h"
#import "CodeViewMiddleware.h"
#import "CodeLineCell.h"
#import "ArcAttributedString.h"

// Middleware
#import "BasicStyles.h"
#import "SyntaxHighlight.h"

@interface CodeViewController ()
@property id<File> currentFile;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ArcAttributedString *arcAttributedString;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIBarButtonItem *toolbarTitle;
@property CTFramesetterRef frameSetter;
@property CGFloat lineHeight;
@property NSMutableArray *lines;
@property NSMutableArray *plugins;
- (void)loadFile;
- (void)processFile;
- (void)renderFile;
- (void)clearPreviousLayoutInformation;
- (void)generateLines;
- (void)calcLineHeight;
@end

@implementation CodeViewController
@synthesize delegate = _delegate;
@synthesize backgroundColor = _backgroundColor;

- (id)init
{
    self = [super init];
    if (self) {
        _lines = [NSMutableArray array];
        _plugins = [NSMutableArray array];
        
        // Defaults
        _backgroundColor = [Utils colorWithHexString:@"FDF6E3"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizesSubviews = YES;
    
    // Add a toolbar
    _toolbar = [[UIToolbar alloc] initWithFrame:
                CGRectMake(0, 0, self.view.bounds.size.width, SIZE_TOOLBAR_HEIGHT)];
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _toolbarTitle = [[UIBarButtonItem alloc] initWithTitle:@""
                                                     style:UIBarButtonItemStylePlain
                                                    target:nil
                                                    action:nil];
    _toolbar.items = [NSArray arrayWithObjects:
                       [Utils flexibleSpace],
                       _toolbarTitle,
                       [Utils flexibleSpace],
                       nil];

    [self.view addSubview:_toolbar];
    
    // Set Up TableView
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                              style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleWidth;
    _tableView.backgroundColor = _backgroundColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.autoresizesSubviews = YES;
    
    // Set TableView's Delegate and DataSource
    _tableView.dataSource = self;
    _tableView.frame = CGRectMake(0, SIZE_TOOLBAR_HEIGHT,
                                  self.view.bounds.size.width,
                                  self.view.bounds.size.height - SIZE_TOOLBAR_HEIGHT);
    [self.view addSubview:_tableView];
}

- (void)refreshForSetting:(NSString *)setting
{
    id<File> tmp = _currentFile;
    _currentFile = nil;
    [self showFile:tmp];
}

- (void)showFile:(id<File>)file
{
    if ([file isEqual:_currentFile]) {
        [_tableView reloadData];
        return;
    }
    
    // Update Current file
    _currentFile = file;
    
    [self updateToolbarTitle];
    
    [self loadFile];
    [self processFile];
    [self generateLines];
    [self renderFile];
}

- (void)loadFile
{
    _arcAttributedString = [[ArcAttributedString alloc]
                            initWithString:(NSString *)[_currentFile contents]];
}

- (void)processFile
{
    for (id<PluginDelegate> plugin in _plugins) {
        if ([plugin respondsToSelector:
             @selector(arcAttributedString:OfFile:delegate:)])
        {
            [plugin arcAttributedString:_arcAttributedString
                                 ofFile:_currentFile
                               delegate:self];
        }
    }
}

- (void)renderFile
{
    // Render Code to screen
    [_tableView reloadData];
}

- (void)updateToolbarTitle
{
    _toolbarTitle.title = [_currentFile name];
}

- (void)clearPreviousLayoutInformation
{
    if (_frameSetter != NULL) {
        CFRelease(_frameSetter);
        _frameSetter = NULL;
    }

    _lines = [NSMutableArray array];
}

- (void)generateLines
{
    [self clearPreviousLayoutInformation];
    _lines = [NSMutableArray array];
    
    CFAttributedStringRef ref = (CFAttributedStringRef)CFBridgingRetain(_arcAttributedString.attributedString);
    _frameSetter = CTFramesetterCreateWithAttributedString(ref);
    
    // Work out the geometry
    CGFloat boundsWidth = _tableView.bounds.size.width - 20*2 - 45;
    
    // Calculate the lines
    CFIndex start = 0;
    NSUInteger length = CFAttributedStringGetLength(ref);
    CFBridgingRelease(ref);
    while (start < length)
    {
        CTTypesetterRef typesetter = CTFramesetterGetTypesetter(_frameSetter);
        CFIndex count = CTTypesetterSuggestLineBreak(typesetter, start, boundsWidth);
        [_lines addObject:[NSValue valueWithRange:NSMakeRange(start, count)]];
        start += count;
    }
    
    [self calcLineHeight];
}

- (void)calcLineHeight
{
    CGFloat asscent, descent, leading;
    if ([_lines count] > 0) {
        CTLineRef line = CTLineCreateWithAttributedString(
              (__bridge CFAttributedStringRef)(
                  [_arcAttributedString.attributedString attributedSubstringFromRange:
                      [[_lines objectAtIndex:0] rangeValue]]));

        CTLineGetTypographicBounds(line, &asscent, &descent, &leading);
        _lineHeight = asscent + descent + leading;
        _tableView.rowHeight = ceil(_lineHeight);
    }
}


#pragma mark - Code View Delegate

- (void)registerPlugin:(id<PluginDelegate>)plugin
{
    // Only register a plugin once.
    if ([_plugins indexOfObject:plugin] == NSNotFound) {
        [_plugins addObject:plugin];
    }
}

- (void)mergeAndRenderWith:(ArcAttributedString *)arcAttributedString
                   forFile:(id<File>)file
{
    if ([file isEqual:_currentFile]) {
        _arcAttributedString = arcAttributedString;
        [_tableView reloadData];
    }
}

#pragma mark - Detail View Controller Delegate

- (void)showShowMasterViewButton:(UIBarButtonItem *)button
{
    _toolbar.items = [NSArray arrayWithObjects:
                      button,
                      [Utils flexibleSpace],
                      _toolbarTitle,
                      [Utils flexibleSpace],
                      nil];
}

- (void)hideShowMasterViewButton:(UIBarButtonItem *)button
{
    _toolbar.items = [NSArray arrayWithObjects:
                      [Utils flexibleSpace],
                      _toolbarTitle,
                      [Utils flexibleSpace],
                      nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_lines count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *cellIdentifier = @"CodeLineCell";
    CodeLineCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[CodeLineCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:cellIdentifier];
    }
    cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    NSUInteger lineNumber = indexPath.row;

    CTLineRef lineRef = CTLineCreateWithAttributedString(
            (__bridge CFAttributedStringRef)(
                [_arcAttributedString.attributedString attributedSubstringFromRange:
                [[_lines objectAtIndex:lineNumber] rangeValue]]));

    cell.line = lineRef;
    [cell setNeedsDisplay];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSLog(@"asdf");
}

@end
