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

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
	NSPasteboard *pboard;
	NSDragOperation sourceDragMask;
	
	sourceDragMask = [sender draggingSourceOperationMask];
	pboard = [sender draggingPasteboard];
	
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
		NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		
		if (files.count == 1) {
			NSString* path = [[files objectAtIndex:0] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
			NSURL* aURL = [NSURL URLWithString:path];
			NSString* ext = aURL.pathExtension.lowercaseString;
			if ([ext isEqualToString:@"png"]) {
				ViewController* vc = (ViewController*)(((AppDelegate*)[NSApp delegate]).vc);
				[vc setPNGFromURL:aURL];
			}
		}
	}
		
	return YES;
}

@end
