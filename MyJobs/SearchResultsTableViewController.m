//
//  SearchResultsTableViewController.m
//  MyJobs
//
//  Created by Joji Kubota on 4/12/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "SearchResultsTableViewController.h"
#import "IndeedAPIDataSource.h"
#import "Job.h"

@interface SearchResultsTableViewController ()

@property(nonatomic) IndeedAPIDataSource *dataSource;
@property(nonatomic) UIActivityIndicatorView *activityIndicator;

@end

static NSString *CellIdentifier = @"Cell"; // Pool of cells.

@implementation SearchResultsTableViewController

- (id)initWithDataSource: (IndeedAPIDataSource *) dataSource {
    /* Initializer */
    self = [super init];
    if (self) {
        // Custom initialization
    }
    self.title = @"Search Results";
    
    self.dataSource = dataSource;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* Reuse the cells using the identifier, "Cell" */
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    /* Update the table view */
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refreshTableView:) forControlEvents:UIControlEventValueChanged];
    
    /* Add the spinning gear to show progress */
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setCenter: self.view.center];
    [self.view addSubview: self.activityIndicator];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.dataSource getNumberOfJobs];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    /* Populate the rows with theater names */
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    //This allows for multiple lines
    cell.detailTextLabel.numberOfLines = 0;
    Job *iJob = [self.dataSource jobAtIndex: [indexPath row]];
    cell.textLabel.text = [iJob jobtitle];
    NSString *location;
    location = [NSString stringWithFormat: @"%@\n", [iJob company]];
    location = [location stringByAppendingString: [iJob city]];
    location = [location stringByAppendingString: @", "];
    location = [location stringByAppendingString: [iJob state]];
    location = [location stringByAppendingString: @", "];
    location = [location stringByAppendingString: [iJob formattedRelativeTime]];
//    location = [location stringByAppendingString: @"\n"];
//    location = [location stringByAppendingString: [iJob snippet]];
    
    cell.detailTextLabel.text = location;
    
    return cell;
}

-(void) refreshTableView: (UIRefreshControl *) sender
{   /* Refresh the table view */
    [self.tableView reloadData];
    [sender endRefreshing];
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   /* Respond to the touch at the row. Create and move to the detail view. */
//    IndeedJob *iJob = [self.dataSource jobAtIndex: [indexPath row]];
//    SearchResultsTableViewController *srtController = [[SearchResultsTableViewController alloc] initWithJob: iJob];
//    [self.navigationController pushViewController: srtController animated:YES];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{   /* Return the height of the row */
    return 70;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
