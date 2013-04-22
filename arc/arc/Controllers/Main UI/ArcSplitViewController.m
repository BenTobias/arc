//
//  ArcSplitViewController.m
//  arc
//
//  Created by Yong Michael on 20/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "ArcSplitViewController.h"

@interface ArcSplitViewController ()
@end

@implementation ArcSplitViewController
@synthesize delegate = _delegate;
@synthesize masterView = _masterView;
@synthesize detailView = _detailView;
@synthesize masterViewVisible = _masterViewVisible;

- (id)init
{
    self = [super init];
    if (self) {
        _masterViewVisible = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:_masterView];
    [self.view addSubview:_detailView];
    _masterView.autoresizesSubviews = YES;
    _detailView.autoresizesSubviews = YES;
    
    // Work Around
    // (force recalculation of self.view.bounds)
    // iOS initial frame is unreliable.
    [[UIApplication sharedApplication]
     setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];

    self.view.backgroundColor = [UIColor blackColor];

    [self autoLayout];
}

- (void)autoLayout
{
    if (_masterViewVisible) {
        [self showMasterViewAnimated:NO];
    } else {
        [self hideMasterViewAnimated:NO];
    }
}

# pragma mark - Layout Methods

- (void)showMasterViewAnimated:(BOOL)animate
{
    if ([self.delegate respondsToSelector:@selector(willShowMasterViewAnimated:)]) {
        [self.delegate willShowMasterViewAnimated:animate];
    }

    _masterViewVisible = YES;

    if (animate) {
        NSString *oldSize = NSStringFromCGSize(_detailView.frame.size);
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [self showMasterView];
                         }
                         completion:^(BOOL finished){
                             BOOL boundsChanged = [oldSize isEqualToString:
                                                   NSStringFromCGSize(_detailView.frame.size)];
                             
                             if ([self.delegate respondsToSelector:@selector(didShowMasterViewAnimated:boundsChanged:)]) {
                                 [self.delegate didShowMasterViewAnimated:animate boundsChanged:boundsChanged];
                             }
                         }];
    } else {
        [self showMasterView];
    }
}

- (void)showMasterView
{
    _masterView.frame =
    CGRectMake(0, 0, 320, self.view.bounds.size.height);
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication]statusBarOrientation])) {
        _detailView.frame =
        CGRectMake(321, 0,
                   self.view.bounds.size.width - 320,
                   self.view.bounds.size.height);
    } else {
        _detailView.frame =
        CGRectMake(321, 0,
                   self.view.bounds.size.width,
                   self.view.bounds.size.height);
    }
}

- (void)hideMasterViewAnimated:(BOOL)animate
{
    if ([self.delegate respondsToSelector:@selector(willHideMasterViewAnimated:)]) {
        [self.delegate willHideMasterViewAnimated:animate];
    }

    _masterViewVisible = NO;

    if (animate) {
        NSString *oldSize = NSStringFromCGSize(_detailView.frame.size);
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [self hideMasterView];
                         }
                         completion:^(BOOL finished){
                             BOOL boundsChanged = [oldSize isEqualToString:
                                                   NSStringFromCGSize(_detailView.frame.size)];
                             if ([self.delegate respondsToSelector:@selector(didHideMasterViewAnimated:boundsChanged:)]) {
                                 [self.delegate didHideMasterViewAnimated:animate boundsChanged:boundsChanged];
                             }
                         }];
    } else {
        [self hideMasterView];
    }
}

- (void)hideMasterView
{
    _masterView.frame =
    CGRectMake(-320, 0, 320, self.view.bounds.size.height);
    
    _detailView.frame =
    CGRectMake(0, 0,
               self.view.bounds.size.width,
               self.view.bounds.size.height);
}

# pragma mark - Orientation Methods

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    [self autoLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (_masterViewVisible) {
        [self showMasterViewAnimated:YES];
    } else {
        [self hideMasterViewAnimated:YES];
    }
}

@end
