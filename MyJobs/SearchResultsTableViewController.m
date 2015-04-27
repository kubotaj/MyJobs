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
#import "ResultDetailViewController.h"

@interface SearchResultsTableViewController ()

@property(nonatomic) IndeedAPIDataSource *dataSource;
@property(nonatomic) NSMutableArray *jobsArray;
@property(nonatomic) UIActivityIndicatorView *activityIndicator;
@property(nonatomic) bool whichInit; // false for dataSource, true for jobsArray

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
    self.whichInit = false;
    
    return self;
}

- (id) initWithJobsArray: (NSMutableArray *) jobsArray {
    self = [super init];
    if (self) {
        // Custom init
    }
    self.title = @"Search Results";
    
    self.jobsArray = jobsArray;
    self.whichInit = true;
    
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
    if (!self.whichInit)
        return [self.dataSource getNumberOfJobs];
    else
        return [self.jobsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    /* Populate the rows with theater names */
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    //This allows for multiple lines
    cell.detailTextLabel.numberOfLines = 0;
    Job *job;
    if (!self.whichInit)
        job = [self.dataSource jobAtIndex: [indexPath row]];
    else
        job = self.jobsArray[[indexPath row]];
    cell.textLabel.text = [job jobtitle];
    NSString *location;
    location = [NSString stringWithFormat: @"%@\n", [job company]];
    if (![[job city] isEqualToString:@""]){
        location = [location stringByAppendingString: [job city]];
        if (![[job state] isEqualToString:@""]){
            location = [location stringByAppendingString: @", "];
            location = [location stringByAppendingString: [job state]];
        }
        location = [location stringByAppendingString: @", "];
    }
    location = [location stringByAppendingString: [job formattedRelativeTime]];
//    location = [location stringByAppendingString: @"\n"];
//    location = [location stringByAppendingString: [iJob snippet]];
    
    cell.detailTextLabel.text = location;
    
    //image setup
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    switch (job.sourceType) {
        case 1:
            imgView.image = [UIImage imageNamed:@"monster.png"];
            break;
        case 2:
            imgView.image = [UIImage imageNamed:@"careerbuilder.png"];
            break;
        case 3:
            imgView.image = [UIImage imageNamed:@"indeed"];
            break;
        default:
            break;
    }
    cell.imageView.image = imgView.image;
    
    return cell;
}

-(void) refreshTableView: (UIRefreshControl *) sender
{   /* Refresh the table view */
    [self.tableView reloadData];
    [sender endRefreshing];
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   /* Respond to the touch at the row. Create and move to the detail view. */
    Job *job;
    if (!self.whichInit)
        job = [self.dataSource jobAtIndex: [indexPath row]];
    else
        job = self.jobsArray[[indexPath row]];
    NSLog(@"the index number: %d", [indexPath row]);
     ResultDetailViewController *rvController = [[ResultDetailViewController alloc] initWithJob: job];
    [self.navigationController pushViewController: rvController animated:YES];
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
