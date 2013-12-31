//
//  Photo+recent.m
//  Shutterbug
//
//  Created by Jan Timar on 10/30/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import "Photo+recent.h"

@implementation Photo (recent)

+(NSArray *)recentlyPhotosInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = nil;
    request.predicate = nil;
    
    NSError *error;
    NSArray *matches = [managedObjectContext executeFetchRequest:request error:&error];
    if(error) NSLog(@"Error %@",[error localizedDescription]);
    
    return matches;
}

@end
