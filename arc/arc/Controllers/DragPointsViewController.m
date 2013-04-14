//
//  DragPointsViewController.m
//  arc
//
//  Created by Benedict Liang on 14/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "DragPointsViewController.h"
#import "CodeLineCell.h"

@interface DragPointsViewController ()

@property (nonatomic) CGRect currentBottomRowCellRect;
@property (nonatomic) CGRect currentTopRowCellRect;

@property (nonatomic) CGRect nextBottomRowCellRect;
@property (nonatomic) CGRect nextTopRowCellRect;
@property (nonatomic, strong) NSIndexPath *nextBottomRowIndexPath;
@property (nonatomic, strong) NSIndexPath *nextTopRowIndexPath;

@end

@implementation DragPointsViewController

- (id)initWithSelectedTextRect:(CGRect)selectedTextRect andOffset:(int)offset {
    self = [super init];
    
    if (self) {
        CGRect leftDragPointFrame = CGRectMake(selectedTextRect.origin.x + offset,
                                               selectedTextRect.origin.y,
                                               20,
                                               selectedTextRect.size.height);
        _leftDragPoint = [[DragPointImageView alloc] initWithFrame:leftDragPointFrame];
        
        CGRect rightDragPointFrame = CGRectMake(selectedTextRect.origin.x + selectedTextRect.size.width + offset,
                                               selectedTextRect.origin.y,
                                               20,
                                               selectedTextRect.size.height);
        _rightDragPoint = [[DragPointImageView alloc] initWithFrame:rightDragPointFrame];
        
        UIPanGestureRecognizer *leftPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(moveLeftDragPoint:)];
        UIPanGestureRecognizer *rightPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(moveRightDragPoint:)];
        [_leftDragPoint addGestureRecognizer:leftPanGesture];
        [_rightDragPoint addGestureRecognizer:rightPanGesture];
        
        _leftDragPoint.userInteractionEnabled = YES;
        _rightDragPoint.userInteractionEnabled = YES;
    }
    
    return self;
}

// TODO: Move drag points and update background color range
// TODO: Set boundary conditions

- (void)moveLeftDragPoint:(UIPanGestureRecognizer*)gesture {
    
}

- (void)moveRightDragPoint:(UIPanGestureRecognizer*)gesture {
    
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        [self calculateRectValues];
    }
    
    if ([gesture state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:_tableView];
        
        if (((_topIndexPath.row == _bottomIndexPath.row) && (translation.y > 0)) ||
            (_topIndexPath.row != _bottomIndexPath.row)) {
//            NSLog(@"translation: %f", translation.y);
        }
        
        CGFloat cellHeight = _currentBottomRowCellRect.size.height;
        CGFloat quarterDistance = cellHeight / 4;
        
        // y-direction changed
        // => get cell for position
        if (translation.y > quarterDistance) {
            [self updateBottomRectValuesWithBottomIndexPath:_nextBottomRowIndexPath];
            gesture.view.center = CGPointMake(gesture.view.center.x, _currentBottomRowCellRect.origin.y + cellHeight/2);
            [gesture setTranslation:CGPointMake(0, 0) inView:_tableView];
            
            CGPoint endPointInRow = CGPointMake(gesture.view.center.x, 0);
            CodeLineCell *cell = (CodeLineCell*)[_tableView cellForRowAtIndexPath:_bottomIndexPath];
            CTLineRef lineRef = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)
                                                                 (cell.line));
            CFIndex index = CTLineGetStringIndexForPosition(lineRef, endPointInRow);
            int endLocation = cell.stringRange.location + index;
            _selectedTextRange = NSMakeRange(_selectedTextRange.location, endLocation - _selectedTextRange.location);
            [_codeViewController setBackgroundColorForString:[UIColor blueColor]
                                                   WithRange:_selectedTextRange
                                                  forSetting:@"copyAndPaste"];
            [_tableView reloadData];
        }
        
        // Needs to resolve for right < left
        if (translation.y < -quarterDistance) {
            [self updateBottomRectValuesWithBottomIndexPath:
             [NSIndexPath indexPathForRow:_bottomIndexPath.row-1
                                inSection:0]];
            gesture.view.center = CGPointMake(gesture.view.center.x, _currentBottomRowCellRect.origin.y + cellHeight/2);
            [gesture setTranslation:CGPointMake(0, 0) inView:_tableView];
        }
    }
    
    else if ([gesture state] == UIGestureRecognizerStateEnded) {

    }
}

- (void)updateBottomRectValuesWithBottomIndexPath:(NSIndexPath*)bottomIndexPath {
    _bottomIndexPath = [NSIndexPath indexPathForRow:bottomIndexPath.row inSection:0];
    _currentBottomRowCellRect = [_tableView rectForRowAtIndexPath:bottomIndexPath];
    
    int bottomRow = _bottomIndexPath.row;
    
    if (bottomRow + 1 < [_tableView numberOfRowsInSection:0]) {
        _nextBottomRowIndexPath = [NSIndexPath indexPathForRow:(bottomRow + 1) inSection:0];
        _nextBottomRowCellRect = [_tableView rectForRowAtIndexPath:_nextBottomRowIndexPath];
    }
    else {
        _nextBottomRowIndexPath = nil;
        _nextBottomRowCellRect = CGRectNull;
    }
}

- (void)moveRightDragPointHorizontal:(UIPanGestureRecognizer*)gesture {
    UITableView *tableView = (UITableView*)gesture.view.superview;
    CGPoint translation = [gesture translationInView:tableView];
    
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x, gesture.view.center.y);
    
    [gesture setTranslation:CGPointMake(0, 0) inView:tableView];
//    [tableView reloadData];
    if ([gesture state] == UIGestureRecognizerStateChanged) {
        // Update selection rect
//        CGFloat originalX = self.frame.origin.x;
//        CGFloat newWidth = gesture.view.center.x - originalX;
//        
//        [self updateSize:CGSizeMake(newWidth, self.frame.size.height)];
    }
    
    else if ([gesture state] == UIGestureRecognizerStateEnded) {
        // Update substring
//        [self updateSelectionSubstring:cell];
//        
//        [self showCopyMenuForTextSelection];
    }
}

- (void)calculateRectValues {
    _currentTopRowCellRect = [_tableView rectForRowAtIndexPath:_topIndexPath];
    _currentBottomRowCellRect = [_tableView rectForRowAtIndexPath:_bottomIndexPath];
    
    int topRow = _topIndexPath.row;
    int bottomRow = _bottomIndexPath.row;

    if (topRow - 1 >= 0) {
        _nextTopRowIndexPath = [NSIndexPath indexPathForRow:(topRow - 1) inSection:0];
        _nextTopRowCellRect = [_tableView rectForRowAtIndexPath:_nextTopRowIndexPath];
    }
    else {
        _nextTopRowIndexPath = nil;
        _nextTopRowCellRect = CGRectNull;
    }
    
    if (bottomRow + 1 < [_tableView numberOfRowsInSection:0]) {
        _nextBottomRowIndexPath = [NSIndexPath indexPathForRow:(bottomRow + 1) inSection:0];
        _nextBottomRowCellRect = [_tableView rectForRowAtIndexPath:_nextBottomRowIndexPath];
    }
    else {
        _nextBottomRowIndexPath = nil;
        _nextBottomRowCellRect = CGRectNull;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
