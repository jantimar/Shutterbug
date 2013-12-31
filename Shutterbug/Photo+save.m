//
//  Photo+save.m
//  Shutterbug
//
//  Created by Jan Timar on 10/30/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import "Photo+save.h"
#import "PhotoThumbnail+load.h"

@implementation Photo (save)

+(Photo *)savePhotoWithId:(NSString *)photoId title:(NSString *)title subtitle:(NSString *)subtitle url:(NSString *)urlString inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    Photo *photo;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = nil;
    request.predicate = [NSPredicate predicateWithFormat:@"photoId = %@",photoId];
    
    NSError *error;
    NSArray *matches = [managedObjectContext executeFetchRequest:request error:&error];
    if(error) NSLog(@"Error %@",[error localizedDescription]);
    
    
    if(matches.count > 1){
        NSLog(@"Error, lot of photo with same id in apps");
    } else if (matches.count == 1) {
        // zmenit cas
        photo = [matches lastObject];
        photo.lastShow = [NSDate date];
    } else {
        // ulozi informacie o zobrazenej fotke do databazi
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:managedObjectContext];
        photo.urlString = urlString;
        photo.title = title;
        photo.subtitle = subtitle;
        photo.lastShow = [NSDate date];
        photo.photoId = photoId;
        
        
        //ziskanie thumbnail
        NSFetchRequest *requestThumbnail = [NSFetchRequest fetchRequestWithEntityName:@"PhotoThumbnail"];
        requestThumbnail.sortDescriptors = nil;
        requestThumbnail.predicate = [NSPredicate predicateWithFormat:@"photoId = %@",photoId];
        
        NSError *errorThumbnail;
        NSArray *matchesThumbnail = [managedObjectContext executeFetchRequest:requestThumbnail error:&errorThumbnail];
        if(error) NSLog(@"Error %@",[errorThumbnail localizedDescription]);
        // pre istotu
        if([matchesThumbnail count] == 1)
            photo.thumbnail = [matchesThumbnail lastObject];
        
        
        // zistenie ci pocet fotiek neprekrocil 5 ak hej zmazat posledne
        NSFetchRequest *requestAllPhoto = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        requestAllPhoto.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastShow" ascending:NO selector:nil]];
        requestAllPhoto.predicate = nil;
        
        NSError *errorAll;
        NSArray *matchesAllPhotos = [managedObjectContext executeFetchRequest:requestAllPhoto error:&errorAll];
        if(errorAll) NSLog(@"Error %@",[error localizedDescription]);
        // obmedzenie na maximum 10 recently fotiek potom poslednu zmaze
        if(matchesAllPhotos.count > 10){
            // najstarsiu fotku zmaze
            Photo *lastPhoto = matchesAllPhotos.lastObject;
            [managedObjectContext deleteObject:lastPhoto];
        }
    }
    
    return photo;
}

@end
