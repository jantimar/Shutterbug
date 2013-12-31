//
//  Photo.h
//  Shutterbug
//
//  Created by Jan Timar on 12/28/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PhotoThumbnail;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSDate * lastShow;
@property (nonatomic, retain) NSString * photoId;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * urlString;
@property (nonatomic, retain) PhotoThumbnail *thumbnail;

@end
