//
//  WindowController.h
//  Image Opener
//
//  Created by Kelvin Sherlock on 3/1/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WindowController : NSWindowController <NSWindowDelegate> {
@private
    
    IBOutlet NSMatrix *_fsMatrix;
    IBOutlet NSMatrix *_ifMatrix;
    
    IBOutlet NSTextView *_textView;
    IBOutlet NSTextField *_nameView;
    IBOutlet NSTextField *_sizeView;
    
    IBOutlet NSButton *_mountButton;
    
    
    NSTask *_task;
    NSFileHandle *_handle;
    
    NSString *_filePath;
    
}

@property (nonatomic, retain) NSString *filePath;


+(id)controllerWithFilePath: (NSString *)filePath;

-(void)runTask;

-(IBAction)mountButton: (id)sender;


#pragma mark -
#pragma mark Notifications

-(void)readComplete:(NSNotification *)notification;
-(void)taskComplete: (NSNotification *)notification;
@end
