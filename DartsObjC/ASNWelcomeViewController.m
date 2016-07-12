//
//  ASNWelcomeViewController.m
//  DartsObjC
//
//  Created by Andy Novak on 5/26/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "ASNWelcomeViewController.h"
#import "AppDelegate.h"
#import "ASNAvailableView.h"
#import "ASNMainGameViewController.h"
#import "ASNUIElements.h"
#import "UIButton+ASNButtonStyle.h"
#import "UILabel+ASNLabelStyle.h"
#import "UISwitch+ASNSwitchStyle.h"

@interface ASNWelcomeViewController ()
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *availableGamesArray;
@property (nonatomic, strong) NSMutableArray *availableGameViewsArray;
@property (nonatomic, strong) NSMutableArray *receivedDataUnarchived;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;

@property (weak, nonatomic) IBOutlet UIView *connectingView;
@property (weak, nonatomic) IBOutlet UILabel *connectingTopLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectingLowerLabel;
@property (weak, nonatomic) IBOutlet UIButton *connectingCancelButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *connectingSpinner;
@property (weak, nonatomic) IBOutlet UIButton *connectingRetryButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshAvailableGamesButton;
@property (weak, nonatomic) IBOutlet UILabel *visibleToOthersLabel;
@property (weak, nonatomic) IBOutlet UISwitch *visibilitySwitch;
@property (weak, nonatomic) IBOutlet UITextField *displayNameTextField;

@property (weak, nonatomic) IBOutlet UILabel *availableGamesLabel;
@property (weak, nonatomic) IBOutlet UIButton *createGameButton;
@property (nonatomic) BOOL isAttemptingToConnect;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;

@property (strong, nonatomic) MCPeerID *inviterPeerID;
@end

@implementation ASNWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.connectingView.layer.cornerRadius = 20;
    self.connectingView.backgroundColor = ASNDarkColor;
    [self.connectingTopLabel labelWithMyStyleAndSizePriority:high];
    [self.connectingLowerLabel labelWithMyStyleAndSizePriority:medium];
    [self.connectingRetryButton buttonWithMyStyleAndSizePriority:low];
    [self.connectingCancelButton buttonWithMyStyleAndSizePriority:low];
    
    
    self.receivedDataUnarchived = [NSMutableArray new];
    
    self.displayNameTextField.delegate = self;
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [self.appDelegate.mcManager setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
//    [self.appDelegate.mcManager advertiseSelf:self.visibilityToggle.isOn];
//    self.appDelegate.mcManager.advertiser.delegate = self;
    
    
    

    
    // sets text of back button in NavBar
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];

    
//    // added this to automatically start looking for available games
//    [self searchForAvailableGames];

}


-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self setupUIElements];
}

-(void)setupUIElements {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Setup buttons
        [self.createGameButton buttonWithMyStyleAndSizePriority:high];
        [self.refreshAvailableGamesButton buttonWithMyStyleAndSizePriority:low];
        
        // Setup Labels
        [self.visibleToOthersLabel labelWithMyStyleAndSizePriority:low];
        [self.orLabel labelWithMyStyleAndSizePriority:medium];
        self.orLabel.textColor = ASNLightColor;
        [self.displayNameLabel labelWithMyStyleAndSizePriority:low];
        [self.availableGamesLabel labelWithMyStyleAndSizePriority:medium];
        
        // Setup Switch
        [self.visibilitySwitch switchWithMyStyle];
        
        // Setup displayNameTextField
        self.displayNameTextField.backgroundColor = ASNLightestColor;
        self.displayNameTextField.tintColor = ASNMiddleColor;
        self.displayNameTextField.font = [UIFont fontWithName:fontName size:15];
        self.displayNameTextField.textColor = ASNDarkColor;
        // set placeholder text and color
        self.displayNameTextField.textAlignment = NSTextAlignmentRight;
        
        

    });

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    self.availableGamesArray = [[NSMutableArray alloc] init];
    self.availableGameViewsArray = [[NSMutableArray alloc] init];
    
    self.inviterPeerID = nil;

//    // Convert "Andy's iPhone" to "Andy"
//    NSMutableString *playerName = [[UIDevice currentDevice].name mutableCopy];
//    if ([playerName containsString:@"'"]) {
//        NSRange lastChar = [playerName rangeOfString:@"'" options:NSBackwardsSearch];
//        playerName = [[playerName substringToIndex:lastChar.location] mutableCopy];
//    }
    if (!self.appDelegate.mcManager.peerID) {
        NSLog(@"SETTING UP PEER AND SESSION");
        [self.appDelegate.mcManager setupPeerAndSessionWithDisplayName:[self.appDelegate.mcManager deviceNameWithoutApostrophe]];
    }

    
    [self.appDelegate.mcManager advertiseSelf:self.visibilitySwitch.isOn];
    
    // added this to automatically start looking for available games
    [self searchForAvailableGames];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationController.navigationBarHidden = NO;
        self.blurView.hidden = YES;
        self.connectingView.hidden = YES;
        self.connectingRetryButton.hidden = YES;

        self.displayNameTextField.text = self.appDelegate.mcManager.peerID.displayName;

    });


    self.isAttemptingToConnect = NO;
    [self reloadAvailableGamesUI];

    
//    NSLog(@"This is my name: %@ and peerID: %@ and my sessionID: %@", self.appDelegate.mcManager.peerID.displayName, self.appDelegate.mcManager.peerID, self.appDelegate.mcManager.session.myPeerID);
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveInvitationNotification:)
                                                 name:@"MCDidReceiveInvitationNotification"
                                               object:nil];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MCDidReceiveDataNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MCDidReceiveInvitationNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MCDidChangeStateNotification" object:nil];
    
//    [self.appDelegate.mcManager.advertiser stopAdvertisingPeer];
    [self.appDelegate.mcManager advertiseSelf:NO];
    [self.appDelegate.mcManager.serviceBrowser stopBrowsingForPeers];
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
    NSLog(@"In WelcomeVC: Found a nearby advertising peer %@ withDiscoveryInfo %@", peerID, info);
    
    if (([info[@"isGame"] isEqualToString:@"yes"]) && (![peerID isEqual:self.appDelegate.mcManager.peerID]) && (![self.availableGamesArray containsObject:peerID])) {
        [self.availableGamesArray addObject:peerID];
        [self reloadAvailableGamesUI];
    }
}

-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    if (([self.availableGamesArray containsObject:peerID]) && (![peerID isEqual:self.appDelegate.mcManager.peerID])) {
        NSLog(@"lost peer %@",peerID.displayName);
        [self.availableGamesArray removeObject:peerID];
        [self reloadAvailableGamesUI];
    }
}

-(void)reloadAvailableGamesUI {

    // remove the previous games
    for (ASNAvailableView *gameView in self.availableGameViewsArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [gameView removeFromSuperview];
        });
    }
    self.availableGameViewsArray = [NSMutableArray new];
    // add the new games
    __block NSUInteger counter = 0;
    for (MCPeerID *peerID in self.availableGamesArray) {
        ASNAvailableView *newGame = [ASNAvailableView new];
        newGame.peerID = peerID;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // available games layout
            // TODO: allow for second row
            newGame.imageView.image = [UIImage imageNamed:@"dartboard"];
            [self.view insertSubview:newGame belowSubview:self.blurView];
            [newGame setTranslatesAutoresizingMaskIntoConstraints:NO];
            [newGame.topAnchor constraintEqualToAnchor:self.availableGamesLabel.bottomAnchor constant:5].active = YES;
            [newGame.heightAnchor constraintEqualToConstant:130].active = YES;
            [newGame.widthAnchor constraintEqualToConstant:100].active = YES;
            [newGame.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:(20+(counter*110))].active = YES;
            newGame.userInteractionEnabled = YES;
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            [newGame addGestureRecognizer:recognizer];
            [self.availableGameViewsArray addObject:newGame];
            counter++;
        });
        

    }

}

-(void)handleTap:(UITapGestureRecognizer *) recognizer {
    // invite this peer to the game
    MCPeerID *receivedPeerID = ((ASNAvailableView *) recognizer.view).peerID;
    NSLog(@"tapped : %@", receivedPeerID.displayName);

    [self.appDelegate.mcManager.serviceBrowser invitePeer:receivedPeerID toSession:self.appDelegate.mcManager.session withContext:nil timeout:30];
}

- (IBAction)toggleVisibility:(id)sender {
    [self.appDelegate.mcManager advertiseSelf:self.visibilitySwitch.isOn];
    
    // hide displayNameTextField if not visible
    [UIView transitionWithView:self.displayNameTextField
                      duration:0.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.displayNameTextField.hidden = !self.visibilitySwitch.isOn;
                    }
                    completion:NULL];
    [UIView transitionWithView:self.displayNameLabel
                      duration:0.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.displayNameLabel.hidden = !self.visibilitySwitch.isOn;
                    }
                    completion:NULL];

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.displayNameTextField resignFirstResponder];
    
    self.appDelegate.mcManager.peerID = nil;
    self.appDelegate.mcManager.session = nil;
    //    _appDelegate.mcManager.browser = nil;
    // added this
    self.appDelegate.mcManager.serviceBrowser = nil;
    
    if ([self.visibilitySwitch isOn]) {
        [self.appDelegate.mcManager.advertiser stopAdvertisingPeer];
    }
    self.appDelegate.mcManager.advertiser = nil;
    
    
    [self.appDelegate.mcManager setupPeerAndSessionWithDisplayName:self.displayNameTextField.text];
    //    [_appDelegate.mcManager setupMCBrowser];
    // added this
    [self.appDelegate.mcManager setupMCServiceBrowser];
    [self.appDelegate.mcManager advertiseSelf:self.visibilitySwitch.isOn];
    
    return YES;
}

- (IBAction)connectingCancelButtonTapped:(id)sender {
    if (self.isAttemptingToConnect) {
        [self.appDelegate.mcManager.session cancelConnectPeer:self.inviterPeerID];
    }
    else {
        if (self.appDelegate.mcManager.session.connectedPeers.count > 0) {
            // user is connected
            [self.appDelegate.mcManager.session disconnect];
        }
        [self.appDelegate.mcManager.advertiser startAdvertisingPeer];
        
    }
    self.blurView.hidden = YES;
    self.connectingView.hidden = YES;
}
- (IBAction)connectingRetryButtonTapped:(id)sender {
    // TODO: Fix this
    // this might cause problems with more than 2 people, cus the session is not the session of the peer creating hte game
       [self.appDelegate.mcManager.serviceBrowser invitePeer:self.inviterPeerID toSession:self.appDelegate.mcManager.session withContext:nil timeout:30];
    
    self.connectingRetryButton.hidden = YES;
}

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
//            [self.connectedDevicesArray addObject:peerDisplayName];
            if (self.isAttemptingToConnect) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.connectingTopLabel.text = @"Connected!";
                    self.connectingLowerLabel.text = [NSString stringWithFormat: @"Waiting for %@ to start the game", peerDisplayName];
                    self.connectingSpinner.hidden = YES;
                });
                self.isAttemptingToConnect = NO;
            }
            NSLog(@"Connected to %@", peerDisplayName);
        }
        else if (state == MCSessionStateNotConnected){
//            if ([self.connectedDevicesArray count] > 0) {
//                NSUInteger indexOfPeer = [self.connectedDevicesArray indexOfObject:peerDisplayName];
//                [self.connectedDevicesArray removeObjectAtIndex:indexOfPeer];
//            }
            if (self.isAttemptingToConnect) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.connectingTopLabel.text = @"Connection Failed";
                    self.connectingLowerLabel.text = [NSString stringWithFormat: @"Could not connect to %@ ", peerDisplayName];
                    self.connectingRetryButton.hidden = NO;
                    self.connectingSpinner.hidden = YES;
                });
                self.isAttemptingToConnect = NO;
                [self.appDelegate.mcManager.advertiser stopAdvertisingPeer];
            }
            NSLog(@"Connection lost with %@", peerDisplayName);
        }
//        [_tblConnectedDevices reloadData];
        
        BOOL peersExist = ([[_appDelegate.mcManager.session connectedPeers] count] == 0);
//        [_btnDisconnect setEnabled:!peersExist];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.displayNameTextField setEnabled:peersExist];
        });
    }
}

-(void)didReceiveDataNotification:(NSNotification *)notification {
//    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    self.receivedDataUnarchived = [NSKeyedUnarchiver unarchiveObjectWithData:receivedData];
    NSLog(@"this is the unarchived data i received in WelcomeVC: %@", self.receivedDataUnarchived);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"goToMainGameSegue" sender:self];
        NSLog(@"executing segue in dispatch");
    });
}


-(void)didReceiveInvitationNotification:(NSNotification *)notification {
    NSLog(@"I recieved an invitation: %@", self.appDelegate.mcManager.peerID.displayName);
    self.inviterPeerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = self.inviterPeerID.displayName;
    NSUInteger teamIndex = [[[notification userInfo] objectForKey:@"teamIndex"] intValue];
    // present an alert to ask to join
    UIAlertController *invitationAlert = [UIAlertController alertControllerWithTitle:@"You're Invited!" message:[NSString stringWithFormat:@"Join %@'s Game?", peerDisplayName] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.isAttemptingToConnect = YES;
        NSDictionary *dict = @{@"peerID": self.inviterPeerID,
                               @"teamIndex" : @(teamIndex)
                               };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didAcceptInvitationNotification"
                                                            object:nil
                                                          userInfo:dict];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.blurView.hidden = NO;
            self.connectingView.hidden = NO;
            self.connectingLowerLabel.text = [NSString stringWithFormat:@"Attempting to connect to %@", peerDisplayName];
        });
        
        
    }];
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didRejectInvitationNotification"
                                                            object:nil
                                                          userInfo:nil];
    }];
    
    [invitationAlert addAction:no];
    [invitationAlert addAction:yes];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:invitationAlert animated:YES completion:nil];
    });
}




//-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler{
//    NSUInteger receivedDataUnarchived;
//    [context getBytes:&receivedDataUnarchived length:sizeof(receivedDataUnarchived)];
////    NSDictionary *dict = @{@"peerID": peerID,
////                           @"teamIndex" : @(receivedDataUnarchived)
////                           };
//     // present an alert to ask to join
//        UIAlertController *invitationAlert = [UIAlertController alertControllerWithTitle:@"You're Invited!" message:[NSString stringWithFormat:@"Join %@'s Game?", peerID.displayName] preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            // create session
//            
//            MCSession *session = [[MCSession alloc] initWithPeer:peerID];
//            NSLog(@"yes, yes, a thousand times yes");
//            
//            
//            invitationHandler(YES, session);
//        }];
//        UIAlertAction *no = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDestructive handler:nil];
//    
//        [invitationAlert addAction:no];
//        [invitationAlert addAction:yes];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self presentViewController:invitationAlert animated:YES completion:nil];
//        });
//    
//
//}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"goToMainGameSegue"]) {
        ASNMainGameViewController *mainGameVC = segue.destinationViewController;
        mainGameVC.teamsArray = self.receivedDataUnarchived;
        NSLog(@"segueing from welcome VC, this is the array: %@", self.receivedDataUnarchived);
    }
}

@end
