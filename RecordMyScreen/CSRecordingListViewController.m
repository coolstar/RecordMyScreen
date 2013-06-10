//
//  CSRecordingListViewController.m
//  RecordMyScreen
//
//  Created by @coolstarorg on 12/30/12.
//  Copyright (c) 2012 CoolStar Organization. All rights reserved.
//

#import "CSRecordingListViewController.h"
#import <MediaPlayer/MediaPlayer.h>
@interface CSRecordingListViewController ()

@end

@implementation CSRecordingListViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Recordings", @"");
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"list"] tag:0] autorelease];
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Edit Video" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleEditVideo:)] autorelease];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEdit:)] autorelease];
        _folderItems = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self inDocumentsDirectory:@""] error:nil] mutableCopy];
        // Custom initialization
    }
    return self;
}
- (void)toggleEdit:(id)sender {
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:self.tableView.isEditing? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit target:self action:@selector(toggleEdit:)] autorelease];
}


- (void)toggleEditVideo:(id)sender {
    if (isEditing) {
        if (mySAVideoRangeSlider) {
            [mySAVideoRangeSlider removeFromSuperview];
        }
        if (ok) {
            [ok removeFromSuperview];
        }
        [self.navigationItem.leftBarButtonItem setTitle:@"Edit Video"];

    }else{
        [self.navigationItem.leftBarButtonItem setTitle:@"Done"];
    }
    isEditing=!isEditing;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_folderItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.textLabel.text = [_folderItems objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    NSString *fileName = [_folderItems objectAtIndex:indexPath.row];
    NSString *filePath = [self inDocumentsDirectory:fileName];
    
    unsigned long long size = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
    cell.detailTextLabel.text = [self humanReadableStringFromBytes:size];
    // Configure the cell...
    
    return cell;
}

- (NSString *)humanReadableStringFromBytes:(unsigned long long)byteCount
{
    
    float numberOfBytes = byteCount;
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB",@"EB",@"ZB",@"YB",nil];
    
    while (numberOfBytes > 1024) {
        numberOfBytes /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@",numberOfBytes, [tokens objectAtIndex:multiplyFactor]];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source and filesystem
        NSString *fileName = [_folderItems objectAtIndex:indexPath.row];
        NSString *filePath = [self inDocumentsDirectory:fileName];
        
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
        [_folderItems removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }    
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSString *fileName = [_folderItems objectAtIndex:indexPath.row];
    NSString *filePath = [self inDocumentsDirectory:fileName];
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    UIDocumentInteractionController *interactionController = [[UIDocumentInteractionController interactionControllerWithURL:fileURL] retain];
    [interactionController presentOptionsMenuFromRect:[tableView cellForRowAtIndexPath:indexPath].frame inView:self.view animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    row = indexPath.row;
    
    NSString *fileName = [_folderItems objectAtIndex:indexPath.row];
    NSString *filePath = [self inDocumentsDirectory:fileName];
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    // Navigation logic may go here. Create and push another view controller.
    if (!isEditing) {

        MPMoviePlayerViewController *moviePlayerController = [[[MPMoviePlayerViewController alloc] initWithContentURL:fileURL] autorelease];
        [moviePlayerController.moviePlayer prepareToPlay];
        // ...
        // Pass the selected object to the new view controller.
        [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
    } else {
        if (mySAVideoRangeSlider) {
            [mySAVideoRangeSlider removeFromSuperview];
        }
        mySAVideoRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(10, 100, self.view.frame.size.width-20, 50) videoUrl:fileURL ];
        mySAVideoRangeSlider.bubleText.font = [UIFont systemFontOfSize:12];
        [mySAVideoRangeSlider setPopoverBubbleSize:120 height:60];
        mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed:0.996 green:0.951 blue:0.502 alpha:1];
        mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed:0.992 green:0.902 blue:0.004 alpha:1];
    

        mySAVideoRangeSlider.delegate = self;
        [self.view addSubview:mySAVideoRangeSlider];
        ok = [UIButton buttonWithType:UIButtonTypeCustom];
        [ok setFrame:CGRectMake((self.view.frame.size.width/2)-50, 170, 100, 30)];
        [ok setBackgroundColor:[UIColor greenColor]];
        [ok setTitleColor:[UIColor blackColor] forState:0];
        [ok setTitle:@"Save" forState:0];
        [ok.layer setCornerRadius:8.0f];

        [ok addTarget:self action:@selector(pressed:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:ok];
    }
}

- (void)pressed:(id)sender{
    AVAssetExportSession *exportSession;
    // Navigation logic may go here. Create and push another view controller.
    NSString *fileName = [_folderItems objectAtIndex:row];
    NSString *filePath = [self inDocumentsDirectory:fileName];
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    AVAsset *anAsset = [[[AVURLAsset alloc] initWithURL:fileURL options:nil] autorelease];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:anAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        
        exportSession = [[AVAssetExportSession alloc]
                              initWithAsset:anAsset presetName:AVAssetExportPresetPassthrough];
        // Implementation continues.
        NSDate *today = [NSDate date];
        NSString *filePath = [self inDocumentsDirectory:[NSString stringWithFormat:@"%@-mod.mp4",today]];
        NSURL *furl = [NSURL fileURLWithPath:filePath];
        
        exportSession.outputURL = furl;
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        
        CMTime start = CMTimeMakeWithSeconds(startTime, anAsset.duration.timescale);
        CMTime duration = CMTimeMakeWithSeconds(stopTime-startTime, anAsset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        exportSession.timeRange = range;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                default:
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _folderItems = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self inDocumentsDirectory:@""] error:nil] mutableCopy];
                        [self.tableView reloadData];
                        [mySAVideoRangeSlider removeFromSuperview];
                        [ok removeFromSuperview];
                        mySAVideoRangeSlider=nil;
                        ok=nil;
                    });
                    
                    break;
            }
        }];
        
    }
    
}

- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    startTime = leftPosition;
    stopTime = rightPosition;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [_folderItems release];
    _folderItems = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self inDocumentsDirectory:@""] error:nil] mutableCopy];
    [self.tableView reloadData];
}

- (void)dealloc {
    [_folderItems release];
    [super dealloc];
}

#pragma mark - NSFileManager Methods

- (NSString *)inDocumentsDirectory:(NSString *)path {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:path];
}

@end
