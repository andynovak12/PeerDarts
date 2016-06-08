//
//  ASNCreateNewGameViewController.m
//  DartsObjC
//
//  Created by Andy Novak on 5/17/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "ASNCreateNewGameViewController.h"
#import "ASNTeam.h"
#import "ASNDataStore.h"
#import "AppDelegate.h"
#import "ASNAvailablePlayerView.h"
#import "ASNMainGameViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ASNCreateNewGameViewController ()
@property (weak, nonatomic) IBOutlet UIButton *addTeamButton;

@property (weak, nonatomic) IBOutlet UIButton *startGameButton;
//@property (strong, nonatomic) ASNDataStore *dataStore;

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *availablePlayerArray;
@property (nonatomic, strong) NSMutableArray *connectedPlayerArray;
@property (nonatomic, strong) NSMutableArray *availablePlayerViewsArray;
@property (nonatomic, strong) NSMutableArray *pendingInvites;
@property (nonatomic, strong) NSMutableArray *addTeamButtonConstraints;
@property (nonatomic, strong) NSMutableArray *createNewTeamViewsArray;

@property (nonatomic) float distanceToCenterFromFirstRow;
@property (nonatomic) float distanceToCenterFromSecondRow;

@end

@implementation ASNCreateNewGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    
    self.availablePlayerArray = [NSMutableArray new];
    self.connectedPlayerArray = [NSMutableArray new];
    self.availablePlayerViewsArray = [NSMutableArray new];
    self.teamsArray = [NSMutableArray new];
    self.pendingInvites = [NSMutableArray new];
    self.addTeamButtonConstraints = [NSMutableArray new];
    self.createNewTeamViewsArray = [NSMutableArray new];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.appDelegate.mcManager advertiseGame:self.visibilityToggle.isOn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    
    // added this to automatically start looking for available games
    [self searchForAvailablePlayers];
    
//    self.dataStore = [ASNDataStore sharedDataStore];

    // create a team initially
    if (self.teamsArray.count == 0) {
        [self addTeam];
        [self addPlayerWithName:self.appDelegate.mcManager.peerID.displayName toTeam:self.teamsArray[0]];
//        [self reloadViewForTeam:self.teamsArray[0]];
    }
    
    [self moveAddTeamButton];
}


-(void)moveAddTeamButton{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    self.distanceToCenterFromFirstRow = -screenHeight/5;
    self.distanceToCenterFromSecondRow = screenHeight/15;

    NSUInteger numberOfTeams = self.teamsArray.count;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.addTeamButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view removeConstraints:self.addTeamButtonConstraints];
        self.addTeamButtonConstraints = [NSMutableArray new];
        
        if (numberOfTeams == 1 || numberOfTeams == 3) {
            NSLayoutConstraint *constraintX = [self.addTeamButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:screenWidth*0.25];
            constraintX.active = YES;
            [self.addTeamButtonConstraints addObject:constraintX];
        }
        else {
            NSLayoutConstraint *constraintX = [self.addTeamButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:-screenWidth*0.25];
            constraintX.active = YES;
            [self.addTeamButtonConstraints addObject:constraintX];
        }
        
        if (numberOfTeams == 1) {
            NSLayoutConstraint *constraintY = [self.addTeamButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:self.distanceToCenterFromFirstRow];
            constraintY.active = YES;
            [self.addTeamButtonConstraints addObject:constraintY];
        }
        else {
            NSLayoutConstraint *constraintY = [self.addTeamButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:self.distanceToCenterFromSecondRow];
            constraintY.active = YES;
            [self.addTeamButtonConstraints addObject:constraintY];
        }
    });
}

-(BOOL)viewExistsForTeam:(ASNTeam *)team {
    for (ASNCreateTeamView *view in self.createNewTeamViewsArray) {
        if (view.team == team) {
            return YES;
        }
    }
    return NO;
}

-(void)reloadViewForTeam:(ASNTeam *)team {
    if (![self viewExistsForTeam:team]) {
        ASNCreateTeamView *newTeamView = [[ASNCreateTeamView alloc] init];
        // border and rounded corners
        newTeamView.layer.cornerRadius = 10.0;
        newTeamView.layer.masksToBounds = YES;
        [newTeamView.layer setBorderWidth:2.0];
        [newTeamView.layer setBorderColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:@"dash.png"]] CGColor]];///just add image name and create image with dashed or doted drawing and add here
        
        newTeamView.team = team;
        [self.createNewTeamViewsArray addObject:newTeamView];
        NSUInteger teamIndex = [self.teamsArray indexOfObject:team];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view addSubview:newTeamView];
            [newTeamView setTranslatesAutoresizingMaskIntoConstraints:NO];
            newTeamView.userInteractionEnabled = YES;
            [newTeamView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.4].active = YES;
            [newTeamView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.23].active = YES;
            
            if (teamIndex == 0) {
                [newTeamView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:self.distanceToCenterFromFirstRow].active = YES;
                [newTeamView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20].active  = YES;
            }
            else if (teamIndex == 1) {
                [newTeamView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:self.distanceToCenterFromFirstRow].active = YES;
                [newTeamView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20].active  = YES;
            }
            else if (teamIndex == 2) {
                [newTeamView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:self.distanceToCenterFromSecondRow].active = YES;
                [newTeamView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20].active  = YES;
            }
            else if (teamIndex == 3) {
                [newTeamView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:self.distanceToCenterFromSecondRow].active = YES;
                [newTeamView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-20].active  = YES;
            }
        });
        
        newTeamView.delegate = self;
    }
    else {
        for (ASNCreateTeamView *view in self.createNewTeamViewsArray) {
            if (view.team == team) {
                [view updateUI];
            }
        }
    }
    

}



- (IBAction)refreshTapped:(id)sender {
    self.availablePlayerArray = [NSMutableArray new];
    [self searchForAvailablePlayers];
    [self reloadAvailablePlayersUI];
}

-(void)searchForAvailablePlayers {
    [self.appDelegate.mcManager setupMCServiceBrowser];
    self.appDelegate.mcManager.serviceBrowser.delegate = self;
    [self.appDelegate.mcManager.serviceBrowser startBrowsingForPeers];
}

-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info {
    NSLog(@"Found a nearby advertising peer %@ withDiscoveryInfo %@", peerID, info);
    if (([info[@"isGame"] isEqualToString:@"no"]) && (![peerID isEqual:self.appDelegate.mcManager.peerID]) && (![self.connectedPlayerArray containsObject:peerID])){
        [self.availablePlayerArray addObject:peerID];
        [self reloadAvailablePlayersUI];
    }
}

-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    NSLog(@"lost peer %@",peerID.displayName);
    if (([self.availablePlayerArray containsObject:peerID]) && (![peerID isEqual:self.appDelegate.mcManager.peerID])) {
        [self.availablePlayerArray removeObject:peerID];
        [self reloadAvailablePlayersUI];
    }
}

-(void)reloadAvailablePlayersUI {
    // remove the previous players
    for (ASNAvailablePlayerView *playerView in self.availablePlayerViewsArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [playerView removeFromSuperview];
        });
    }
    self.availablePlayerViewsArray = [NSMutableArray new];
    // add the new player views
    NSUInteger counter = 0;
    for (MCPeerID *peerID in self.availablePlayerArray) {
        ASNAvailablePlayerView *newPlayerView = [ASNAvailablePlayerView new];
        newPlayerView.peerID = peerID;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view addSubview:newPlayerView];
            [newPlayerView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [newPlayerView.heightAnchor constraintEqualToConstant:100].active = YES;
            [newPlayerView.widthAnchor constraintEqualToConstant:100].active = YES;
            [newPlayerView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:525].active = YES;
            [newPlayerView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:(20+(counter*110))].active = YES;
            newPlayerView.userInteractionEnabled = YES;
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOfAvailablePlayer:)];
            [newPlayerView addGestureRecognizer:recognizer];
        });

        [self.availablePlayerViewsArray addObject:newPlayerView];
        counter++;
    }
}

-(void)handleTapOfAvailablePlayer:(UITapGestureRecognizer *) recognizer {
    ASNAvailablePlayerView *playerView = (ASNAvailablePlayerView *) recognizer.view;
    // invite this peer to the game
    MCPeerID *receivedPeerID = playerView.peerID;
    
    // start loading indicator
    playerView.spinner.frame = CGRectMake(0,0,recognizer.view.frame.size.width,recognizer.view.frame.size.height);
    [playerView.spinner startAnimating];
    
    // create alert that prompts to add player to team
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Invite %@", receivedPeerID.displayName] message:@"Join Team:" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [playerView.spinner stopAnimating];
    }];
    [alertController addAction:cancelAction];
    
    for (ASNTeam *team in self.teamsArray) {
        UIAlertAction *teamAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@",team.teamName] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self invitePeer:receivedPeerID toTeam:team];
        }];
        [alertController addAction:teamAction];
    }
    if (self.teamsArray.count < 4) {
        UIAlertAction *newTeamAction = [UIAlertAction actionWithTitle:@"New Team" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ASNTeam *placeholderTeam = [[ASNTeam alloc] initWithName:@"placeholderTeam"];
            [self invitePeer:receivedPeerID toTeam:placeholderTeam];
        }];
        [alertController addAction:newTeamAction];

    }

    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)invitePeer:(MCPeerID *)receivedPeerID toTeam:(ASNTeam *)team {
//    NSUInteger indexOfTeam = [self.teamsArray indexOfObject:team];
//    NSData *indexOfTeamAsData = [NSData dataWithBytes:&indexOfTeam length:sizeof(indexOfTeam)];
    [self.appDelegate.mcManager.serviceBrowser invitePeer:receivedPeerID toSession:self.appDelegate.mcManager.session withContext:nil timeout:30];
    // add peer to array of pending users
    NSDictionary *inviteDict = @{@"peerID" : receivedPeerID ,
                                 @"team" : team};
    [self.pendingInvites addObject:inviteDict];
}

- (IBAction)toggleVisibility:(id)sender {
    [self.appDelegate.mcManager advertiseGame:self.visibilityToggle.isOn];
}

//-(BOOL)textFieldShouldReturn:(UITextField *)textField{
//    [self.displayNameTextField resignFirstResponder];
//    
//    self.appDelegate.mcManager.peerID = nil;
//    self.appDelegate.mcManager.session = nil;
//    //    _appDelegate.mcManager.browser = nil;
//    // added this
//    self.appDelegate.mcManager.serviceBrowser = nil;
//    
//    if ([self.visibilityToggle isOn]) {
//        [self.appDelegate.mcManager.advertiser stopAdvertisingPeer];
//    }
//    self.appDelegate.mcManager.advertiser = nil;
//    
//    
//    [self.appDelegate.mcManager setupPeerAndSessionWithDisplayName:self.displayNameTextField.text];
//    //    [_appDelegate.mcManager setupMCBrowser];
//    // added this
//    [self.appDelegate.mcManager setupMCServiceBrowser];
//    [self.appDelegate.mcManager advertiseGame:self.visibilityToggle.isOn];
//    
//    return YES;
//}

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
            NSLog(@"Connected to %@", peerDisplayName);
            
            // check if the peer is in the pendingInvites array, if so, add them to the right team
            NSPredicate *peerIDPredicate = [NSPredicate predicateWithFormat:@"peerID = %@", peerID];
            NSArray *matchingObjects = [self.pendingInvites filteredArrayUsingPredicate:peerIDPredicate];
            if (matchingObjects.count > 0) {
                if ([((ASNTeam *)matchingObjects[0][@"team"]).teamName isEqualToString:@"placeholderTeam"]) {
                    [self addTeam];
                    [self addPlayerWithName:peerDisplayName toTeam:self.teamsArray.lastObject];
                }
                else {
                    [self addPlayerWithName:peerDisplayName toTeam:matchingObjects[0][@"team"]];
                }
                [self.pendingInvites removeObjectsInArray:matchingObjects];
            }
            
            [self.connectedPlayerArray addObject:peerID];
            [self.availablePlayerArray removeObject:peerID];
            [self reloadAvailablePlayersUI];
        }
        else if (state == MCSessionStateNotConnected){
            NSLog(@"Disconnected from %@", peerDisplayName);
            
            // check if the peer is in the pendingInvites array, if so, indicate failed to connect
            NSPredicate *peerIDPredicate = [NSPredicate predicateWithFormat:@"peerID = %@", peerID];
            NSArray *matchingObjects = [self.pendingInvites filteredArrayUsingPredicate:peerIDPredicate];
            if (matchingObjects.count > 0) {
                // stop spinner
                for (ASNAvailablePlayerView *playerView in self.availablePlayerViewsArray) {
                    if (playerView.peerID == peerID) {
                        [playerView.spinner stopAnimating];
                        
                        
//                        // make background flash red 
//                        CABasicAnimation *theAnimation;
//                        theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
//                        theAnimation.duration=1.0;
//                        theAnimation.repeatCount=HUGE_VALF;
//                        theAnimation.autoreverses=YES;
//                        theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
//                        theAnimation.toValue=[NSNumber numberWithFloat:0.0];
//                        [playerView.layer addAnimation:theAnimation forKey:@"animateOpacity"];
                        
                    }
                }
                [self.pendingInvites removeObjectsInArray:matchingObjects];
            }
            
            if ([self.connectedPlayerArray containsObject:peerID]) {
                NSUInteger indexOfPeer = [self.connectedPlayerArray indexOfObject:peerID];
                [self.connectedPlayerArray removeObjectAtIndex:indexOfPeer];
            }
        }
        
//        BOOL peersExist = ([[_appDelegate.mcManager.session connectedPeers] count] == 0);
        //        [_btnDisconnect setEnabled:!peersExist];
    }
}


- (IBAction)addTeamButtonTapped:(id)sender {
    [self addTeam];
}

-(void)addTeam {
    NSUInteger numberOfTeams = self.teamsArray.count;
    ASNTeam *team = [[ASNTeam alloc] initWithName:[NSString stringWithFormat:@"Team %lu", numberOfTeams+1]];
    [self.teamsArray addObject:team];
    [self reloadViewForTeam:team];
    [self moveAddTeamButton];
}

-(void)addPlayerButtonTappedInView:(ASNCreateTeamView *)view{
    UIAlertController *addPlayerAlert = [UIAlertController alertControllerWithTitle:@"Add Player" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [addPlayerAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Player Name";
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        [textField addTarget:self
                      action:@selector(alertTextFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
    }];
    
    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Submit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *nameField = addPlayerAlert.textFields.firstObject;
        
        [self addPlayerWithName:nameField.text toTeam:view.team];
        // this is too slow
//        [view updateUI];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
    
    [addPlayerAlert addAction:cancel];
    [addPlayerAlert addAction:submit];
    [addPlayerAlert.view setNeedsLayout];
    dispatch_async(dispatch_get_main_queue(), ^{
        submit.enabled = NO;
        [self presentViewController:addPlayerAlert animated:YES completion:nil];
    });
}

-(void)addPlayerWithName:(NSString *)playerName toTeam:(ASNTeam *)team {
    ASNPlayer *player = [ASNPlayer new];
    player.name = playerName;
    [team.players addObject:player];
    
    [self reloadViewForTeam:team];
}

-(void)teamNameEntered:(UITextField *)textField {
    NSLog(@"this is the text %@", textField.text);
    [textField resignFirstResponder];
}

-(void)didReceiveDataNotification:(NSNotification *)notification {
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *receivedDataUnarchived = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"this is the unarchived data i received in MainGameVC: %@ from %@", receivedDataUnarchived, peerDisplayName);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"startGameSegue"]) {
        ASNMainGameViewController *nextVC = segue.destinationViewController;
        nextVC.teamsArray = self.teamsArray;
        
        // send teams array to all players in session
        if (self.connectedPlayerArray.count > 0) {
            NSData *teamsToStartGame = [NSKeyedArchiver archivedDataWithRootObject:self.teamsArray];
            NSArray *allPeers = self.appDelegate.mcManager.session.connectedPeers;
            NSError *error;
            
            [self.appDelegate.mcManager.session sendData:teamsToStartGame
                                                 toPeers:allPeers
                                                withMode:MCSessionSendDataReliable
                                                   error:&error];
            
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            }
            
            NSLog(@"Sent data to all users. These are the unarchived teams: %@", self.teamsArray);
        }
       
    }
}

// disable submit button on addPlayer to team, if no characters inputted
-(void)alertTextFieldDidChange:(UITextField *)sender {
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController)
    {
        UITextField *nameTextField = alertController.textFields.firstObject;
        UIAlertAction *submitAction = alertController.actions.lastObject;
        submitAction.enabled = nameTextField.text.length > 0;
    }
}

@end
