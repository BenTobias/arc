//
//  CreateFolderViewController.m
//  arc
//
//  Created by Jerome Cheng on 9/4/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "CreateFolderViewController.h"

@interface CreateFolderViewController ()

@property UITextField *textField;
@property UIButton *okButton;


@end

@implementation CreateFolderViewController

- (id)initWithDelegate:(id<CreateFolderViewControllerDelegate>)delegate
{
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 75)];
    [view setBackgroundColor:[UIColor whiteColor]];
    [self setContentSizeForViewInPopover:[view frame].size];
    [self setView:view];
    
    UILabel *createFolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 25)];
    [createFolderLabel setText:@"Enter folder name:"];
    [createFolderLabel setFont:[UIFont boldSystemFontOfSize:17]];
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 25, 250, 25)];
    [_textField setBorderStyle:UITextBorderStyleRoundedRect];
    [_textField setDelegate:self];

    _okButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [[_okButton titleLabel] setText:@"OK"];
    [_okButton setFrame:CGRectMake(0, 50, 250, 25)];

    [[self view] addSubview:createFolderLabel];
    [[self view] addSubview:_textField];
    [[self view] addSubview:_okButton];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *input = [_textField text];
    [_delegate createFolderWithName:input];
    return NO;
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
