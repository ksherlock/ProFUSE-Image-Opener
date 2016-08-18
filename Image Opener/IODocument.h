//
//  IODocument.h
//  Image Opener
//
//  Created by Kelvin Sherlock on 8/17/2016.
//
//

#import <Cocoa/Cocoa.h>

@interface IODocument : NSDocument {

    IBOutlet NSMatrix *_fsMatrix;
    IBOutlet NSMatrix *_ifMatrix;
    
    IBOutlet NSTextView *_textView;
    IBOutlet NSTextField *_nameView;
    IBOutlet NSTextField *_sizeView;
    
    IBOutlet NSButton *_mountButton;
    
    
    NSTask *_task;
    NSFileHandle *_handle;
    
    NSString *_filePath;
    NSDictionary *_fileInfo;
    
}

@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, retain) NSDictionary *fileInfo;

-(void)runTask;

-(IBAction)mountButton: (id)sender;


#pragma mark -
#pragma mark Notifications

-(void)readComplete:(NSNotification *)notification;
-(void)taskComplete: (NSNotification *)notification;
@end
