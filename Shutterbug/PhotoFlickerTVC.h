//
//  PhotoFlickerTVC.h
//  Shutterbug
//
//  Created by Jan Timar on 10/7/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

// Will call setImageURL: as part of any Show Image segue

#import <UIKit/UIKit.h>

// tableviewcontroller pre zobrazeni zoznamu fotiek
@interface PhotoFlickerTVC : UITableViewController

// zoznam fotiek ktore sa maju zobrazit
@property(nonatomic,strong) NSArray *photos;    // of NSDictionary

@end
