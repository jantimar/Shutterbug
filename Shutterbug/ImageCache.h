//
//  ImageCache.h
//  Shutterbug
//
//  Created by Jan Timar on 12/30/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject

+(UIImage *)getCachedImage:(NSString *)imageURLString withFileName:(NSString *)fileName;

@end
