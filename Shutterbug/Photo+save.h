//
//  Photo+save.h
//  Shutterbug
//
//  Created by Jan Timar on 10/30/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import "Photo.h"

@interface Photo (save)

// ulozenie informacii o zobrazenej fotke
+(Photo *)savePhotoWithId:(NSString *)photoId title:(NSString *)title subtitle:(NSString *)subtitle url:(NSString *)urlString inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
