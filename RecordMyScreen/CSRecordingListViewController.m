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
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEdit:)] autorelease];
        _folderItems = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"] error:nil] mutableCopy];
        // Custom initialization
    }
    return self;
}

- (void)toggleEdit:(id)sender {
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:self.tableView.isEditing? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit target:self action:@selector(toggleEdit:)] autorelease];
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
    NSString *fileDirectory = [@"Documents/" stringByAppendingString:fileName];
    
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:fileDirectory];
    
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
        NSString *fileDirectory = [@"Documents/" stringByAppendingString:fileName];
        
        NSURL *fileURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:fileDirectory]];
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
    NSString *fileDirectory = [@"Documents/" stringByAppendingString:fileName];
    
    NSURL *fileURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:fileDirectory]];
    
    UIDocumentInteractionController *interactionController = [[UIDocumentInteractionController interactionControllerWithURL:fileURL] retain];
    [interactionController presentOptionsMenuFromRect:[tableView cellForRowAtIndexPath:indexPath].frame inView:self.view animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    NSString *fileName = [_folderItems objectAtIndex:indexPath.row];
    NSString *fileDirectory = [@"Documents/" stringByAppendingString:fileName];
    
    NSURL *fileURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:fileDirectory]];
    
    MPMoviePlayerViewController *moviePlayerController = [[[MPMoviePlayerViewController alloc] initWithContentURL:fileURL] autorelease];
    [moviePlayerController.moviePlayer prepareToPlay];
     // ...
     // Pass the selected object to the new view controller.
    [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
}

- (void)viewDidAppear:(BOOL)animated {
    [_folderItems release];
    _folderItems = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"] error:nil] mutableCopy];
    [self.tableView reloadData];
}

- (void)dealloc {
    [_folderItems release];
    [super dealloc];
}

@end
