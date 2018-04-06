//
//  ViewController.h
//  Iconset
//
//  Created by Scott on 4/3/18.
//  Copyright © 2018 CrankySoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (readwrite)BOOL deleteFolder;
@property (strong) IBOutlet NSImageView *imageView;
@property (readwrite, retain)NSURL *url;
@property (strong) IBOutlet NSImage *image;

- (IBAction)setPNGFromURL:(id)sender;

@end

