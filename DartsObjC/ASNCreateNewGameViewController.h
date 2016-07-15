//
//  ASNCreateNewGameViewController.h
//  DartsObjC
//
//  Created by Andy Novak on 5/17/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASNCreateTeamView.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ASNCreateNewGameViewController : UIViewController <MCNearbyServiceBrowserDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *teamsArray;
@end
