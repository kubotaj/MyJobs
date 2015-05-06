//
//  FavoritesTableViewController.m
//  MyJobs
//
//  Created by Joji Kubota on 4/4/15.
//  Copyright (c) 2015 Joji Kubota. All rights reserved.
//

#import "FavoritesTableViewController.h"
#import "FavoriteDataSource.h"
#import "Job.h"
#import "ResultDetailViewController.h"

@interface FavoritesTableViewController ()

@property(nonatomic) NSMutableArray *jobsArray;
@property(nonatomic) UIActivityIndicatorView *activityIndicator;
@property(nonatomic) UserSettings* us;
@property(nonatomic) UIColor *cellColorVeryHighScore;
@property(nonatomic) UIColor *cellColorHighScore;
@property(nonatomic) UIColor *cellColorMediumScore;
@property(nonatomic) UIColor *cellColorLowScore;
@property(nonatomic) UIColor *cellColorVeryLowScore;
@property(nonatomic) Job *testFav;
@property(nonatomic) MFMailComposeViewController *mailvController;

@end

static NSString *CellIdentifier = @"Cell"; // Pool of cells.

@implementation FavoritesTableViewController

- (instancetype) init {
    if ((self = [super init]) == nil) {
        return nil;
    }
    
    self.title = @"Favorites";
    
    /* Initialize the data source */
    FavoriteDataSource *fDataSource = [[FavoriteDataSource alloc] init];
    self.jobsArray = [fDataSource getAllJobs];
    
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
    
    /* Email the list NOT WORKING WITH SIMULATOR */
    [self cycleTheGlobalMailComposer];
    self.mailvController.mailComposeDelegate = self;
    
    [self refreshTableView:self.refreshControl];
    
//     Uncomment the following line to preserve selection between presentations.
//     self.clearsSelectionOnViewWillAppear = NO;
    
//     Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshTableView:self.refreshControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.jobsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /* Populate the rows with jobs */
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    //This allows for multiple lines
    cell.detailTextLabel.numberOfLines = 0;
    
    Job *job = [[Job alloc] init];
    job = self.jobsArray[indexPath.row];
    cell.textLabel.text = job.jobtitle;
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
    
    cell.detailTextLabel.text = location;
    
    //image setup
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    NSLog(@"jobSourcetype: %d", job.sourceType);
    if (job.isFav){
        switch (job.sourceType) {
            case 1:
                imgView.image = [UIImage imageNamed:@"monsterFav.png"];
                break;
            case 2:
                imgView.image = [UIImage imageNamed:@"careerbuilderFav.png"];
                break;
            case 3:
                imgView.image = [UIImage imageNamed:@"indeedFav.png"];
                break;
            default:
                break;
        }
    }
    else {
        switch (job.sourceType) {
            case 1:
                imgView.image = [UIImage imageNamed:@"monster.png"];
                break;
            case 2:
                imgView.image = [UIImage imageNamed:@"careerbuilder.png"];
                break;
            case 3:
                imgView.image = [UIImage imageNamed:@"indeed.png"];
                break;
            default:
                break;
        }
        
    }
    cell.imageView.image = imgView.image;
    cell.backgroundColor = [self findCellColor:job.score];
    
    return cell;
}

-(void) refreshTableView: (UIRefreshControl *) sender
{   /* Refresh the table view */
    [self init];
    [self.tableView reloadData];
    [sender endRefreshing];
}

- (UIColor *) findCellColor:(int) score{
    //NSLog(@"Returning color for score: %d", score);
    if (score > (int)([self.us findScoreMax] * 0.80))
        return self.cellColorVeryHighScore;
    if (score > (int)([self.us findScoreMax] * 0.60))
        return self.cellColorHighScore;
    if (score > (int)([self.us findScoreMax] * 0.45))
        return self.cellColorMediumScore;
    if (score > (int)([self.us findScoreMax] * 0.30))
        return self.cellColorLowScore;
    if (score <= (int)([self.us findScoreMax] * 0.30))
        return self.cellColorVeryLowScore;
    return [UIColor whiteColor];
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   /* Respond to the touch at the row. Create and move to the detail view. */
    Job *job;
    job = self.jobsArray[[indexPath row]];
    ResultDetailViewController *rvController = [[ResultDetailViewController alloc] initWithJob: job];
    [self.navigationController pushViewController: rvController animated:YES];
    
    // Mail feature does not work on iPhone simulator
    
    //    if([MFMailComposeViewController canSendMail]) {
    //        [self.mailvController setSubject:@"Doesn't work on simulator!"];
    //        [self presentViewController:self.mailvController animated:YES completion:nil];
    //    }
    //    else
    //    {
    //        NSLog(@"Unable to mail. No email on this device?");
    //    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{   /* Return the height of the row */
    return 70;
}

// Then implement the delegate method
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
        [controller dismissViewControllerAnimated:YES completion:^
        { [self cycleTheGlobalMailComposer]; }
        ];
}

-(void)cycleTheGlobalMailComposer
{
        // we are cycling the damned GlobalMailComposer... due to horrible iOS issue
        self.mailvController = nil;
        self.mailvController = [[MFMailComposeViewController alloc] init];
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
