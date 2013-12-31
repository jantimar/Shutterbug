//
//  PhotoThumbnail+load.m
//  Shutterbug
//
//  Created by Jan Timar on 12/28/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import "PhotoThumbnail+load.h"
#import "FlickrFetcher.h"

@implementation PhotoThumbnail (load)

+(PhotoThumbnail *)loadPhotoThumbnailFromPhoto:(NSDictionary *)photoDictionary inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    PhotoThumbnail *photoThumbnail = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PhotoThumbnail"];
    request.sortDescriptors = nil;
    request.predicate = [NSPredicate predicateWithFormat:@"photoId = %@",photoDictionary[FLICKR_PHOTO_ID]];
    
    NSError *error;
    NSArray *matches = [managedObjectContext executeFetchRequest:request error:&error];
    if(error) NSLog(@"Error %@",[error localizedDescription]);
    
    // zisti ci fotka nie je uz ulozena v databaze
    if(matches.count > 1){
        NSLog(@"Error, lot of photoThumbnail with same id in apps");
    } else if (matches.count == 1) {
        // zmenit cas
        photoThumbnail = [matches lastObject];
    } else {
        // ulozi fotku do databazy
        photoThumbnail = [NSEntityDescription insertNewObjectForEntityForName:@"PhotoThumbnail" inManagedObjectContext:managedObjectContext];
        photoThumbnail.thumbnail = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatSquare]];
        photoThumbnail.photoId = photoDictionary[FLICKR_PHOTO_ID];
    }
    
    return photoThumbnail;
}


@end
