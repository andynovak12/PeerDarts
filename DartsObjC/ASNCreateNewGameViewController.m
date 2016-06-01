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

@interface ASNCreateNewGameViewController ()

@property (weak, nonatomic) IBOutlet UIButton *startGameButton;
@property (strong, nonatomic) ASNDataStore *dataStore;

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *availablePlayerArray;
@property (nonatomic, strong) NSMutableArray *connectedPlayerArray;
@property (nonatomic, strong) NSMutableArray *availablePlayerViewsArray;
@property (nonatomic, strong) NSMutableArray *connectedPlayerViewsArray;

@end

@implementation ASNCreateNewGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    
    self.displayNameTextField.delegate = self;
    
    self.availablePlayerArray = [[NSMutableArray alloc] init];
    self.connectedPlayerArray = [[NSMutableArray alloc] init];
    self.availablePlayerViewsArray = [NSMutableArray new];
    self.connectedPlayerViewsArray = [NSMutableArray new];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.appDelegate.mcManager setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    [self.appDelegate.mcManager advertiseGame:self.visibilityToggle.isOn];
//    [self.appDelegate.mcManager advertiseSelf:self.visibilityToggle.isOn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
    
    // added this to automatically start looking for available games
    [self searchForAvailablePlayers];

    
    
//    self.teamsArray = [NSMutableArray new];
    
    self.dataStore = [ASNDataStore sharedDataStore];

    for (ASNTeam *team in self.dataStore.teams) {
        ASNCreateTeamView *newTeamView = [[ASNCreateTeamView alloc] init];
        newTeamView.team = team;
        
        [self.view addSubview:newTeamView];
        NSUInteger teamIndexInDataStore = [self.dataStore.teams indexOfObject:team];
        
        [newTeamView setTranslatesAutoresizingMaskIntoConstraints:NO];
        newTeamView.userInteractionEnabled = YES;
        [newTeamView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:200].active = YES;
        [newTeamView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.3].active = YES;
        [newTeamView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:20+(200*teamIndexInDataStore)].active  = YES;
        [newTeamView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.3].active = YES;
        newTeamView.delegate = self;
        
    }
    if ((self.dataStore.teams.count > 0) &&  ((ASNTeam *)self.dataStore.teams[0]).players.count > 0){
        self.startGameButton.enabled = YES;
    }
    else {
        self.startGameButton.enabled = NO;
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
    // tried to not show peer if its self, but discovered peerid is different from users peerid
    if (([info[@"isGame"] isEqualToString:@"no"]) && (![peerID isEqual:self.appDelegate.mcManager.peerID])){
        NSLog(@"Found a nearby advertising peer %@ withDiscoveryInfo %@", peerID, info);
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
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            [newPlayerView addGestureRecognizer:recognizer];
        });

        [self.availablePlayerViewsArray addObject:newPlayerView];
        counter++;
    }
}

-(void)reloadConnectedPlayersUI {
    // remove the previous games
    for (ASNAvailablePlayerView *playerView in self.connectedPlayerViewsArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [playerView removeFromSuperview];
        });
    }
    self.connectedPlayerViewsArray = [NSMutableArray new];
    // add the new player views
    NSUInteger counter = 0;
    for (MCPeerID *peerID in self.connectedPlayerArray) {
        ASNAvailablePlayerView *newPlayerView = [ASNAvailablePlayerView new];
        newPlayerView.peerID = peerID;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view addSubview:newPlayerView];
            [newPlayerView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [newPlayerView.heightAnchor constraintEqualToConstant:100].active = YES;
            [newPlayerView.widthAnchor constraintEqualToConstant:100].active = YES;
            [newPlayerView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:400].active = YES;
            [newPlayerView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:(20+(counter*110))].active = YES;
            newPlayerView.userInteractionEnabled = YES;
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            [newPlayerView addGestureRecognizer:recognizer];
        });
   
        [self.connectedPlayerViewsArray addObject:newPlayerView];
        counter++;
    }
}

-(void)handleTap:(UITapGestureRecognizer *) recognizer {
    // invite this peer to the game
    MCPeerID *receivedPeerID = ((ASNAvailablePlayerView *) recognizer.view).peerID;
    NSLog(@"tapped : %@", receivedPeerID.displayName);
    
    [self.appDelegate.mcManager.serviceBrowser invitePeer:receivedPeerID toSession:self.appDelegate.mcManager.session withContext:nil timeout:30];
}

- (IBAction)toggleVisibility:(id)sender {
    [self.appDelegate.mcManager advertiseGame:self.visibilityToggle.isOn];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.displayNameTextField resignFirstResponder];
    
    self.appDelegate.mcManager.peerID = nil;
    self.appDelegate.mcManager.session = nil;
    //    _appDelegate.mcManager.browser = nil;
    // added this
    self.appDelegate.mcManager.serviceBrowser = nil;
    
    if ([self.visibilityToggle isOn]) {
        [self.appDelegate.mcManager.advertiser stop];
    }
    self.appDelegate.mcManager.advertiser = nil;
    
    
    [self.appDelegate.mcManager setupPeerAndSessionWithDisplayName:self.displayNameTextField.text];
    //    [_appDelegate.mcManager setupMCBrowser];
    // added this
    [self.appDelegate.mcManager setupMCServiceBrowser];
    [self.appDelegate.mcManager advertiseGame:self.visibilityToggle.isOn];
    
    return YES;
}

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
            NSLog(@"Connected to %@", peerDisplayName);
            [self.connectedPlayerArray addObject:peerID];
            [self.availablePlayerArray removeObject:peerDisplayName];
            [self reloadConnectedPlayersUI];
            [self reloadAvailablePlayersUI];
        }
        else if (state == MCSessionStateNotConnected){
            NSLog(@"Disconnected from %@", peerDisplayName);
            
            if ([self.connectedPlayerArray containsObject:peerID]) {
                NSUInteger indexOfPeer = [self.connectedPlayerArray indexOfObject:peerID];
                [self.connectedPlayerArray removeObjectAtIndex:indexOfPeer];
                [self reloadConnectedPlayersUI];
            }
        }
        //        [_tblConnectedDevices reloadData];
        
        BOOL peersExist = ([[_appDelegate.mcManager.session connectedPeers] count] == 0);
        //        [_btnDisconnect setEnabled:!peersExist];
        [self.displayNameTextField setEnabled:peersExist];
    }
}






- (IBAction)addTeamButtonTapped:(id)sender {
    NSUInteger numberOfTeams = self.dataStore.teams.count;
    ASNTeam *t1 = [[ASNTeam alloc] initWithName:[NSString stringWithFormat:@"Team %lu", numberOfTeams+1]];
    [self.dataStore.teams addObject:t1];
    // this is too slow
    [self viewDidLoad];
    
}


-(void)addPlayerButtonTappedInView:(UIView *)view{
    UIAlertController *addPlayerAlert = [UIAlertController alertControllerWithTitle:@"Add Player" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [addPlayerAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Player Name";
    }];
    
    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Submit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *nameField = addPlayerAlert.textFields.firstObject;
        ASNPlayer *p1 = [ASNPlayer new];
        p1.name = nameField.text;
        [((ASNCreateTeamView *) view).team.players addObject:p1];
        // this is too slow
        [((ASNCreateTeamView *) view) updateUI];
//        [self viewDidLoad];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
    
    [addPlayerAlert addAction:cancel];
    [addPlayerAlert addAction:submit];
    [addPlayerAlert.view setNeedsLayout];
    [self presentViewController:addPlayerAlert animated:YES completion:nil];
}

//-(void)teamNameEntered:(UITextField *)textField {
////    NSLog(@"t %@", textField.text);
//    ((ASNTeam *)[self.teamsArray lastObject]).teamName = textField.text;
//    ((ASNCreateTeamView *)[self.teamViewsArray lastObject]).p1AddButton.enabled = YES;
//    
//    
//    // dismiss keyboard
//}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"startGameSegue"]) {
//        ASNMainGameViewController *nextVC = segue.destinationViewController;
        
        // send teams array to all players in session
        NSData *teamsToStartGame = [NSKeyedArchiver archivedDataWithRootObject:self.dataStore.teams];
        NSArray *allPeers = self.appDelegate.mcManager.session.connectedPeers;
        NSError *error;
        
        [self.appDelegate.mcManager.session sendData:teamsToStartGame
                                         toPeers:allPeers
                                        withMode:MCSessionSendDataReliable
                                           error:&error];
        
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        
        NSLog(@"Sent data to all users. These are the unarchived teams: %@", self.dataStore.teams);
    }
}

@end
