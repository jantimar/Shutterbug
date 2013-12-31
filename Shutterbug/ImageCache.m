//
//  ImageCache.m
//  Shutterbug
//
//  Created by Jan Timar on 12/30/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import "ImageCache.h"

@implementation ImageCache

#define CACHE_IMAGES_KEY @"sk.jantimar.shutterbug.cachkeImages"
#define FILE_NAME_KEY @"sk.jantimar.shutterbug.fileName"
#define IMAGE_URL_KEY @"sk.jantimar.shutterbug.imageURL"
#define IMAGE_SIZE_KEY @"sk.jantimar.shutterbug.imageSize"
#define SAVE_DATE_KEY @"sk.jantimar.shutterbug.imageSaveDate"

+(void)cacheImageFromURL:(NSString *)imageURLString withFileName:(NSString *)fileName
{
    NSURL *ImageURL = [NSURL URLWithString: imageURLString];
    
    NSString *uniquePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    
    // Check for file existence
    if(![[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        // The file doesn't exist, we should get a copy of it
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        // Fetch image
        NSData *data = [[NSData alloc] initWithContentsOfURL: ImageURL];
        UIImage *image = [[UIImage alloc] initWithData: data];
        
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        // Is it PNG or JPG/JPEG?
        // Running the image representation function writes the data from the image to a file
        if([imageURLString rangeOfString: @".png" options: NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
        }
        else if(
                [imageURLString rangeOfString: @".jpg" options: NSCaseInsensitiveSearch].location != NSNotFound ||
                [imageURLString rangeOfString: @".jpeg" options: NSCaseInsensitiveSearch].location != NSNotFound
                )
        {
            [UIImageJPEGRepresentation(image, 100) writeToFile: uniquePath atomically: YES];
        }
        
        NSMutableDictionary *cachedImages = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:CACHE_IMAGES_KEY] mutableCopy];
        if(!cachedImages) cachedImages = [[NSMutableDictionary alloc] init];
        
        // zistenie ci nie je velke mnozstvo ulozenych obrazkov ak hej najstarsi sa zmaze
        long size = 0;
        NSDictionary *oldestCacheImageInfo = nil;
        for(NSString *key in [cachedImages allKeys]){
            NSDictionary *cacheImageInfo = [cachedImages objectForKey:key];
            size += [[cacheImageInfo objectForKey:IMAGE_SIZE_KEY] longValue];
            if(!oldestCacheImageInfo) oldestCacheImageInfo = cacheImageInfo;
            else if ([[oldestCacheImageInfo objectForKey:SAVE_DATE_KEY] compare:[cacheImageInfo objectForKey:SAVE_DATE_KEY]])
                    oldestCacheImageInfo = cacheImageInfo;
        }
        // ak je velkost vacsia ako 5MB nacachovanych obrazkov tak najdlhsie uchovany v pamati odhodi
        
        if(size > 5242880){
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:[oldestCacheImageInfo objectForKey:FILE_NAME_KEY] error:&error];
        }
        
        // ulozenie path pre obrazok
        cachedImages[fileName] = @{ FILE_NAME_KEY : fileName,
                                    IMAGE_URL_KEY : imageURLString,
                                    IMAGE_SIZE_KEY : @(data.length),
                                    SAVE_DATE_KEY : [NSDate date] };
        [[NSUserDefaults standardUserDefaults] setObject:cachedImages forKey:CACHE_IMAGES_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+(UIImage *)getCachedImage:(NSString *)imageURLString withFileName:(NSString *)fileName
{
    NSString *uniquePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    
    UIImage *image;
    
    // Check for a cached version
    if([[NSFileManager defaultManager] fileExistsAtPath:uniquePath])
    {
        image = [UIImage imageWithContentsOfFile: uniquePath]; // this is the cached image
    }
    else
    {
        // get a new one
        [self cacheImageFromURL:imageURLString withFileName:fileName];
        image = [UIImage imageWithContentsOfFile:uniquePath];
    }
    
    return image;
}

@end
