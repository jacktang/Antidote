//
//  LoginProfileFormView.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 09/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "LoginProfileFormView.h"
#import "AppearanceManager.h"
#import "UIColor+Utilities.h"
#import "UIButton+Utilities.h"

static const CGFloat kFormHorizontalOffset = 40.0;
static const CGFloat kOffsetInForm = 20.0;
static const CGFloat kProfileToButtonOffset = 10.0;
static const CGFloat kFieldHeight = 40.0;
static const CGFloat kFormToButtonOffset = 10.0;
static const CGFloat kBottomButtonsBottomOffset = -20.0;
static const CGFloat kOrButtonOffset = 10.0;

static const NSTimeInterval kAnimationDuration = 0.3;

@interface LoginProfileFormView () <UITextFieldDelegate>

@property (strong, nonatomic) UIView *formView;
@property (strong, nonatomic) UITextField *profileFakeTextField;
@property (strong, nonatomic) UIButton *profileButton;
@property (strong, nonatomic) UITextField *passwordField;

@property (strong, nonatomic) UIButton *loginButton;

@property (strong, nonatomic) UIView *bottomButtonsContainer;
@property (strong, nonatomic) UIButton *createAccountButton;
@property (strong, nonatomic) UILabel *orLabel;
@property (strong, nonatomic) UIButton *importProfileButton;

@property (strong, nonatomic) MASConstraint *profileButtonBottomToFormConstraint;
@property (strong, nonatomic) MASConstraint *passwordFieldBottomToFormConstraint;

@end

@implementation LoginProfileFormView

#pragma mark -  Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (! self) {
        return nil;
    }

    [self createFormViews];
    [self createLoginButton];
    [self createBottomButtons];

    [self installConstraints];

    return self;
}

#pragma mark -  Properties

- (void)setProfileString:(NSString *)text
{
    self.profileFakeTextField.text = text;
}

- (NSString *)profileString
{
    return self.profileFakeTextField.text;
}

- (void)setPasswordString:(NSString *)text
{
    self.passwordField.text = text;
}

- (NSString *)passwordString
{
    return self.passwordField.text;
}

#pragma mark -  Actions

- (void)profileButtonPressed
{
    [self endEditing:YES];
    [self.delegate loginProfileFormViewProfileButtonPressed:self];
}

- (void)hidePasswordFieldButtonPressed
{
    [self endEditing:YES];
}

- (void)loginButtonPressed
{
    [self.delegate loginProfileFormViewLoginButtonPressed:self];
}

- (void)createAccountButtonPressed
{
    [self.delegate loginProfileFormViewCreateAccountButtonPressed:self];
}

- (void)importProfileButtonPressed
{
    [self.delegate loginProfileFormViewImportProfileButtonPressed:self];
}

#pragma mark -  Public

- (void)showPasswordField:(BOOL)show animated:(BOOL)animated
{
    void (^updateForm)() = ^() {
        if (show) {
            [self.profileButtonBottomToFormConstraint deactivate];
            [self.passwordFieldBottomToFormConstraint activate];
            self.passwordField.alpha = 1.0;
        }
        else {
            [self.profileButtonBottomToFormConstraint activate];
            [self.passwordFieldBottomToFormConstraint deactivate];
            self.passwordField.alpha = 0.0;
        }

        [self layoutIfNeeded];
    };

    if (animated) {
        [UIView animateWithDuration:kAnimationDuration animations:updateForm];
    }
    else {
        updateForm();
    }
}

- (CGFloat)loginButtonBottomY
{
    return CGRectGetMaxY(self.loginButton.frame);
}

#pragma mark -  UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self loginButtonPressed];
    return YES;
}

#pragma mark -  Private

- (void)createFormViews
{
    self.formView = [UIView new];
    self.formView.backgroundColor = [UIColor whiteColor];
    self.formView.layer.cornerRadius = 5.0;
    self.formView.layer.masksToBounds = YES;
    [self addSubview:self.formView];

    self.profileFakeTextField = [UITextField new];
    self.profileFakeTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.profileFakeTextField.leftViewMode = UITextFieldViewModeAlways;
    self.profileFakeTextField.leftView = [self iconContainerWithImage:@"login-profile-icon"];
    [self.formView addSubview:self.profileFakeTextField];

    self.profileButton = [UIButton new];
    [self.profileButton addTarget:self action:@selector(profileButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.formView addSubview:self.profileButton];

    self.passwordField = [UITextField new];
    self.passwordField.delegate = self;
    self.passwordField.placeholder = NSLocalizedString(@"Password", @"LoginViewController");
    self.passwordField.secureTextEntry = YES;
    self.passwordField.returnKeyType = UIReturnKeyGo;
    self.passwordField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordField.leftView = [self iconContainerWithImage:@"login-password-icon"];
    [self.formView addSubview:self.passwordField];
}

- (void)createLoginButton
{
    self.loginButton = [UIButton loginButton];
    [self.loginButton setTitle:NSLocalizedString(@"Log In", @"LoginViewController") forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.loginButton];
}

- (void)createBottomButtons
{
    self.bottomButtonsContainer = [UIView new];
    self.bottomButtonsContainer.backgroundColor = [UIColor clearColor];
    [self addSubview:self.bottomButtonsContainer];

    self.createAccountButton = [UIButton new];
    [self.createAccountButton setTitle:NSLocalizedString(@"Create profile", @"LoginViewController")
                              forState:UIControlStateNormal];
    [self.createAccountButton setTitleColor:[[AppContext sharedContext].appearance linkYellowColor]
                                   forState:UIControlStateNormal];
    [self.createAccountButton addTarget:self
                                 action:@selector(createAccountButtonPressed)
                       forControlEvents:UIControlEventTouchUpInside];
    self.createAccountButton.titleLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:16.0];
    [self.bottomButtonsContainer addSubview:self.createAccountButton];

    self.orLabel = [UILabel new];
    self.orLabel.text = NSLocalizedString(@"or", @"LoginViewController");
    self.orLabel.textColor = [[AppContext sharedContext].appearance loginDescriptionTextColor];
    self.orLabel.backgroundColor = [UIColor clearColor];
    [self.bottomButtonsContainer addSubview:self.orLabel];

    self.importProfileButton = [UIButton new];
    [self.importProfileButton setTitle:NSLocalizedString(@"Import to Antidote", @"LoginViewController")
                              forState:UIControlStateNormal];
    [self.importProfileButton setTitleColor:[[AppContext sharedContext].appearance linkYellowColor]
                                   forState:UIControlStateNormal];
    [self.importProfileButton addTarget:self
                                 action:@selector(importProfileButtonPressed)
                       forControlEvents:UIControlEventTouchUpInside];
    self.importProfileButton.titleLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:16.0];
    [self.bottomButtonsContainer addSubview:self.importProfileButton];
}

- (void)installConstraints
{
    [self.formView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.centerX.equalTo(self);
        make.left.equalTo(self).offset(kFormHorizontalOffset);
        make.right.equalTo(self).offset(-kFormHorizontalOffset);
    }];

    [self.profileFakeTextField makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.profileButton);
    }];

    [self.profileButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.formView).offset(kOffsetInForm);
        make.left.equalTo(self.formView).offset(kOffsetInForm);
        make.right.equalTo(self.formView).offset(-kOffsetInForm);
        make.height.equalTo(kFieldHeight);
        self.profileButtonBottomToFormConstraint = make.bottom.equalTo(self.formView).offset(-kOffsetInForm);
    }];

    [self.passwordField makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.profileButton.bottom).offset(kProfileToButtonOffset);
        make.left.equalTo(self.formView).offset(kOffsetInForm);
        make.right.equalTo(self.formView).offset(-kOffsetInForm);
        make.height.equalTo(kFieldHeight);
        self.passwordFieldBottomToFormConstraint = make.bottom.equalTo(self.formView).offset(-kOffsetInForm);
    }];

    [self.loginButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.formView.bottom).offset(kFormToButtonOffset);
        make.height.equalTo(kFieldHeight);
        make.width.equalTo(self.formView);
    }];

    [self.bottomButtonsContainer makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(self.loginButton.bottom).offset(30.0);
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(kBottomButtonsBottomOffset);
    }];

    [self.createAccountButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.bottomButtonsContainer);
    }];

    [self.orLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomButtonsContainer);
        make.left.equalTo(self.createAccountButton.right).offset(kOrButtonOffset);
        make.right.equalTo(self.importProfileButton.left).offset(-kOrButtonOffset);
    }];

    [self.importProfileButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(self.bottomButtonsContainer);
    }];
}

- (UIView *)iconContainerWithImage:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tintColor = [UIColor uColorWithWhite:200 alpha:1];

    UIView *container = [UIView new];
    container.backgroundColor = [UIColor clearColor];
    [container addSubview:imageView];

    CGRect frame = container.frame;
    frame.size.width = kFieldHeight - 15.0;
    frame.size.height = kFieldHeight;
    container.frame = frame;

    frame = imageView.frame;
    frame.origin.x = container.frame.size.width - frame.size.width;
    frame.origin.y = (kFieldHeight - frame.size.width) / 2 - 1.0;
    imageView.frame = frame;

    return container;
}

@end