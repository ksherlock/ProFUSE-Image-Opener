//
//  WindowController.m
//  Image Opener
//
//  Created by Kelvin Sherlock on 3/1/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WindowController.h"


@implementation WindowController

@synthesize filePath = _filePath;

static const char *TagToFormat(NSInteger tag)
{
    switch (tag)
    {

        case 1:
        default:
            return "po";
        case 2:
            return "do";
        case 3:
            return "2img";
        case 4:
            return "dc42";
        case 5:
            return "davex";
    
    }
    
}

+(id)new
{
    return [[self alloc] initWithWindowNibName: @"Window"];
        
}

+(id)controllerWithFilePath: (NSString *)filePath
{
    WindowController *controller = [[self alloc] initWithWindowNibName: @"Window"];
    NSWindow *window = [controller window]; // force a load...

    [controller setFilePath: filePath];
    
    [window makeKeyAndOrderFront: nil];
    [window makeFirstResponder: nil];
    
    return controller;
}


- (void)dealloc
{
    //NSLog(@"%s %@", sel_getName(_cmd), self);
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc removeObserver: self];
    
    [_task release];
    [_handle release];

    [_filePath release];
    [super dealloc];
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


#pragma mark -


-(void)setFilePath:(NSString *)filePath
{
    NSString *ext;
    NSFileManager *manager;
    NSDictionary *dict;
    NSError *error;
    unsigned format;
    
    if (_filePath == filePath) return;
    
    [_filePath release];
    _filePath = [filePath retain];
    
    [[self window] setTitleWithRepresentedFilename: filePath];
    
    [_nameView setStringValue: [_filePath lastPathComponent]];
    
    
    manager = [NSFileManager defaultManager];
    
    error = nil;
    dict = [manager attributesOfItemAtPath: filePath error: &error];
    
    if (error)
    {
        [_sizeView setStringValue: @""];
        [_mountButton setEnabled: NO];
        [_textView setString: [error localizedDescription]];
    }
    else
    {
        NSString *ss = @"";
        size_t size = [(NSNumber *)[dict objectForKey: NSFileSize] unsignedLongLongValue];
        
        if (size < 1024) 
            ss = [NSString stringWithFormat: @"%u B", (unsigned)size];
        else if (size < 1024 * 1024)
            ss = [NSString stringWithFormat: @"%.1f KB", (double) size / 1024.0];
        
        else ss = [NSString stringWithFormat: @"%.1f MB", (double) size / (1024.0 * 1024.0)];
        
        [_sizeView setStringValue: ss];
        
    }
    
    
    // set the default image format.
    
    
    ext = [_filePath pathExtension];

    ext = [ext lowercaseString];
    
    format = 1;
    
    if ([ext isEqualToString: @"po"] ||
        [ext isEqualToString: @"raw"])
    {
        format = 1;
    }
    else if ([ext isEqualToString: @"do"] ||
             [ext isEqualToString: @"dsk"])
    {
        format = 2;
    }
    else if ([ext isEqualToString: @"2mg"] ||
             [ext isEqualToString: @"2img"])
    {
        format = 3;
    }
    else if ([ext isEqualToString: @"dc42"])
    {
        format = 4;
    }
    else if ([ext isEqualToString: @"davex"] ||
             [ext isEqualToString: @"dvx"])
    {
        format = 5;
    }
    
    [_ifMatrix selectCellWithTag: format];
    [_fsMatrix selectCellWithTag: 1]; // assume prodos.

}


-(IBAction)mountButton: (id)sender
{
    [_mountButton setEnabled: NO];

    [self runTask];
}

-(void)appendString: (NSString *)string
{
    if ([string length])
    {
        [[[_textView textStorage] mutableString] appendString: string];
    }
}


-(void)runTask
{
    NSPipe *pipe = [NSPipe pipe];
    NSString *launchPath;
    NSArray *argv;
    NSNotificationCenter *nc;
    NSString *exe;
    
    _task = [[NSTask alloc] init];
    
    [_task setStandardError: pipe];
    [_task setStandardOutput: pipe];
    [_task setStandardInput: [NSFileHandle fileHandleWithNullDevice]];
    
    _handle = [[pipe fileHandleForReading] retain];
    
    
    switch ([_fsMatrix selectedTag])
    {
        case 1:
        default:
            exe = @"profuse";
            break;
        case 2:
            exe = @"fuse_pascal";
            break;
    }
    
    launchPath = [[NSBundle mainBundle] pathForAuxiliaryExecutable: exe];

    
    argv = [NSArray arrayWithObjects:
            @"-r",
            [NSString stringWithFormat: @"--format=%s", TagToFormat([_ifMatrix selectedTag])],
            _filePath
            , nil];
    
    
    
    [_task setLaunchPath: launchPath];
    [_task setArguments: argv];
    
    [self appendString: launchPath];

    for (NSString *string in argv)
    {
        [self appendString: @" "];
        [self appendString: string];
    }
    [self appendString: @"\n\n"];
    
    
    nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver: self 
           selector: @selector(taskComplete:) 
               name: NSTaskDidTerminateNotification 
             object: _task];
    [nc addObserver: self 
           selector: @selector(readComplete:) 
               name: NSFileHandleReadCompletionNotification 
             object: _handle];
    
 
    [_task launch];
    [_handle readInBackgroundAndNotify];
     
}



#pragma mark -
#pragma mark Notifications
-(void)readComplete:(NSNotification *)notification
{
    // read complete, queue up another.
    NSDictionary *dict = [notification userInfo];
    NSData *data = [dict objectForKey: NSFileHandleNotificationDataItem];
    
    if ([data length])
    {
        
        NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];

        [self appendString: string];
        [_handle readInBackgroundAndNotify];        
    }
    
}

-(void)taskComplete: (NSNotification *)notification
{
    BOOL ok = NO;
    NSTaskTerminationReason reason;
    int status;
    NSString *string = nil;
    
    reason = [_task terminationReason];
    status = [_task terminationStatus];

    if (reason == NSTaskTerminationReasonExit)
    {
        
        if (status == 0)
        {
            string = @"\n\n[Success]\n\n";
            ok = YES;
        }
        else string = @"\n\n[An error occurred]\n\n";
    }
    else
    {
        string = @"\n\n[Caught signal]\n\n";
        
    }
    
    [self appendString: string];
    
    [_handle release];
    _handle = nil;
    
    [_task release];
    _task = nil;
    
    if (!ok) [_mountButton setEnabled: YES];

}
#pragma mark -
#pragma mark NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    [self release];
}

@end
