//
//  PerformGenerateScript.m
//  Iconset
//
//  Created by Scott on 4/8/18.
//  Copyright © 2018 CrankySoft. All rights reserved.
//

#import "PerformGenerateScript.h"
#import "scriptLog.h"
#import "AppDelegate.h"
#import "ViewController.h"

@implementation PerformGenerateScript

- (id)performDefaultImplementation {
	// Create a URL so we can check for a PNG
	NSString* param = self.directParameter;
	if (![param containsString:@"file://"]) {
		//Add file scheme
		param = [param stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLPathAllowedCharacterSet];
	}
	
	NSURL* aURL = [NSURL URLWithString:param];
	if (aURL) {
		NSString* ext = aURL.pathExtension.lowercaseString;
		
		// A valid PNG to use
		if ([ext isEqualToString:@"png"]) {
			// Good to go - send to ViewController for processing
			ViewController* vc = (ViewController*)((AppDelegate*)NSApp.delegate).vc;
			if (vc) {
				[vc setPNGFromURL:aURL];
				__unused NSTimer* tm = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:NO block:^(NSTimer * _Nonnull timer) {
					[vc createICNS:self];
				}];
			}
		}
	}
	
	/* return the quoted direct parameter to show how to return a string from a command */
	return [NSString stringWithFormat:@"'%@'", [self directParameter]];
}


@end
