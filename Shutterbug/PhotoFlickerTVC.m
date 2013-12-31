//
//  PhotoFlickerTVC.m
//  Shutterbug
//
//  Created by Jan Timar on 10/7/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import "PhotoFlickerTVC.h"
#import "FlickrFetcher.h"
#import "Photo+save.h"
#import "AppDelegate.h"
#import "PhotoThumbnail+load.h"

@interface PhotoFlickerTVC () <UISplitViewControllerDelegate>

@end

@implementation PhotoFlickerTVC

// nastavenie adresy obrazka pri jeho zobrazeni
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([sender isKindOfClass:[UITableViewCell class]]){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if(indexPath){
            if([segue.identifier isEqualToString:@"Show Image"]){
                SEL selectorSetImageURL = NSSelectorFromString(@"setImageURL:");
                if([segue.destinationViewController respondsToSelector:selectorSetImageURL]){
    
                    NSURL *url = [FlickrFetcher urlForPhoto:self.photos[indexPath.row] format:FlickrPhotoFormatLarge];
                    [segue.destinationViewController performSelector:selectorSetImageURL withObject:url];
                    [segue.destinationViewController setTitle:[self titleForRow:indexPath.row]];
                    
                    //ulozenie zobrazenej fotky do databazy
                    [self savePhotoFromDictionary:self.photos[indexPath.row]];
                }
            }
        }
    }
}

// zobrazenie thumbnail image pre zobrazeny cell
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    dispatch_queue_t fetchQ = dispatch_queue_create("Load thumbnail", NULL);
    dispatch_async(fetchQ, ^{
        PhotoThumbnail *photoThumbnail = [self loadPhotoThumbnailFromDictionray:self.photos[indexPath.row]];
        UIImage *thumbnailImage = [UIImage imageWithData:photoThumbnail.thumbnail];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.imageView setImage:thumbnailImage];
            
            // inac sa nezobrazi thumbnail a aby nebolo vidno ze bol zoselektovany
            UITableViewCellSelectionStyle selectionStyle = cell.selectionStyle;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setSelected:YES];
            [cell setSelected:NO];
            cell.selectionStyle = selectionStyle;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    });
    
}

// ulozenie fotky do databazy
-(void)savePhotoFromDictionary:(NSDictionary *)photoDictionary
{
    [Photo savePhotoWithId:photoDictionary[FLICKR_PHOTO_ID]
                     title:photoDictionary[FLICKR_PHOTO_TITLE]
                  subtitle:photoDictionary[FLICKR_PHOTO_OWNER]
                       url:[[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString]
    inManagedObjectContext:((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext];
}

-(PhotoThumbnail *)loadPhotoThumbnailFromDictionray:(NSDictionary *)photodictionary
{
    return [PhotoThumbnail loadPhotoThumbnailFromPhoto:photodictionary
                          inManagedObjectContext:((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext];
}

-(void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

// aby v portrait mode bol zobrazeny master aj detail
-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subtitleForRow:indexPath.row];
    
    return cell;
}

// vrat nazov fotky
-(NSString *)titleForRow:(NSUInteger)row
{
    return [self.photos[row][FLICKR_PHOTO_TITLE] description];
}

// vrati vlastnika fotky
-(NSString *)subtitleForRow:(NSUInteger)row
{
    return [self.photos[row][FLICKR_PHOTO_OWNER] description];
}

// seter pre fotky ich zosortuje podla abecedy
-(void)setPhotos:(NSArray *)photos
{
    _photos = [self sortArrayByAlphabeth:photos];
    [self.tableView reloadData];
}

// zosortovanie pola fotiek podla nazvu fotiek
-(NSArray *)sortArrayByAlphabeth:(NSArray *)array
{
    id sortByAlphabeth = ^(NSDictionary *firstObject, NSDictionary *secondObject){
        return ([[[firstObject objectForKey:FLICKR_PHOTO_TITLE] description] compare:[[secondObject objectForKey:FLICKR_PHOTO_TITLE] description]]);
    };
    
    return [array sortedArrayUsingComparator:sortByAlphabeth];
}

@end
