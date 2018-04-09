//
//  Task.h
//  Iconset
//
//  Created by Scott on 4/8/18.
//  Copyright © 2018 CrankySoft. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ViewController;

@interface Task : NSObject {
	
}

@property (readwrite, retain)ViewController* vc;

- (void)GenerateAll:(NSString*)path;

@end
