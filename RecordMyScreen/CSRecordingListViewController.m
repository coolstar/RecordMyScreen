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
        // Custom initialization
    }
    return self;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/video.mp4"]])
        return 1;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.textLabel.text = @"video.mp4";
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    //NSNumber *size = [[[NSFileManager defaultManager] attributesOfItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/video.mp4"] error:nil] objectForKey:@"NSFileSize"];
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",size.intValue]; //dirty but this should be replaced anyways
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
    UIDocumentInteractionController *interactionController = [[UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/video.mp4"]]] retain];
    [interactionController presentOptionsMenuFromRect:[tableView cellForRowAtIndexPath:indexPath].frame inView:self.view animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    MPMoviePlayerViewController *moviePlayerController = [[[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/video.mp4"]]] autorelease];
    [moviePlayerController.moviePlayer prepareToPlay];
     // ...
     // Pass the selected object to the new view controller.
    [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
}

-(void)viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
}

@end
