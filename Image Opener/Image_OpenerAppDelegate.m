//
//  Image_OpenerAppDelegate.m
//  Image Opener
//
//  Created by Kelvin Sherlock on 3/1/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Image_OpenerAppDelegate.h"
#import "WindowController.h"
#import "IODocumentController.h"

@implementation Image_OpenerAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application


}

-(void)applicationWillFinishLaunching:(NSNotification *)notification {

    // initialize the shared document controller.
    //[[IODocumentController alloc] init];
}

#if 0
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    [WindowController controllerWithFilePath: filename];
    return YES;
}
#endif

-(BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    return NO;
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return NO;
}

#if 0
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

                [WindowController controllerWithFilePath: path];
                
                [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL: url];
            }
            
        }
    }];
    
    
}
#endif

@end
