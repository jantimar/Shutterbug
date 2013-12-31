//
//  RecentTableViewController.m
//  Shutterbug
//
//  Created by Jan Timar on 10/30/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import "RecentTableViewController.h"
#import "Photo+recent.h"
#import "Photo+save.h"
#import "AppDelegate.h"
#import "PhotoThumbnail.h"

@interface RecentTableViewController ()

// pole poslednych 10tich zobrazenych fotiek
@property (nonatomic,strong) NSArray *photos;

@end

@implementation RecentTableViewController

// seter pre nastavenie pola fotiek
// v osobytnom vlakne reloadne zoznam fotiek
-(void)setPhotos:(NSArray *)photos
{
    [self.refreshControl beginRefreshing];
    _photos = photos;
    dispatch_queue_t loadPhotosQueue = dispatch_queue_create("flicker latest loader", NULL);
    dispatch_async(loadPhotosQueue, ^{
        [self.tableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
        });
    });
}

// po zobrazeni UI zavola natiahnutie poslednych zobrazenych fotiek z databazy
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.refreshControl beginRefreshing];
    self.photos = [Photo recentlyPhotosInManagedObjectContext:((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Recent Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Photo *photo = [self.photos objectAtIndex:indexPath.row];
    
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    cell.imageView.image = [UIImage imageWithData:photo.thumbnail.thumbnail];
    
    return cell;
}

// kliknutie na cell zavola segue pre zobrazenie obrazka
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // treba takto volat inac sa preprae for segue nechce zavolat
    [self performSegueWithIdentifier:@"Show Image" sender:[tableView cellForRowAtIndexPath:indexPath]];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([sender isKindOfClass:[UITableViewCell class]]){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if(indexPath){
            Photo *photo = [self.photos objectAtIndex:indexPath.row];
            if([segue.identifier isEqualToString:@"Show Image"]){
                SEL selectorSetImageURL = NSSelectorFromString(@"setImageURL:");
                if([segue.destinationViewController respondsToSelector:selectorSetImageURL]){
                    
                    // nastavenie url obrazka pre jeho zobrazenie nasledne
                    NSURL *url = [NSURL URLWithString:photo.urlString];
                    [segue.destinationViewController performSelector:selectorSetImageURL withObject:url];
                    // nastavenie nazvu obrazka
                    [segue.destinationViewController setTitle:photo.title];
                    
                    [self updatePhotoShowDate:photo];
                }
            }
        }
    }
}

// update fotky ako znovu zobrazenej aby sa dostala do poslednych 10 zobrazenych fotiek
-(void)updatePhotoShowDate:(Photo *)photo
{
    [Photo savePhotoWithId:photo.photoId
                     title:photo.title
                  subtitle:photo.subtitle
                       url:photo.urlString
    inManagedObjectContext:((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext];
}

@end
