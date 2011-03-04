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

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _controller = [[NSDocumentController sharedDocumentController] retain];
    // Insert code here to initialize your application
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    WindowController *controller;
    controller = [WindowController controllerWithFilePath: filename];
    return YES;
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
            NSURL *url = [[panel URLs] lastObject];
            NSString *path = [url isFileURL] ? [url path] : nil;
            
            //NSLog(@"%d %@", (int)result, path);
            
            if (path)
            {
                [self application: nil openFile: path];
                
                [_controller noteNewRecentDocumentURL: url];
            }
            
        }
    }];
    
    
}

@end
