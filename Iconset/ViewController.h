//
//  ViewController.h
//  Iconset
//
//  Created by Scott on 4/3/18.
//  Copyright © 2018 CrankySoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Task;

@interface ViewController : NSViewController

@property (readwrite)BOOL deleteFolder;
@property (strong) IBOutlet NSImageView *imageView;
@property (readwrite, retain)NSURL *url;
@property (strong) IBOutlet NSImage *image;
@property (strong) IBOutlet NSButton *generateICNSFileButton;
@property (readwrite, retain)Task* task;

- (IBAction)setPNGFromURL:(id)sender;
- (IBAction)generateIconset:(id)sender;
- (NSDictionary*)components:(NSURL*)url;
- (IBAction)createICNS:(id)sender;

@end

