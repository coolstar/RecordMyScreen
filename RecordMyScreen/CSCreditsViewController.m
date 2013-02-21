//
//  CSCreditsViewController.m
//  RecordMyScreen
//
//  Created by @coolstarorg on 2/17/13.
//  Copyright (c) 2013 CoolStar Organization. All rights reserved.
//

#import "CSCreditsViewController.h"

@interface CSTableViewCell : UITableViewCell {
    UITextView *_descriptionTextLabel;
}
@property (nonatomic, retain) UITextView *descriptionTextLabel;
@end

@implementation CSTableViewCell
@synthesize descriptionTextLabel;

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = [self.textLabel frame];
    frame.origin.y = 5;
    [self.textLabel setFrame:frame];
    
    frame = [self.detailTextLabel frame];
    frame.origin.y = 5;
    [self.detailTextLabel setFrame:frame];
}

@end

@interface CSCreditsViewController () {
    NSArray *_credits;
}

@end

@implementation CSCreditsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"Credits", @"");
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:self.title image:[UIImage imageNamed:@"team"] tag:0] autorelease];
        _credits = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"plist"]];
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
    return [_credits count];
}

- (CSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CreditsIdentifier = @"CreditsIdentifier";
    CSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CreditsIdentifier];
    if (!cell){
        cell = [[[CSTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CreditsIdentifier] autorelease];
    }
    NSDictionary *person = [_credits objectAtIndex:indexPath.row];
    [cell.textLabel setText:[person objectForKey:@"name"]];
    
    NSString *description = [person objectForKey:@"description"];
    CGSize stringSize = [description sizeWithFont:[UIFont boldSystemFontOfSize:15] constrainedToSize:CGSizeMake(self.view.bounds.size.width, 9999) lineBreakMode:UILineBreakModeWordWrap];
    
    if (cell.descriptionTextLabel == nil){
        UITextView *descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 25, 290, stringSize.height+10)];
        [descriptionTextView setFont:[UIFont systemFontOfSize:15.0]];
        [descriptionTextView setText:description];
        [descriptionTextView setTextColor:[UIColor blackColor]];
        [descriptionTextView setBackgroundColor:[UIColor clearColor]];
        [descriptionTextView setEditable:NO];
        [descriptionTextView setScrollEnabled:NO];
        [descriptionTextView setUserInteractionEnabled:NO];
        [cell.contentView addSubview:[descriptionTextView autorelease]];
        [cell setDescriptionTextLabel:descriptionTextView];
    }
    
    if ([person objectForKey:@"twitter"] != nil) {
        [cell.detailTextLabel setText:[@"@" stringByAppendingString:[person objectForKey:@"twitter"]]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *person = [_credits objectAtIndex:indexPath.row];
    NSString *description = [person objectForKey:@"description"];
    CGSize stringSize = [description sizeWithFont:[UIFont boldSystemFontOfSize:15]
                          constrainedToSize:CGSizeMake(self.view.bounds.size.width, 9999)
                              lineBreakMode:UILineBreakModeWordWrap];
    
    return stringSize.height+40;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *person = [_credits objectAtIndex:indexPath.row];
    if ([person objectForKey:@"twitter"] != nil) {
        NSString *twitterLink = [@"https://www.twitter.com/" stringByAppendingString:[person objectForKey:@"twitter"]];
        NSURL *twitterUrl = [NSURL URLWithString:twitterLink];
        [[UIApplication sharedApplication] openURL:twitterUrl];
    }
}

- (void)dealloc {
    [_credits release];
    [super dealloc];
}

@end
