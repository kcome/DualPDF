//
//  KCDetailViewController.m
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

@import MobileCoreServices;

#import "common.h"
#import "KCPDFViewController.h"

@interface KCPDFViewController () {
    ReaderDocument *document;
    ReaderViewController *reader;
}
@end


@implementation KCPDFViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (IBAction)openPDF:(id)sender {
    if (document)
        document = nil;
    
#if TARGET_IPHONE_SIMULATOR
    NSString *path = [[NSBundle mainBundle] pathForResource:@"simulator" ofType:@"pdf"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *folder = [paths[0] stringByAppendingPathComponent:path.lastPathComponent];
    [[NSFileManager defaultManager] removeItemAtPath:folder error:NULL];
    [[NSFileManager defaultManager] copyItemAtURL:[NSURL fileURLWithPath:path] toURL:[NSURL fileURLWithPath:folder] error:NULL];
    [self openReader:path];
#else
    UIDocumentMenuViewController *docMenu = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypePDF] inMode:UIDocumentPickerModeImport];
    docMenu.delegate = self;
    if (!IS_PHONE) {
        docMenu.popoverPresentationController.sourceView = sender;
    }
    [self presentViewController:docMenu animated:YES completion:nil];
#endif
}

- (IBAction)infoClicked:(id)sender {
    [self performSegueWithIdentifier:@"openSettings" sender:self];
}

- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker {
    documentPicker.delegate = self;
    [self showViewController:documentPicker sender:self];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    NSError *err, *err2;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *folder = paths[0];
    NSString *path = [folder stringByAppendingPathComponent:url.pathComponents.lastObject];
    [[NSFileManager defaultManager] removeItemAtPath:path error:&err2];
    [url startAccessingSecurityScopedResource];
    [[NSFileManager defaultManager] copyItemAtURL:url toURL:[NSURL fileURLWithPath:path] error:&err];
    [url stopAccessingSecurityScopedResource];
    if (err) {
        NSLog(@"error while import file: %@", err);
        return;
    }
    [self openReader:path];
}

- (void)openReader:(NSString *)path {
    document = nil;
    document = [ReaderDocument withDocumentFilePath:path password:@""];

    if (!reader) {
        reader = [[ReaderViewController alloc] initWithReaderDocument:document];
    }
    reader.delegate = self;
    reader.view.frame = self.view.bounds;
    [self addChildViewController:reader];
    [self.view addSubview:reader.view];
    [reader didMoveToParentViewController:self];
}

- (void)dismissReaderViewController:(ReaderViewController *)viewController {
    if (reader) {
        [reader willMoveToParentViewController:nil];
        [reader.view removeFromSuperview];
        [reader removeFromParentViewController];
        reader = nil;
    }
}

- (void)dualPDFButtonClicked:(ReaderViewController *)viewController {
    [self.delegate changeScreenPartition:self];
}

- (void)reloadFile {
    if (reader) {
        [reader willMoveToParentViewController:nil];
        [reader.view removeFromSuperview];
        [reader removeFromParentViewController];
        reader = nil;
    }
    NSString *filepath = [NSString stringWithCString:document.fileURL.fileSystemRepresentation encoding:NSUTF8StringEncoding];
    [self openReader:filepath];
}

- (BOOL)readerIsOn {
    return reader != nil;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)documentMenuWasCancelled:(UIDocumentMenuViewController *)documentMenu {
    // stub method: do nothing
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    // stub method: do nothing
}

@end
