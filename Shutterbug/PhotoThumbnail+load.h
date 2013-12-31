//
//  PhotoThumbnail+load.h
//  Shutterbug
//
//  Created by Jan Timar on 12/28/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import "PhotoThumbnail.h"

@interface PhotoThumbnail (load)

// natiahnutie thumbnail fotky a ulozenie jej do databazy
+(PhotoThumbnail *)loadPhotoThumbnailFromPhoto:(NSDictionary *)photoDictionary inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;


@end
