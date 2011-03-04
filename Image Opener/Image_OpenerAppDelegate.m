//
//  Image_OpenerAppDelegate.m
//  Image Opener
//
//  Created by Kelvin Sherlock on 3/1/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Image_OpenerAppDelegate.h"
#import "WindowController.h"

@implementation Image_OpenerAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

-(IBAction)openDocument:(id)sender
{
    NSOpenPanel *panel;
    
    panel = [NSOpenPanel openPanel];
    
    [panel setCanChooseFiles: YES];
    [panel setCanCreateDirectories: NO];
    [panel setResolvesAliases: YES];
    [panel setAllowsMultipleSelection: NO];
    [panel setExtensionHidden: NO];
    
    
    [panel beginWithCompletionHandler: ^(NSInteger result){
        
        if (result == 1)
        {
            WindowController *controller;
            NSURL *url = [[panel URLs] lastObject];
            NSString *path = [url isFileURL] ? [url path] : nil;
            
            //NSLog(@"%d %@", (int)result, path);
            
            if (path)
            {
                controller = [WindowController controllerWithFilePath: path];
            }
            
        }
    }];
    
    
}

@end
