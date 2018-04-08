//
//  NSImageView+NSImageViewExtensions.m
//  Iconset
//
//  Created by Scott on 4/3/18.
//  Copyright © 2018 CrankySoft. All rights reserved.
//

#import "NSImageView+NSImageViewExtensions.h"
#import "AppDelegate.h"
#import "ViewController.h"

@implementation NSImageView (NSImageViewExtensions)

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

/**
 Override the default performDragOperation to handle our needs

 @param sender The info of the drag object
 @return A boolean to continue
 */
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
	NSPasteboard *pboard;
	NSDragOperation sourceDragMask;
	
	sourceDragMask = [sender draggingSourceOperationMask];
	pboard = [sender draggingPasteboard];
	
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
		NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		
		// Only handle one dropped object
		if (files.count == 1) {
			// Get the path and fix it if we need to for the URL
			NSString* path = [[files objectAtIndex:0] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
			
			// Create a URL so we can check for a PNG
			NSURL* aURL = [NSURL URLWithString:path];
			NSString* ext = aURL.pathExtension.lowercaseString;
			
			// A valid PNG to use
			if ([ext isEqualToString:@"png"]) {
				// Good to go - send to ViewController for processing
				ViewController* vc = (ViewController*)(((AppDelegate*)[NSApp delegate]).vc);
				[vc setPNGFromURL:aURL];
			}
		}
	}
		
	return YES;
}

@end
