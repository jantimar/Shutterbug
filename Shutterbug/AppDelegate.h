//
//  AppDelegate.h
//  Shutterbug
//
//  Created by Jan Timar on 10/7/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

@end
