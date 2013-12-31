//
//  LatestPhotoFlickerTVC.m
//  Shutterbug
//
//  Created by Jan Timar on 10/7/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import "LatestPhotoFlickerTVC.h"
#import "FlickrFetcher.h"

@interface LatestPhotoFlickerTVC ()

@end

@implementation LatestPhotoFlickerTVC

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
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = photos;
            [self.refreshControl endRefreshing];
        });
    });
}

@end
