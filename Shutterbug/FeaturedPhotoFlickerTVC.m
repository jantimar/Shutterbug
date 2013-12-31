//
//  FeaturedPhotoFlickerTVC.m
//  Shutterbug
//
//  Created by Jan Timar on 10/30/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import "FeaturedPhotoFlickerTVC.h"
#import "FlickrFetcher.h"

@interface FeaturedPhotoFlickerTVC ()

@end

@implementation FeaturedPhotoFlickerTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadLatesPhotosFromFlicker];
    
    [self.refreshControl addTarget:self action:@selector(loadLatesPhotosFromFlicker) forControlEvents:UIControlEventValueChanged];
}

-(void)loadLatesPhotosFromFlicker
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t loadPhotosQueue = dispatch_queue_create("flicker latest loader", NULL);
    dispatch_async(loadPhotosQueue, ^{
        NSArray *photos = [FlickrFetcher latestGeoreferencedPhotos];    // fotky nedaleko
        
        for(NSDictionary *photo in photos)
        {
            NSLog(@"Photo %@",photo[FLICKR_TAGS]);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = photos;
            [self.refreshControl endRefreshing];
        });
    });
}

@end
