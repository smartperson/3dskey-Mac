//
//  AppDelegate.h
//  3dskey Mac
//
//  Created by Varun Mehta on 1/5/17.
//  Copyright (c) 2017 Varun Mehta. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MasterViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
    @property (nonatomic,strong) IBOutlet MasterViewController *masterViewController;
@end

