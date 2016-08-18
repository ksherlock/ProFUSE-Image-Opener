//
//  Image_OpenerAppDelegate.m
//  Image Opener
//
//  Created by Kelvin Sherlock on 3/1/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Image_OpenerAppDelegate.h"

@implementation Image_OpenerAppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application


}

-(void)applicationWillFinishLaunching:(NSNotification *)notification {

}



-(BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    return NO;
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return NO;
}


@end
