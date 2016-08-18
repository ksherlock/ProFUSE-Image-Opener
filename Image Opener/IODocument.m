//
//  IODocument.m
//  Image Opener
//
//  Created by Kelvin Sherlock on 8/17/2016.
//
//

#import "IODocument.h"


enum {
    kTagLucky = 1,
    kTag2MG,
    kTagDC42,
    kTagSDK,
    kTagDavex,
    kTagPO,
    kTagDO
};

static const char *TagToFormat(NSInteger tag)
{
    switch (tag)
    {
            
        case kTagPO:
        default:
            return "po";
        case kTagDO:
            return "do";
        case kTag2MG:
            return "2img";
        case kTagDC42:
            return "dc42";
        case kTagDavex:
            return "davex";
        case kTagSDK:
            return  "sdk";
            
    }
}

@implementation IODocument

@synthesize filePath = _filePath;

- (NSString *)windowNibName {
    return @"IODocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];



    [_nameView setStringValue: [_filePath lastPathComponent]];
    
    
    NSString *ss = @"";
    off_t size = [(NSNumber *)[_fileInfo objectForKey: NSFileSize] unsignedLongLongValue];
    
    if (size < 1024)
        ss = [NSString stringWithFormat: @"%u B", (unsigned)size];
    else if (size < 1024 * 1024)
        ss = [NSString stringWithFormat: @"%.1f KB", (double) size / 1024.0];
    
    else ss = [NSString stringWithFormat: @"%.1f MB", (double) size / (1024.0 * 1024.0)];
    
    [_sizeView setStringValue: ss];
    
    
    [_ifMatrix selectCellWithTag: kTagLucky];
    [_fsMatrix selectCellWithTag: 1]; // assume prodos.

}


-(BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable *)outError {

    NSString *path = [url isFileURL] ? [url path] : nil;
    
    //NSLog(@"%d %@", (int)result, path);
    
    [self setFileInfo: nil];
    [self setFilePath: nil];

    if (path) {

        NSFileManager *manager;
        NSDictionary *dict;
        NSError *error = nil;
        
        _filePath = [path retain];
        

        manager = [NSFileManager defaultManager];
        
        dict = [manager attributesOfItemAtPath: path error: &error];
        if (error) {
            *outError = error;
            return NO;
        }

        _fileInfo = [dict retain];

        
        return YES;
        
    } else {
        *outError = [NSError errorWithDomain: NSURLErrorDomain code: 1 userInfo: nil];
        return NO;
    }
    
}


+(BOOL)autosavesInPlace {
    // YES adds the rename drop down panel in the title bar!
    return NO;
}

- (void)dealloc
{
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc removeObserver: self];
    
    [_task release];
    [_handle release];
    
    [_filePath release];
    [super dealloc];
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
    NSMutableArray *argv;
    NSNotificationCenter *nc;
    NSString *exe;
    
    NSInteger tag;
    
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
    
    
    
    argv = [NSMutableArray arrayWithCapacity: 4];
    
    [argv addObject: @"-r"]; // read-only.
    
    tag = [_ifMatrix selectedTag];
    if (tag != kTagLucky)
    {
        [argv addObject: [NSString stringWithFormat: @"--format=%s", TagToFormat(tag)]];
    }
    
    [argv addObject: _filePath];
    
    
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
        [string release];
        
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

@end
