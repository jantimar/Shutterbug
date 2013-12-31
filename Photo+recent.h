//
//  Photo+recent.h
//  Shutterbug
//
//  Created by Jan Timar on 10/30/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import "Photo.h"

@interface Photo (recent)

// vrati posledne zobrazene fotky
+(NSArray *)recentlyPhotosInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
