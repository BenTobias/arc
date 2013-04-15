//
//  ArcViewController.m
//  arc
//
//  Created by Yong Michael on 11/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "ArcViewController.h"

@interface ArcViewController ()
@property BOOL animating;
@property UIView *masterView;
@property UIView *detailView;
@end

@implementation ArcViewController
@synthesize masterViewController = _masterViewController;
@synthesize detailViewController = _detailViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Work Around
    // (force recalculation of self.view.bounds)
    // iOS initial frame is unreliable.
    [[UIApplication sharedApplication]
     setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    
    _masterView = _masterViewController.view;
    _detailView = _detailViewController.view;
    _masterView.layer.masksToBounds = YES;
    [self.view addSubview:_masterView];

    _detailView.layer.masksToBounds = NO;
    _detailView.layer.shadowRadius = 5;
    _detailView.layer.shadowOpacity = 0.5;
    [self.view addSubview:_detailView];
    
    [self autoLayout:
     [[UIApplication sharedApplication]statusBarOrientation]];
    
    // Attach Pan Gesture Recognizer to MainView
    UIPanGestureRecognizer *panGestureRecognizer =
    [[UIPanGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(panGestureAction:)];
    [_detailView addGestureRecognizer:panGestureRecognizer];
}

- (void)panGestureAction:(UIPanGestureRecognizer *)gesture
{
    if (_animating) {
        return;
    }
    
    if ([gesture state] == UIGestureRecognizerStateBegan ||
        [gesture state] == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:self.view];
        
        CGFloat xCoordOfDetailView = _detailView.frame.origin.x + translation.x;

        if (xCoordOfDetailView > 320) {
            xCoordOfDetailView = 320;
        } else if (xCoordOfDetailView < 0) {
            xCoordOfDetailView = 0;
        }
        
        // Scale masterView
        CGFloat scale = 0.9 + powf((xCoordOfDetailView/320.0),2) * 0.1;
        _masterView.transform = CGAffineTransformMakeScale(scale, scale);
        
        _detailView.frame = CGRectMake(xCoordOfDetailView,
                                       0,
                                       self.view.bounds.size.width - xCoordOfDetailView,
                                       _detailView.frame.size.height);

        [gesture setTranslation:CGPointZero
                         inView:self.view];
    }
    
    if ([gesture state] == UIGestureRecognizerStateEnded) {
        _animating = YES;
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             if (_detailView.frame.origin.x > 160) {
                                 _masterView.transform = CGAffineTransformMakeScale(1, 1);
                                 _detailView.frame = CGRectMake(320, 0,
                                                                _detailView.frame.size.width,
                                                                _detailView.frame.size.height);
                             } else {
                                 _masterView.transform = CGAffineTransformMakeScale(0.9, 0.9);
                                 _detailView.frame = CGRectMake(0, 0,
                                                                self.view.bounds.size.width,
                                                                _detailView.frame.size.height);

                             }
                         } completion:^(BOOL finished){
                             _animating = NO;
                         }];
    }
}

- (void)autoLayout:(UIInterfaceOrientation)toInterfaceOrientation
{
    _masterView.frame =
    CGRectMake(0, 0, 320, self.view.bounds.size.height);
    
    _detailView.frame =
    CGRectMake(320, 0,
               self.view.bounds.size.width - 320,
               self.view.bounds.size.height);
}

# pragma mark - Orientation Methods

- (BOOL)shouldAutorotate
{
    // Allow any orientation
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    [self autoLayout:toInterfaceOrientation];
}

@end
