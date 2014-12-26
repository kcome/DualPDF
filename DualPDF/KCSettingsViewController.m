//
//  KCSettingsViewController.m
//  DualPDF
//
// Created by Hanfei Li on 2014-12-20.
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

#import "KCSettingsViewController.h"

#import "common.h"
#import "vendor_private.h"

@implementation KCSettingsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.screenSplit.value = [[NSUserDefaults standardUserDefaults] floatForKey:PREF_KEY_SCRPARTITION];
    SplitOrientation splitOrientation = (SplitOrientation)[[NSUserDefaults standardUserDefaults] integerForKey:PREF_KEY_ORIENTATION];
    
    if (splitOrientation == kAuto)
        [self.orientation setSelectedSegmentIndex:1];
    else if (splitOrientation == kVertical)
        [self.orientation setSelectedSegmentIndex:0];
    else
        [self.orientation setSelectedSegmentIndex:2];
    
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *ver = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSRange range = [self.aboutLabel.attributedText.string rangeOfString:@"x.y_(z)"];
    NSMutableAttributedString *aboutContent = [self.aboutLabel.attributedText mutableCopy];
    [aboutContent replaceCharactersInRange:range withString:[NSString stringWithFormat:@"%@ (%@)", ver, build]];
    self.aboutLabel.attributedText = aboutContent;
}

- (IBAction)close:(id)sender {
    [self valueChanged:self.orientation];
    [self valueChanged:self.screenSplit];
    [self dismissViewControllerAnimated:NO completion:^{
        NSNotification *notification = [NSNotification notificationWithName:MSG_PARTITION_CHANGED object:nil userInfo:@{@"width":@(self.view.frame.size.width), @"height":@(self.view.frame.size.height)}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }];
}

- (IBAction)valueChanged:(id)sender {
    if (sender == self.orientation) {
        if (self.orientation.selectedSegmentIndex == 0)
            [[NSUserDefaults standardUserDefaults] setObject:@(kVertical) forKey:PREF_KEY_ORIENTATION];
        else if (self.orientation.selectedSegmentIndex == 1)
            [[NSUserDefaults standardUserDefaults] setObject:@(kAuto) forKey:PREF_KEY_ORIENTATION];
        else
            [[NSUserDefaults standardUserDefaults] setObject:@(kHorizontal) forKey:PREF_KEY_ORIENTATION];
    }

    if (sender == self.screenSplit) {
        [[NSUserDefaults standardUserDefaults] setFloat:self.screenSplit.value forKey:PREF_KEY_SCRPARTITION];
    }
}

- (IBAction)feedBack:(id)sender {
#ifdef SUPPORT_EMAIL
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:SUPPORT_EMAIL]];
#else
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"example@domain.net"]];
#endif
}

- (IBAction)howtoUse:(id)sender {
#ifdef SUPPORT_URL
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:SUPPORT_URL]];
#else
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.example.net/"]];
#endif
}

@end
