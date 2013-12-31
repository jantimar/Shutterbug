//
//  PhotoThumbnail.h
//  Shutterbug
//
//  Created by Jan Timar on 12/29/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface PhotoThumbnail : NSManagedObject

@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * photoId;
@property (nonatomic, retain) Photo *photo;

@end
