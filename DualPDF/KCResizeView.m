//
//  KCResizeView.m
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

#import "KCResizeView.h"

@interface KCResizeView ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* firstViewPercentWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* firstViewPercentTop;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* sliderWidth;
@property (nonatomic, weak) IBOutlet UILabel *firstViewPercentOnLeft;
@property (nonatomic, weak) IBOutlet UILabel *secondViewPercentOnRight;
@property (nonatomic, weak) IBOutlet UILabel *firstViewPercentOnTop;
@property (nonatomic, weak) IBOutlet UILabel *secondViewPercentOnBottom;

@end

@implementation KCResizeView

- (void)showResizeView:(CGFloat)split withVertical:(BOOL)isVertical withSize:(CGSize)newSize {
    self.isVerticalSplit = isVertical;

    CGAffineTransform noRotation = CGAffineTransformIdentity;
    self.slider.transform=noRotation;
    if (self.isVerticalSplit) {
        self.sliderWidth.constant = self.bounds.size.width * 0.7;
        self.slider.value = 1 - split;
    } else {
        CGAffineTransform sliderRotation = CGAffineTransformIdentity;
        sliderRotation = CGAffineTransformRotate(sliderRotation, -(M_PI / 2));
        self.slider.transform=sliderRotation;
        self.sliderWidth.constant = self.bounds.size.height * 0.7;
        self.slider.value = split;
    }
    self.firstViewPercentOnLeft.hidden = !self.isVerticalSplit;
    self.secondViewPercentOnRight.hidden = !self.isVerticalSplit;
    self.firstViewPercentOnTop.hidden = self.isVerticalSplit;
    self.secondViewPercentOnBottom.hidden = self.isVerticalSplit;
    [self valueChanged:nil];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [[UIColor colorWithWhite:0.3 alpha:1.0] set];
    CGRect firstHalf;
    if (self.isVerticalSplit)
        firstHalf = CGRectMake(0, 0, self.bounds.size.width * self.slider.value, self.bounds.size.height);
    else
        firstHalf = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height * (1-self.slider.value));
    UIRectFill(firstHalf);
}

- (IBAction)valueChanged:(id)sender {
    CGFloat firstW = self.bounds.size.width * self.slider.value - 20;
    CGFloat firstH = self.bounds.size.height * (1 - self.slider.value);

    self.firstViewPercentWidth.constant = firstW;
    self.firstViewPercentTop.constant = firstH;
    self.firstViewPercentOnLeft.text = [NSString stringWithFormat:@"%ld%%", (long)(self.slider.value * 100.0)];
    self.secondViewPercentOnRight.text = [NSString stringWithFormat:@"%ld%%", 100-(long)(self.slider.value * 100.0)];
    self.secondViewPercentOnBottom.text = [NSString stringWithFormat:@"%ld%%", (long)(self.slider.value * 100.0)];
    self.firstViewPercentOnTop.text = [NSString stringWithFormat:@"%ld%%", 100-(long)(self.slider.value * 100.0)];
    [self setNeedsDisplay];
}

@end
