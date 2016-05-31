//
//  ASNWelcomeViewController.m
//  DartsObjC
//
//  Created by Andy Novak on 5/26/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "ASNWelcomeViewController.h"
#import "AppDelegate.h"
#import "ASNAvailableGamesView.h"

@interface ASNWelcomeViewController ()
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *availableGamesArray;
@property (nonatomic, strong) NSMutableArray *availableGameViewsArray;

@end

@implementation ASNWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = YES;
    
    self.displayNameTextField.delegate = self;
    
    self.availableGamesArray = [[NSMutableArray alloc] init];
    self.availableGameViewsArray = [[NSMutableArray alloc] init];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.appDelegate.mcManager setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    [self.appDelegate.mcManager advertiseSelf:self.visibilityToggle.isOn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
    
    // added this to automatically start looking for available games
    [self searchForAvailableGames];

}
- (IBAction)refreshTapped:(id)sender {
    [self searchForAvailableGames];
}

-(void)searchForAvailableGames {
    [self.appDelegate.mcManager setupMCServiceBrowser];
    self.appDelegate.mcManager.serviceBrowser.delegate = self;
    [self.appDelegate.mcManager.serviceBrowser startBrowsingForPeers];
}



-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info {
    NSLog(@"Found a nearby advertising peer %@ withDiscoveryInfo %@", peerID, info);
    if ([info[@"isGame"] isEqualToString:@"yes"]) {
        [self.availableGamesArray addObject:peerID];
        [self reloadAvailableGamesUI];
    }
}

-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    NSLog(@"lost peer %@",peerID.displayName);
    if ([self.availableGamesArray containsObject:peerID]) {
        [self.availableGamesArray removeObject:peerID];
        [self reloadAvailableGamesUI];
    }
}

-(void)reloadAvailableGamesUI {
    // remove the previous games
    for (ASNAvailableGamesView *gameView in self.availableGameViewsArray) {
        [gameView removeFromSuperview];
    }
    self.availableGameViewsArray = [NSMutableArray new];
    // add the new games
    NSUInteger counter = 0;
    for (MCPeerID *peerID in self.availableGamesArray) {
        ASNAvailableGamesView *newGame = [ASNAvailableGamesView new];
        newGame.peerID = peerID;
        
        
        [self.view addSubview:newGame];
        [newGame setTranslatesAutoresizingMaskIntoConstraints:NO];
        [newGame.heightAnchor constraintEqualToConstant:130].active = YES;
        [newGame.widthAnchor constraintEqualToConstant:100].active = YES;
        [newGame.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:250].active = YES;
        [newGame.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:(20+(counter*110))].active = YES;
        newGame.userInteractionEnabled = YES;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [newGame addGestureRecognizer:recognizer];
        [self.availableGameViewsArray addObject:newGame];
        counter++;
    }
}

-(void)handleTap:(UITapGestureRecognizer *) recognizer {
    // invite this peer to the game
    MCPeerID *receivedPeerID = ((ASNAvailableGamesView *) recognizer.view).peerID;
    NSLog(@"tapped : %@", receivedPeerID.displayName);

    [self.appDelegate.mcManager.serviceBrowser invitePeer:receivedPeerID toSession:self.appDelegate.mcManager.session withContext:nil timeout:30];
}

- (IBAction)toggleVisibility:(id)sender {
    [self.appDelegate.mcManager advertiseSelf:self.visibilityToggle.isOn];
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
    [self.appDelegate.mcManager advertiseSelf:self.visibilityToggle.isOn];
    
    return YES;
}

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
//            [self.connectedDevicesArray addObject:peerDisplayName];
            NSLog(@"This is where we would transition to the game");
        }
        else if (state == MCSessionStateNotConnected){
//            if ([self.connectedDevicesArray count] > 0) {
//                NSUInteger indexOfPeer = [self.connectedDevicesArray indexOfObject:peerDisplayName];
//                [self.connectedDevicesArray removeObjectAtIndex:indexOfPeer];
//            }
            NSLog(@"Connection lost with %@", peerDisplayName);
        }
//        [_tblConnectedDevices reloadData];
        
        BOOL peersExist = ([[_appDelegate.mcManager.session connectedPeers] count] == 0);
//        [_btnDisconnect setEnabled:!peersExist];
        [self.displayNameTextField setEnabled:peersExist];
    }
}

@end
