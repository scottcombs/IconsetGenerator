//
//  ViewController.m
//  Iconset
//
//  Created by Scott on 4/3/18.
//  Copyright © 2018 CrankySoft. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@implementation ViewController
@synthesize deleteFolder;
@synthesize imageView;
@synthesize image;
@synthesize url;


- (void)viewDidLoad {
	[super viewDidLoad];

	// Do any additional setup after loading the view.
	self.image = [NSImage imageNamed:@"Default.png"];
}

- (void)awakeFromNib{
	AppDelegate* ad = (AppDelegate*)[NSApp delegate];
	ad.vc = self;
}

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

	// Update the view, if already loaded.
}

- (IBAction)loadPNG:(id)sender {
	NSOpenPanel* panel = [NSOpenPanel openPanel];
	panel.directoryURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()]];
	panel.title = @"Select File";
	panel.message = @"Choose a PNG file of at least 1024px X 1024px";
	panel.allowedFileTypes = @[@"png"];
	panel.canChooseDirectories = NO;
	panel.canChooseFiles = YES;
	panel.allowsMultipleSelection = NO;
	NSModalResponse returnCode = [panel runModal];
	if (returnCode == NSModalResponseOK){
		[self setPNGFromURL:panel.URL];
	}
}

- (IBAction)generateIconset:(id)sender {
	NSDictionary* components = [self components:self.url];
	NSBundle* bundle = [NSBundle mainBundle];
	NSFileManager* fm = [[NSFileManager alloc]init];
	NSString* pathToSips = [bundle pathForResource:@"sips" ofType:@""];
	// Make an iconset folder
	
	NSString* pathToIconset = [NSString stringWithFormat:@"%@%@.iconset", [components objectForKey:@"path"], [components objectForKey:@"filename"]];
	
	// Remove if exists
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
		
		for (NSArray* item in array) {
			NSString* size = item[0];
			NSString* name = item[1];
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
	}
	// End
}

- (NSDictionary*)components:(NSURL*)url{
	NSString* extension = [url.path pathExtension];
	NSString* filename = self.url.lastPathComponent;
	NSString* path = [url.path stringByReplacingOccurrencesOfString:filename withString:@""];
	filename = [filename stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",extension] withString:@""];
	return @{@"path": path, @"filename": filename, @"extension": extension };
}

- (IBAction)setPNGFromURL:(id)sender {
	NSURL* url = (NSURL*)sender;
	self.url = [NSURL URLWithString:url.absoluteString];
	self.image = [[NSImage alloc]initByReferencingURL:self.url];
	[self.imageView setNeedsLayout:YES];
	[self generateIconset:self];
}

- (IBAction)createICNS:(id)sender{
	NSDictionary* components = [self components:self.url];
	NSBundle* bundle = [NSBundle mainBundle];
	NSFileManager* fm = [[NSFileManager alloc]init];
	NSString* pathToIconutil = [bundle pathForResource:@"iconutil" ofType:@""];
	NSString* pathToIconset = [NSString stringWithFormat:@"%@%@.iconset", [components objectForKey:@"path"], [components objectForKey:@"filename"]];
	
	// Remove is icn set exists
	NSString* icns = [NSString stringWithFormat:@"%@%@.icns",[components objectForKey:@"path"], [components objectForKey:@"filename"]];
	
	if ([fm fileExistsAtPath:icns]) {
		[fm removeItemAtPath:icns error:NULL];
	}
	
	// Create the icn set
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
