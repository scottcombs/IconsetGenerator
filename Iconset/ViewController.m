//
//  ViewController.m
//  Iconset
//
//  Created by Scott on 4/3/18.
//  Copyright © 2018 CrankySoft. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Task.h"

@implementation ViewController
@synthesize deleteFolder;
@synthesize imageView;
@synthesize image;
@synthesize url;
@synthesize generateICNSFileButton;
@synthesize task;

static void *ImageContext = &ImageContext;

- (BOOL)application:(NSApplication *)sender delegateHandlesKey:(NSString *)key {
	
	if ([key isEqualToString:@"tasks"]) {
		return YES;
	}
		 
	return NO;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	// Do any additional setup after loading the view.
	self.image = [NSImage imageNamed:@"Default.png"];
}

- (void)awakeFromNib{
	// Set ourselves to the AppDelegate so drag operations can
	// find us easier
	AppDelegate* ad = (AppDelegate*)[NSApp delegate];
	ad.vc = self;
	
	self.task.vc = self;
	
	// Add ourselves to observe the image property
	[self addObserver:self forKeyPath:@"image" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
				 context:ImageContext];
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

	// Update the view, if already loaded.
}

/**
 We observe when the image is set or unset to
 enable or disable the generate icns button

 @param keyPath Path to the image property
 @param object Use (self)
 @param change What kind of change
 @param context Specifically the image context
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	
	if (context == ImageContext) {
		// Check to see if image is null or new
		if (self.image) {
			if ([self.image.name isEqualToString:@"Default"]) {
				// If we are the default image
				self.generateICNSFileButton.enabled = NO;
			}else{
				// A good image to work with
				self.generateICNSFileButton.enabled = YES;
			}
		}else{ // This is when the user deletes the image
			// We need to do this in its own thread to work properly
			__unused NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:NO block:^(NSTimer * _Nonnull timer) {
				// Set the default image
				self.image = [NSImage imageNamed:@"Default.png"];
				// Force a refresh
				[self.imageView setNeedsLayout:YES];
				// Disable the button
				self.generateICNSFileButton.enabled = NO;
			}];
		}
	}
}

/**
 Generate an iconset from a URL.

 @param sender (unused)
 */
- (IBAction)generateIconset:(id)sender {
	// Get all the parts we need from the URL
	NSDictionary* components = [self components:self.url];
	
	// Find the SIPS app in our bundle
	NSBundle* bundle = [NSBundle mainBundle];
	NSFileManager* fm = [[NSFileManager alloc]init];
	NSString* pathToSips = [bundle pathForResource:@"sips" ofType:@""];
	
	// Make an iconset folder
	NSString* pathToIconset = [NSString stringWithFormat:@"%@%@.iconset", [components objectForKey:@"path"], [components objectForKey:@"filename"]];
	
	// Remove the old one if exists
	NSError* err;
	[fm removeItemAtPath:pathToIconset error:&err];
	
	// Create the folder
	NSTask* mkDir = [[NSTask alloc]init];
	mkDir.launchPath = @"/bin/mkdir";
	mkDir.arguments = @[pathToIconset];
	[mkDir launch];
	[mkDir waitUntilExit];
	
	// Continue if folder was made
	BOOL isDir;
	if ([fm fileExistsAtPath:pathToIconset isDirectory:&isDir]) {
		
		// Set up all our sizes
		NSArray* array = @[@[@"16", @"icon_16x16.png"],
						   @[@"32", @"icon_16x16@2x.png"],
						   @[@"32", @"icon_32x32.png"],
						   @[@"64", @"icon_32x32@2x.png"],
						   @[@"128", @"icon_128x128.png"],
						   @[@"256", @"icon_128x128@2x.png"],
						   @[@"256", @"icon_256x256.png"],
						   @[@"512", @"icon_256x256@2x.png"],
						   @[@"512", @"icon_512x512.png"],
						   @[@"1024", @"icon_512x512@2x.png"]];
		
		// Run through each item in the array and build an icon
		for (NSArray* item in array) {
			NSString* size = item[0];
			NSString* name = item[1];
			
			// Process through sips for a sized icon
			NSTask* task = [[NSTask alloc]init];
			task.launchPath = pathToSips;
			NSString* arg1 = @"-Z";
			NSString* arg2 = [NSString stringWithFormat:@"%@", size];
			NSString* arg3 = [NSString stringWithFormat:@"%@", self.url.path];
			NSString* arg4 = @"--out";
			NSString* arg5 = [NSString stringWithFormat:@"%@/%@", pathToIconset, name];
			[task setArguments:@[arg1, arg2, arg3, arg4, arg5]];
			[task launch];
			[task waitUntilExit];
		}

		// Create Content.json file
		NSBundle *myBundle = [NSBundle mainBundle];
		NSString *absPath= [myBundle pathForResource:@"Contents" ofType:@"json"];
		NSString *pathToContentsJson = [[NSString alloc]initWithFormat:@"%@/Contents.json", pathToIconset];
		NSData* data = [[NSData alloc] initWithContentsOfFile:absPath];
		if (data != nil) {
			[data writeToFile:pathToContentsJson atomically:YES];
		}
		
	}
	// End of creating icons
}

/**
 Component is a convenience method to get all the pars
 we need to rebuild a path and files. It gives us a
 Dictionary for the path, filename and extension.

 @param url The URL to decompose
 @return NSDictionary containing the 3 components
 */
- (NSDictionary*)components:(NSURL*)url {
	NSString* extension = [url.path pathExtension];
	NSString* filename = self.url.lastPathComponent;
	NSString* path = [url.path stringByReplacingOccurrencesOfString:filename withString:@""];
	filename = [filename stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",extension] withString:@""];
	
	return @{@"path": path, @"filename": filename, @"extension": extension };
}

/**
 Process the URL to interface with our app

 @param sender Is a NSURL of the PNG file
 */
- (IBAction)setPNGFromURL:(id)sender {
	NSURL* url = (NSURL*)sender;
	NSString* path = [url.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
	path = [NSString stringWithFormat:@"file://%@", path];
	self.url = [NSURL URLWithString:path];
	self.image = [[NSImage alloc]initByReferencingURL:self.url];
	[self.imageView setNeedsLayout:YES];
	[self generateIconset:self];
}

/**
 Create an ICNS file from the iconset folder

 @param sender (unused)
 */
- (IBAction)createICNS:(id)sender {
	// Get the components of the iconset
	NSDictionary* components = [self components:self.url];
	
	// Get the path of iconutil app in our bundle
	NSBundle* bundle = [NSBundle mainBundle];
	NSFileManager* fm = [[NSFileManager alloc]init];
	NSString* pathToIconutil = [bundle pathForResource:@"iconutil" ofType:@""];
	
	// Construct path to match the iconset folder
	NSString* pathToIconset = [NSString stringWithFormat:@"%@%@.iconset", [components objectForKey:@"path"], [components objectForKey:@"filename"]];
	
	// Path to icns file to be made
	NSString* icns = [NSString stringWithFormat:@"%@%@.icns",[components objectForKey:@"path"], [components objectForKey:@"filename"]];
	
	// Remove old icns file if necessary
	if ([fm fileExistsAtPath:icns]) {
		[fm removeItemAtPath:icns error:NULL];
	}
	
	// Create the icns file
	NSTask* task = [[NSTask alloc]init];
	task.launchPath = pathToIconutil;
	NSString* arg1 = @"-c";
	NSString* arg2 = @"icns";
	NSString* arg3 = pathToIconset;
	[task setArguments:@[arg1, arg2, arg3]];
	[task launch];
	[task waitUntilExit];
}

@end
