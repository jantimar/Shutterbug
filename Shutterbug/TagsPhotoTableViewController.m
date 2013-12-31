//
//  TagsPhotoTableViewController.m
//  Shutterbug
//
//  Created by Jan Timar on 10/30/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import "TagsPhotoTableViewController.h"
#import "FlickrFetcher.h"

@interface TagsPhotoTableViewController ()

// zoznam vsetkych tagov zo stiahnutych fotiek
@property (nonatomic, strong) NSArray *tags; // of NSDictionary

@end

@implementation TagsPhotoTableViewController

#define TAG @"tag"
#define ARRAY @"array"

// zosortovanie tagov podla abecedy
-(void)setTags:(NSArray *)tags{
    _tags = [self sortArrayByAlphabeth:tags];
    [self.tableView reloadData];
}

-(NSArray *)sortArrayByAlphabeth:(NSArray *)array
{
    id sortByAlphabeth = ^(NSDictionary *firstObject, NSDictionary *secondObject){
        return ([[firstObject objectForKey:TAG] compare:[secondObject objectForKey:TAG]]);
    };
    
    return [array sortedArrayUsingComparator:sortByAlphabeth];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // stiahnutie vsetkych fotiek pri zobrazeni UI
    [self.refreshControl addTarget:self action:@selector(loadLatesPhotosFromFlicker) forControlEvents:UIControlEventValueChanged];
    [self loadLatesPhotosFromFlicker];
}

-(void)loadLatesPhotosFromFlicker
{
    [self.refreshControl beginRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    dispatch_queue_t fetchQ = dispatch_queue_create("Stenford refresh", NULL);
    dispatch_async(fetchQ, ^{
        NSMutableDictionary *tagsDictionary = [[NSMutableDictionary alloc] init];
        // prejde vsetkymi stiahnutymi fotkami
        for(NSDictionary *photo in [FlickrFetcher stanfordPhotos]){
            NSString *stringTags = [photo[FLICKR_TAGS] description];
            // rozdelenie na tagy
            NSArray *tags = [stringTags componentsSeparatedByString:@" "];
            //prejdenie kazdym tagom
            for (NSString *tag in tags) {
                // pole ktore obsahuje dictionary len z tagom
                NSDictionary *tagPhoto = tagsDictionary[tag];
                if(!tagPhoto) {
                    tagPhoto = [[NSDictionary alloc] initWithObjectsAndKeys:[[NSMutableArray alloc] init],tag, tag, TAG, nil];
                    [tagsDictionary setObject:tagPhoto forKey:tag];
                    
                }
                NSMutableArray *photoArray = tagPhoto[tag];
                [photoArray addObject:photo];
            }
        }
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for(NSString *string in tagsDictionary){
            NSDictionary *dic = [tagsDictionary objectForKey:string];
            [array addObject:dic];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{            
            self.tags = [[NSArray alloc] initWithArray:array];
            [self.refreshControl endRefreshing];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tags count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tag cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subtitleForRow:indexPath.row];
    
    
    return cell;
}


- (NSString *)titleForRow:(NSUInteger)row
{
    return  [self.tags[row][TAG] description];
}

-(NSString *)subtitleForRow:(NSUInteger)row
{
    return [NSString stringWithFormat:@"%d photos",[self.tags[row][self.tags[row][TAG]] count]];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // zobrazenie fotiek z daneho tagu
    if([segue.identifier isEqualToString:@"Show tag photo"]){
        if([sender isKindOfClass:[UITableViewCell class]]){
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            if(indexPath){
                if ([segue.destinationViewController respondsToSelector:@selector(setPhotos:)]) {
                    NSArray *photos = self.tags[indexPath.row][self.tags[indexPath.row][TAG]];
                    [segue.destinationViewController performSelector:@selector(setPhotos:) withObject:photos];
                    [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];
                }
            }
        }
    }
}

@end
