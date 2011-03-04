//
//  Image_OpenerAppDelegate.h
//  Image Opener
//
//  Created by Kelvin Sherlock on 3/1/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Image_OpenerAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *_window;
    NSDocumentController *_controller;
}

@property (assign) IBOutlet NSWindow *window;


-(IBAction)openDocument:(id)sender;


@end
