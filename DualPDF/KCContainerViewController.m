//
//  KCContainerViewController.m
//  DualPDF
//
// Created by Hanfei Li on 2014-12-16.
// Copyright © 2014-2015 Hanfei Li. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to
// do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "KCContainerViewController.h"
#import "KCSettingsViewController.h"
#import "KCResizeView.h"

#import "common.h"

@interface KCContainerViewController () {
    KCPDFViewController *firstPDFVC;
    KCPDFViewController *secondPDFVC;
    CGFloat firstViewPercent;
}

@property (nonatomic, weak) IBOutlet UIView *firstView;
@property (nonatomic, weak) IBOutlet UIView *secondView;
@property (nonatomic, weak) IBOutlet KCResizeView *resizeView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *secondToTop;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *secondToLeft;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *firstToRight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *firstToBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *firstToTop;

@end

@implementation KCContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    firstViewPercent = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:PREF_KEY_SCRPARTITION] floatValue];
    firstPDFVC = [storyboard instantiateViewControllerWithIdentifier:@"firstPDFViewController"];
    firstPDFVC.delegate = self;
    [self addChildViewController:firstPDFVC];
    self.firstView.autoresizingMask = UIViewAutoresizingNone;
    [self.firstView addSubview:firstPDFVC.view];
    [firstPDFVC didMoveToParentViewController:self];
    
    secondPDFVC = [storyboard instantiateViewControllerWithIdentifier:@"secondPDFViewController"];
    secondPDFVC.delegate = self;
    [self addChildViewController:secondPDFVC];
    self.secondView.autoresizingMask = UIViewAutoresizingNone;
    [self.secondView addSubview:secondPDFVC.view];
    [secondPDFVC didMoveToParentViewController:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScreenPartitionChangeMsg:) name:MSG_PARTITION_CHANGED object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    firstPDFVC.view.frame = self.firstView.bounds;
    secondPDFVC.view.frame = self.secondView.bounds;
    self.secondView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.secondView.layer.shadowRadius = 3.0;
    self.secondView.layer.shadowOpacity = 0.5;
    [self handleScreenPartitionChange:self.view.bounds.size];
}

- (void)handleScreenPartitionChangeMsg:(NSNotification *)notification {
    NSDictionary* userInfo = notification.userInfo;
    CGSize newSize = CGSizeMake(((NSNumber *)[userInfo objectForKey:@"width"]).doubleValue, ((NSNumber *)[userInfo objectForKey:@"height"]).doubleValue);
    [self handleScreenPartitionChange:newSize];
}

- (void)handleScreenPartitionChange:(CGSize)newSize
{
    firstViewPercent = [[NSUserDefaults standardUserDefaults] floatForKey:PREF_KEY_SCRPARTITION];
    SplitOrientation mode = [[NSUserDefaults standardUserDefaults] integerForKey:PREF_KEY_ORIENTATION];
    BOOL portrait = YES;
    
    if (mode == kHorizontal)
        portrait = YES;
    else if (mode == kVertical)
        portrait = NO;
    else
        portrait = newSize.height > newSize.width;
    
    self.firstToTop.constant = IS_PHONE ? 0 : SIGBAR_HEIGHT;
    if (portrait) {
        self.firstToRight.constant = 0;
        self.secondToLeft.constant = 0;
        self.firstToBottom.constant = newSize.height * firstViewPercent;
        self.secondToTop.constant = newSize.height * (1.0 - firstViewPercent);
        if (!IS_PHONE)
            self.secondView.layer.shadowOffset = CGSizeMake(-4.0, -4.0);
    } else {
        self.firstToRight.constant = newSize.width * firstViewPercent;
        self.secondToLeft.constant = newSize.width * (1.0 - firstViewPercent);
        self.firstToBottom.constant = 0;
        self.secondToTop.constant = IS_PHONE ? 0 : SIGBAR_HEIGHT;
        if (!IS_PHONE)
            self.secondView.layer.shadowOffset = CGSizeMake(-4.0, 4.0);
    }
    [self updateViewConstraints];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [self handleScreenPartitionChange:size];
    if (!self.resizeView.isHidden)
        [self.resizeView showResizeView:firstViewPercent withVertical:self.firstToBottom.constant == 0 withSize:size];
    if ([firstPDFVC readerIsOn])
        [firstPDFVC reloadFile];
    if ([secondPDFVC readerIsOn])
        [secondPDFVC reloadFile];
}

- (IBAction)closeResizeView:(id)sender {
    self.resizeView.hidden = YES;
    firstViewPercent = self.firstToBottom.constant == 0 ? 1 - self.resizeView.slider.value : self.resizeView.slider.value;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:firstViewPercent] forKey:PREF_KEY_SCRPARTITION];
    [self handleScreenPartitionChange:self.view.bounds.size];
    if ([firstPDFVC readerIsOn])
        [firstPDFVC reloadFile];
    if ([secondPDFVC readerIsOn])
        [secondPDFVC reloadFile];
}

- (BOOL)prefersStatusBarHidden {
    if (IS_PHONE)
        return YES;
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// delegate methods

- (void)changeScreenPartition:(KCPDFViewController *)pdfViewController {
    [self.resizeView showResizeView:firstViewPercent withVertical:self.firstToBottom.constant == 0 withSize:CGSizeMake(self.view.bounds.size.width, self.firstView.bounds.size.height + self.secondView.bounds.size.height)];
    self.resizeView.hidden = NO;
}

@end
