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
#import "ASNAvailableView.h"
#import "ASNMainGameViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ASNUIElements.h"
#import "UISwitch+ASNSwitchStyle.h"
#import "UILabel+ASNLabelStyle.h"
#import "UIButton+ASNButtonStyle.h"

@interface ASNCreateNewGameViewController ()

@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *blurViewTapRecognizer;
@property (weak, nonatomic) IBOutlet UIButton *startGameButton;
//@property (strong, nonatomic) ASNDataStore *dataStore;

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *availablePlayerArray;
@property (nonatomic, strong) NSMutableArray *connectedPlayerArray;
@property (nonatomic, strong) NSMutableArray *availablePlayerViewsArray;
@property (nonatomic, strong) NSMutableArray *pendingInvites;

@property (nonatomic) float distanceToCenterFromFirstRow;
@property (nonatomic) float distanceToCenterFromSecondRow;

@property (weak, nonatomic) IBOutlet UITableView *team1TableView;
@property (weak, nonatomic) IBOutlet UITableView *team2TableView;
@property (weak, nonatomic) IBOutlet UITableView *team3TableView;
@property (weak, nonatomic) IBOutlet UITableView *team4TableView;
@property (nonatomic, strong) NSMutableArray *tableViewArray;

@property (weak, nonatomic) IBOutlet UIView *team2CoverView;
@property (weak, nonatomic) IBOutlet UIView *team3CoverView;
@property (weak, nonatomic) IBOutlet UIView *team4CoverView;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
//@property (weak, nonatomic) IBOutlet UISwitch *visibilityToggle;
//@property (weak, nonatomic) IBOutlet UILabel *visibleToOthersLabel;
@property (weak, nonatomic) IBOutlet UILabel *availablePlayersLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *availablePlayersScrollView;
@property (weak, nonatomic) IBOutlet UILabel *availablePlayerInfoLabel;

@end

@implementation ASNCreateNewGameViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.blurView.hidden = YES;
    
    // tableviews
    self.team1TableView.dataSource = self;
    self.team1TableView.delegate = self;
    self.team2TableView.dataSource = self;
    self.team2TableView.delegate = self;
    self.team3TableView.dataSource = self;
    self.team3TableView.delegate = self;
    self.team4TableView.dataSource = self;
    self.team4TableView.delegate = self;
    
    [self.availablePlayerInfoLabel labelWithMyStyleAndSizePriority:medium];
    self.availablePlayerInfoLabel.textColor = ASNLightColor;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    self.availablePlayerArray = [NSMutableArray new];
    self.connectedPlayerArray = [NSMutableArray new];
    self.availablePlayerViewsArray = [NSMutableArray new];
    self.teamsArray = [NSMutableArray new];
    self.pendingInvites = [NSMutableArray new];
    self.tableViewArray = [@[self.team1TableView, self.team2TableView, self.team3TableView, self.team4TableView] mutableCopy];
    
    [self setupUI];
 
//    [self.appDelegate.mcManager advertiseGame:self.visibilityToggle.isOn];
    
    // added this to automatically start looking for available games
    [self searchForAvailablePlayers];
    
//    self.dataStore = [ASNDataStore sharedDataStore];
    
    // this is for the position of the createNewTeamVCs and the addTeamButton
    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    self.distanceToCenterFromFirstRow = -screenHeight/5;
    self.distanceToCenterFromSecondRow = screenHeight/15;
    
    // create a team initially
    if (self.teamsArray.count == 0) {
        [self addTeam];
        [self addPlayerWithName:self.appDelegate.mcManager.peerID.displayName withPeerID:self.appDelegate.mcManager.peerID toTeam:self.teamsArray[0]];
//        [self reloadViewForTeam:self.teamsArray[0]];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [self.appDelegate.mcManager.advertiser stopAdvertisingPeer];
//    [self.appDelegate.mcManager advertiseGame:NO];
    [self.appDelegate.mcManager.serviceBrowser stopBrowsingForPeers];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MCDidChangeStateNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MCDidReceiveDataNotification" object:nil];
}

-(void)updateTeamTableViewsUI{
    NSUInteger numberOfTeams = self.teamsArray.count;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (numberOfTeams == 1) {
            self.team2CoverView.hidden = NO;
            self.team3CoverView.hidden = YES;
            self.team4CoverView.hidden = YES;
            
            self.team1TableView.hidden = NO;
            self.team2TableView.hidden = YES;
            self.team3TableView.hidden = YES;
            self.team4TableView.hidden = YES;
        }
        else if (numberOfTeams == 2) {
            self.team2CoverView.hidden = YES;
            self.team3CoverView.hidden = NO;
            self.team4CoverView.hidden = YES;
            
            self.team1TableView.hidden = NO;
            self.team2TableView.hidden = NO;
            self.team3TableView.hidden = YES;
            self.team4TableView.hidden = YES;
        }
        else if (numberOfTeams == 3) {
            self.team2CoverView.hidden = YES;
            self.team3CoverView.hidden = YES;
            self.team4CoverView.hidden = NO;
            
            self.team1TableView.hidden = NO;
            self.team2TableView.hidden = NO;
            self.team3TableView.hidden = NO;
            self.team4TableView.hidden = YES;
        }
        else if (numberOfTeams == 4) {
            self.team2CoverView.hidden = YES;
            self.team3CoverView.hidden = YES;
            self.team4CoverView.hidden = YES;
            
            self.team1TableView.hidden = NO;
            self.team2TableView.hidden = NO;
            self.team3TableView.hidden = NO;
            self.team4TableView.hidden = NO;
        }
        else {
            NSLog(@"ERROR: There should not be more than 4, or less than 1 teams");
        }
    });
}

-(void)setupUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.startGameButton buttonWithMyStyleAndSizePriority:high];

    });
//    [self.visibilityToggle switchWithMyStyle];
    [self.refreshButton buttonWithMyStyleAndSizePriority:low];
    [self.availablePlayersLabel labelWithMyStyleAndSizePriority:medium];
//    [self.visibleToOthersLabel labelWithMyStyleAndSizePriority:low];
    
    // set borders and corner radii
    for (UITableView *tableview in self.tableViewArray) {
        [self setRadiusAndBorder:tableview];
    }
    
    NSArray *coverViewsArray = @[self.team2CoverView, self.team3CoverView, self.team4CoverView];
    for (UIView *coverView in coverViewsArray) {
        [self setRadiusAndBorder:coverView];
        coverView.backgroundColor = ASNDarkColor;
        coverView.tintColor = ASNYellowColor;
    }
}
-(void)setRadiusAndBorder:(UIView *)view {
    view.layer.borderWidth = 2;
    view.layer.cornerRadius = 10;
    view.layer.borderColor = ASNLightestColor.CGColor;
}


- (IBAction)refreshTapped:(id)sender {
    self.availablePlayerArray = [NSMutableArray new];
    self.availablePlayerInfoLabel.hidden = YES;

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
    
    if (([info[@"isGame"] isEqualToString:@"no"]) && (![peerID.displayName isEqual:self.appDelegate.mcManager.peerID.displayName]) && (![self.connectedPlayerArray containsObject:peerID])){
        [self.availablePlayerArray addObject:peerID];
        [self reloadAvailablePlayersUI];
    }
}

-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    NSLog(@"lost peer %@",peerID.displayName);
    if (([self.availablePlayerArray containsObject:peerID]) && (![peerID isEqual:self.appDelegate.mcManager.peerID])) {
        [self.availablePlayerArray removeObject:peerID];
//        for (ASNAvailableView *view in self.availablePlayerViewsArray) {
//            if (view.peerID == peerID) {
//                [view removeFromSuperview];
//            }
//        }
        [self reloadAvailablePlayersUI];
    }
}

-(void)reloadAvailablePlayersUI {

    
    // remove the previous players
    for (ASNAvailableView *playerView in self.availablePlayerViewsArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [playerView removeFromSuperview];
        });
    }
    self.availablePlayerViewsArray = [NSMutableArray new];
    // add the new player views
    NSUInteger counter = 0;
    for (MCPeerID *peerID in self.availablePlayerArray) {
        ASNAvailableView *newPlayerView = [ASNAvailableView new];
        newPlayerView.peerID = peerID;
        newPlayerView.imageView.image = [UIImage imageNamed:@"defaultUserImage"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.availablePlayersScrollView addSubview:newPlayerView];
//            [self.view addSubview:newPlayerView];
            [newPlayerView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [newPlayerView.heightAnchor constraintEqualToAnchor:self.availablePlayersScrollView.heightAnchor multiplier:0.9].active = YES;
            [newPlayerView.widthAnchor constraintEqualToAnchor:self.availablePlayersScrollView.heightAnchor multiplier:0.9].active = YES;
            [newPlayerView.centerYAnchor constraintEqualToAnchor:self.availablePlayersScrollView.centerYAnchor].active = YES;
            [newPlayerView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:(20+(counter*self.availablePlayersScrollView.frame.size.width))].active = YES;
            newPlayerView.userInteractionEnabled = YES;
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOfAvailablePlayer:)];
            [newPlayerView addGestureRecognizer:recognizer];
        });

        [self.availablePlayerViewsArray addObject:newPlayerView];
        counter++;
    }
    
    // TODO: this flashes because array is 0 at first every time this method called
    // show/hide info
    if (self.availablePlayerArray.count == 0) {
        self.availablePlayerInfoLabel.hidden = NO;
    }
    else {
        self.availablePlayerInfoLabel.hidden = YES;
    }
}

-(void)handleTapOfAvailablePlayer:(UITapGestureRecognizer *) recognizer {
    ASNAvailableView *playerView = (ASNAvailableView *) recognizer.view;
    // invite this peer to the game
    MCPeerID *receivedPeerID = playerView.peerID;
    NSLog(@"Inviting player: %@ with peerID: %@", receivedPeerID.displayName, receivedPeerID);

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
        if (team.players.count < 4) {
                    UIAlertAction *teamAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@",team.teamName] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self invitePeer:receivedPeerID toTeam:team];
        }];
        [alertController addAction:teamAction];
        }

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

//- (IBAction)toggleVisibility:(id)sender {
//    [self.appDelegate.mcManager advertiseGame:self.visibilityToggle.isOn];
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
                    [self addPlayerWithName:peerDisplayName withPeerID:peerID toTeam:self.teamsArray.lastObject];
                }
                else {
                    [self addPlayerWithName:peerDisplayName withPeerID:peerID toTeam:matchingObjects[0][@"team"]];
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
                for (ASNAvailableView *playerView in self.availablePlayerViewsArray) {
                    if (playerView.peerID == peerID) {
                        [playerView.spinner stopAnimating];
                        
                        // alert user that unable to connect
                        UIAlertController *unableToConnectAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Unable To Connect With %@", peerDisplayName] message:nil preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *retry = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [self.appDelegate.mcManager.serviceBrowser invitePeer:peerID toSession:self.appDelegate.mcManager.session withContext:nil timeout:30];
                        }];
                        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                            [self.pendingInvites removeObjectsInArray:matchingObjects];
                        }];
                        
                        [unableToConnectAlert addAction:cancel];
                        [unableToConnectAlert addAction:retry];
                        [unableToConnectAlert.view setNeedsLayout];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self presentViewController:unableToConnectAlert animated:YES completion:nil];
                        });
                        
                    }
                }
            }
            
            if ([self.connectedPlayerArray containsObject:peerID]) {
                NSUInteger indexOfPeer = [self.connectedPlayerArray indexOfObject:peerID];
                NSMutableArray *newConnectedPlayerArray = self.connectedPlayerArray;
                [newConnectedPlayerArray removeObjectAtIndex:indexOfPeer];
                // user left -- take out from list of teams
                for (ASNTeam *team in self.teamsArray) {
                    for (ASNPlayer *player in team.players) {
                        if (player.playersPeerID == peerID) {
                            [team removePlayerFromTeam:player];
                            
                            // if the team now has no players, remove this team
                            if (team.players.count == 0) {
                                //delete team
                                [self.teamsArray removeObject:team];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    // reload view
                                    for (UITableView *tableView in self.tableViewArray) {
                                        [tableView reloadData];
                                    }
                                    [self updateTeamTableViewsUI];
                                    
                                });
                            }                            
                            
                            // alert user that lost player
                            UIAlertController *lostPlayerAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Lost Connection With %@", peerDisplayName] message:nil preferredStyle:UIAlertControllerStyleAlert];
  
                            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"That's A Shame" style:UIAlertActionStyleDefault handler:nil];
                            
                            [lostPlayerAlert addAction:ok];
                            
                            [lostPlayerAlert.view setNeedsLayout];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self presentViewController:lostPlayerAlert animated:YES completion:nil];
                            });

                            
                        }
                    }
                }
                self.connectedPlayerArray = newConnectedPlayerArray;
            }
            
        }
        
//        BOOL peersExist = ([[_appDelegate.mcManager.session connectedPeers] count] == 0);
        //        [_btnDisconnect setEnabled:!peersExist];
    }
}


- (IBAction)addTeamButtonTapped:(id)sender {
    [self addTeam];
    [self addPlayerToTeam:self.teamsArray.lastObject];
}

-(void)addTeam {
    NSUInteger numberOfTeams = self.teamsArray.count;
    ASNTeam *team = [[ASNTeam alloc] initWithName:[NSString stringWithFormat:@"Team %lu", numberOfTeams+1]];
    [self.teamsArray addObject:team];
//    [self reloadViewForTeam:team];
    [self updateTeamTableViewsUI];
    NSUInteger teamIndex = [self.teamsArray indexOfObject:team];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableViewArray[teamIndex] reloadData];
    });
}

-(void)addPlayerWithName:(NSString *)playerName withPeerID:(MCPeerID *)peerID toTeam:(ASNTeam *)team {
    ASNPlayer *player = [ASNPlayer new];
    player.name = playerName;
    player.playersPeerID = peerID;
    [team.players addObject:player];
    NSUInteger teamIndex = [self.teamsArray indexOfObject:team];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableViewArray[teamIndex] reloadData];
    });
}

//-(void)teamNameEntered:(UITextField *)textField {
//    NSLog(@"this is the text %@", textField.text);
//    [textField resignFirstResponder];
//}

-(void)didReceiveDataNotification:(NSNotification *)notification {
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *receivedDataUnarchived = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
}
- (IBAction)startGameTapped:(id)sender {
    for (ASNTeam *team in self.teamsArray) {
        if (![self teamHasAtLeastOnePlayer:team]) {
            // present Alert
            UIAlertController *teamsMustHaveAtLeastOnePlayerAlert = [UIAlertController alertControllerWithTitle:@"Teams Must Have At Least One Player" message:@"To delete a team, swipe left on the team's name" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Got It" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [teamsMustHaveAtLeastOnePlayerAlert addAction:ok];
            [teamsMustHaveAtLeastOnePlayerAlert.view setNeedsLayout];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:teamsMustHaveAtLeastOnePlayerAlert animated:YES completion:nil];
            });


            return;
        }
    }
   
    [self performSegueWithIdentifier:@"startGameSegue" sender:self];
}

-(BOOL)teamHasAtLeastOnePlayer:(ASNTeam *)team {
    if (team.players.count == 0) {
        return NO;
    }
    else {
        return YES;
    }
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
        }
       
    }
}

//-(BOOL)doAllTeamsHavePlayers {
//    for (ASNTeam *team in self.teamsArray) {
//        if (team.players.count == 0) {
//            return NO;
//        }
//    }
//    return YES;
//}

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

# pragma mark - Table View methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    tableView.backgroundColor = ASNDarkColor;
    if (section == 0) {
        return 1;
    }
    else {
        NSUInteger tableViewIndex = [self.tableViewArray indexOfObject:tableView];
        if (self.teamsArray.count > tableViewIndex) {
            if (((ASNTeam *)self.teamsArray[tableViewIndex]).players.count < 4) {
                return ((ASNTeam *)self.teamsArray[tableViewIndex]).players.count + 1;
            }
            else {
                return 4;
            }
        }
        else {
            return 0;
        }
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
    cell.backgroundColor = ASNDarkColor;

    
    NSUInteger tableViewIndex = [self.tableViewArray indexOfObject:tableView];
    if (self.teamsArray.count > tableViewIndex) {
        ASNTeam *team = ((ASNTeam *)self.teamsArray[tableViewIndex]);
        if (indexPath.section == 0) {
            cell.textLabel.text = team.teamName;
            cell.textLabel.font = [UIFont fontWithName:fontNameBold size:22];
            cell.textLabel.textColor = ASNLightestColor;
            cell.backgroundColor = ASNMiddleColor;
            
            // add doubleTap gesture
            UITapGestureRecognizer *teamNameTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(teamNameDoubleTapped:)];
            [teamNameTapRecognizer setNumberOfTapsRequired:2];
            [cell.contentView addGestureRecognizer:teamNameTapRecognizer];
            [cell.contentView setTag:tableViewIndex];
        }
        else {
            NSUInteger numberOfPlayersOnTeam = team.players.count;
            cell.textLabel.font = [UIFont fontWithName:fontName size:15];
            if (indexPath.row < numberOfPlayersOnTeam ) {
                cell.showsReorderControl = YES;
                cell.textLabel.text = ((ASNPlayer *) team.players[indexPath.row]).name;
                cell.textLabel.textColor = ASNLightestColor;
            }
            if (indexPath.row == numberOfPlayersOnTeam && numberOfPlayersOnTeam < 4) {
                cell.textLabel.text = @"Add Player";
                cell.textLabel.textColor = ASNYellowColor;
                [cell.contentView setUserInteractionEnabled:YES];
                // this determines what team the player is added to
                cell.contentView.tag = tableViewIndex;
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addPlayerCellTapped:)];
                
                [cell.contentView addGestureRecognizer:tapGestureRecognizer];
            }
        }
    }
    
    return cell;
}

// Used when "Add Player" Button tapped
-(void)addPlayerCellTapped:(UIGestureRecognizer *)recognizer {
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
        ASNTeam *team = self.teamsArray[recognizer.view.tag];
        [self addPlayerWithName:nameField.text withPeerID:nil toTeam:team];
        recognizer.view.userInteractionEnabled = NO;
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

// Used when new team created
-(void)addPlayerToTeam:(ASNTeam *)team {
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
        
        [self addPlayerWithName:nameField.text withPeerID:nil toTeam:team];
        
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
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 30;
//}

# pragma mark - Swipe to delete player

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger tableViewIndex = [self.tableViewArray indexOfObject:tableView];
    if (self.teamsArray.count > tableViewIndex) {
        NSUInteger numberOfPlayersOnTeam = ((ASNTeam *)self.teamsArray[tableViewIndex]).players.count;
        // Do not allow deleting first player on team 1
        if (tableViewIndex == 0 && numberOfPlayersOnTeam == 1) {
            return NO;
        }
        // allow deleting all teams except team 1
        else if (tableViewIndex != 0 && indexPath.section == 0) {
            return YES;
        }
            
        // Do not give delete option on "Add Player" cell
        else if (numberOfPlayersOnTeam == 4 || numberOfPlayersOnTeam > indexPath.row) {
            return YES;
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger tableViewIndex = [self.tableViewArray indexOfObject:tableView];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete team
        if (indexPath.section == 0) {
            
            UIAlertController *deleteTeamAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Delete %@", ((ASNTeam *)self.teamsArray[tableViewIndex]).teamName] message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //delete team
                [self.teamsArray removeObjectAtIndex:tableViewIndex];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // reload view
                    for (UITableView *tableView in self.tableViewArray) {
                        [tableView reloadData];
                    }
                    [self updateTeamTableViewsUI];

                });

            }];
            UIAlertAction *no = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            [deleteTeamAlert addAction:no];
            [deleteTeamAlert addAction:yes];
            [deleteTeamAlert.view setNeedsLayout];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:deleteTeamAlert animated:YES completion:nil];
            });
        }
        
        // Delete Player
        else {
            [((ASNTeam *)self.teamsArray[tableViewIndex]).players removeObjectAtIndex:indexPath.row];
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableView reloadData];
            });
        }
       
    }
}

// make tableview show 5 cells
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.frame.size.height/5;
}

# pragma mark - Drag and Drop player
//    // to allow reordering of cells, these must be turned on. This will disable swipe to delete
//      http://stackoverflow.com/questions/31772419/reorder-table-view-cell-without-the-delete-button-and-implement-swipe-to-delete
//    [self.team1TableView setEditing:YES animated:YES];
//    [self.team2TableView setEditing:YES animated:YES];
//    [self.team3TableView setEditing:YES animated:YES];
//    [self.team4TableView setEditing:YES animated:YES];

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger tableViewIndex = [self.tableViewArray indexOfObject:tableView];
    if (self.teamsArray.count > tableViewIndex && indexPath.section == 1) {
        NSUInteger numberOfPlayersOnTeam = ((ASNTeam *)self.teamsArray[tableViewIndex]).players.count;
        // Do not give drag option on "Add Player" cell, or if there is only 1 player on team
        if (numberOfPlayersOnTeam <= 1) {
            return NO;
        }
        else if (numberOfPlayersOnTeam == 4 || numberOfPlayersOnTeam > indexPath.row ) {
            return YES;
        }
    }

    return NO;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSUInteger tableViewIndex = [self.tableViewArray indexOfObject:tableView];
    if (self.teamsArray.count > tableViewIndex) {
        NSMutableArray *playersArray = ((ASNTeam *)self.teamsArray[tableViewIndex]).players;
        ASNPlayer *player = [playersArray objectAtIndex:fromIndexPath.row];
        [playersArray removeObjectAtIndex:fromIndexPath.row];
        [playersArray insertObject:player atIndex:toIndexPath.row];
    }
}

- (IBAction)longPressedTeam:(UIGestureRecognizer *)sender {
    self.blurView.hidden = NO;
    [self.view bringSubviewToFront:self.blurView];
    self.blurViewTapRecognizer.enabled = YES;
    [self.view bringSubviewToFront:sender.view];
    [((UITableView *)sender.view) setEditing:YES animated:YES];
}

- (IBAction)blurViewTapped:(id)sender {
    self.blurView.hidden = YES;
    [self.team1TableView setEditing:NO animated:YES];
    [self.team2TableView setEditing:NO animated:YES];
    [self.team3TableView setEditing:NO animated:YES];
    [self.team4TableView setEditing:NO animated:YES];
}

- (void)teamNameDoubleTapped:(UIGestureRecognizer *)sender {
    ASNTeam *team = self.teamsArray[sender.view.tag];

    UIAlertController *changeNameAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Change Name of %@", team.teamName] message:nil preferredStyle:UIAlertControllerStyleAlert];
    [changeNameAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Team Name";
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        [textField addTarget:self
                      action:@selector(alertTextFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
    }];
    
    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Submit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *nameField = changeNameAlert.textFields.firstObject;
        team.teamName = nameField.text;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableViewArray[sender.view.tag] reloadData];
        });
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
    
    [changeNameAlert addAction:cancel];
    [changeNameAlert addAction:submit];
    [changeNameAlert.view setNeedsLayout];
    dispatch_async(dispatch_get_main_queue(), ^{
        submit.enabled = NO;
        [self presentViewController:changeNameAlert animated:YES completion:nil];
    });
    
}
//// these two methods hide the red circle created when implementing moverowatindexpath
//- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
//    return NO;
//}
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return UITableViewCellEditingStyleNone;
//}

// this prevents users from dragging past the "Add Player" cell
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if( sourceIndexPath.section != proposedDestinationIndexPath.section )
    {
        return sourceIndexPath;
    }
    else
    {
        NSUInteger tableViewIndex = [self.tableViewArray indexOfObject:tableView];
        

        if (proposedDestinationIndexPath.row == ((ASNTeam *)self.teamsArray[tableViewIndex]).players.count) {
            return sourceIndexPath;
        } else {
            return proposedDestinationIndexPath;
        }
    }
}


@end
