//
//  ASNMainGameViewController.m
//  DartsObjC
//
//  Created by Andy Novak on 5/4/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "ASNMainGameViewController.h"
#import "ASNDataStore.h"
#import "ASNGame.h"
#import "AppDelegate.h"

@interface ASNMainGameViewController ()

@property (strong, nonatomic) ASNDataStore *dataStore;
@property (nonatomic, strong) AppDelegate *appDelegate;

@property (strong, nonatomic) NSMutableArray *teamContainersArray;

@property (strong, nonatomic) UIImageView *team120;
@property (strong, nonatomic) UIImageView *team119;
@property (strong, nonatomic) UIImageView *team118;
@property (strong, nonatomic) UIImageView *team117;
@property (strong, nonatomic) UIImageView *team116;
@property (strong, nonatomic) UIImageView *team115;
@property (strong, nonatomic) UIImageView *team1Bull;

@property (strong, nonatomic) UIImageView *team220;
@property (strong, nonatomic) UIImageView *team219;
@property (strong, nonatomic) UIImageView *team218;
@property (strong, nonatomic) UIImageView *team217;
@property (strong, nonatomic) UIImageView *team216;
@property (strong, nonatomic) UIImageView *team215;
@property (strong, nonatomic) UIImageView *team2Bull;

@property (strong, nonatomic) NSArray *team1ImageViewsArray;
@property (strong, nonatomic) NSArray *team2ImageViewsArray;

//@property (strong, nonatomic) UILabel *currentPlayerLabel;

@property (strong, nonatomic) UILabel *team1NameLabel;
@property (strong, nonatomic) UILabel *team2NameLabel;
@property (strong, nonatomic) UILabel *team3NameLabel;
@property (strong, nonatomic) UILabel *team4NameLabel;
@property (strong, nonatomic) NSArray *teamNameLabelsArray;

@property (strong, nonatomic) NSMutableArray *playerNamesLabelsArray;


@property (strong, nonatomic) ASNGame *currentGame;

@end

@implementation ASNMainGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"in view did load of Main");

    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    
    
    self.navigationController.navigationBarHidden = YES;
    
    // set chalkboard background image
    UIImageView *chalkboardImageView = [[UIImageView alloc] init];
    [chalkboardImageView setImage:[UIImage imageNamed:@"Chalkboard"]];
    [chalkboardImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:chalkboardImageView];

    [self initializeImageViews];
    self.playerNamesLabelsArray = [NSMutableArray new];
    self.dataStore = [ASNDataStore sharedDataStore];
    
    // this will be done on previous page and taken from datastore
//    Player *p1 = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:self.dataStore.managedObjectContext];
//    p1.name = @"Player 1";
//    Player *p2 = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:self.dataStore.managedObjectContext];
//    p2.name = @"Player 2";
//    Player *p3 = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:self.dataStore.managedObjectContext];
//    p3.name = @"Player 3";
//    Player *p4 = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:self.dataStore.managedObjectContext];
//    p4.name = @"Player 4234";
//    
//    ASNTeam *t1 = [[ASNTeam alloc] initWithName:@"Team 1"];
//    [t1 addPlayerToTeam:p1];
//    [t1 addPlayerToTeam:p2];
//    
//    ASNTeam *t2 = [[ASNTeam alloc] initWithName:@"Team 2"];
//    [t2 addPlayerToTeam:p3];
//    [t2 addPlayerToTeam:p4];
//    
//    self.currentGame = [[ASNGame alloc] initWithTeams:@[t1, t2]];
    
    if (self.teamsArray.count > 0) {
        self.currentGame = [[ASNGame alloc] initWithTeams:self.teamsArray];
    }
    else {
        self.currentGame = [[ASNGame alloc] initWithTeams:self.dataStore.teams];
    }
    
    // move this line to other place later
//    [self.currentGame.currentPlayer setupPlayerForRound];
    
    [self setupGameVisuals];
    
//    [self enableTouchingForTeam:self.currentGame.currentTeam];

}

-(void)viewDidLayoutSubviews {
//    [self setupGameVisuals];
    
}

-(void)newGame {
    if (self.teamsArray.count > 0) {
        self.currentGame = [[ASNGame alloc] initWithTeams:self.teamsArray];
    }
    else {
        self.currentGame = [[ASNGame alloc] initWithTeams:self.dataStore.teams];
    }

    for (ASNTeam *team in self.currentGame.teams) {
        [self updateTeamNameAndScore:team];
        [self updatePlayerNamesLabelsOfPreviousTeam:team];
    }
//    [self updateCurrentPlayerLabel];
    for (UIImageView *imageview in self.team1ImageViewsArray) {
        imageview.alpha = 0.1;
    }
    for (UIImageView *imageview in self.team2ImageViewsArray) {
        imageview.alpha = 0.1;
    }
}

# pragma mark -- Setup View Programatically

- (void) setupGameVisuals {
    [self setupContainerViewsForTeams:self.currentGame.teams];
    
    // load player names
    for (ASNTeam *team in self.currentGame.teams) {
        [self.playerNamesLabelsArray addObject:[NSMutableArray new]];
        [self loadPlayerNamesOfTeam:team];
    }
    [self setupNumbersContainerView];
    
//    
//    // setup current player label
//    self.currentPlayerLabel = [[UILabel alloc] init];
//    self.currentPlayerLabel.numberOfLines = 4;
//    [self.currentPlayerLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.view addSubview:self.currentPlayerLabel];
//        [self.currentPlayerLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:20].active = YES;
//        [self.currentPlayerLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
//        [self updateCurrentPlayerLabel];
    

        
        // setup log turn button
        UIButton *logTurnButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:logTurnButton];
        
        [logTurnButton addTarget:self action:@selector(handleLogButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        logTurnButton.backgroundColor = [UIColor blueColor];
        [logTurnButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [logTurnButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
        [logTurnButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-200].active = YES;
        [logTurnButton.widthAnchor constraintEqualToConstant:150].active = YES;
        [logTurnButton.heightAnchor constraintEqualToConstant:30].active = YES;
        [logTurnButton setTitle:@"Log Turn" forState:UIControlStateNormal];
        
        [self makeCurrentPlayerNameBig];

    });
    
}

- (void) loadPlayerNamesOfTeam:(ASNTeam *)team{
//    NSUInteger indexOfPlayer = 0;
    NSUInteger numberOfPlayersOnTeam = team.players.count;
//    if ([team.players containsObject:self.currentGame.currentPlayer]) {
//        indexOfPlayer = [team.players indexOfObject:self.currentGame.currentPlayer];
//    }
    
    
    // get index of team
    NSUInteger teamIndex = [self.currentGame.teams indexOfObject:team];
    for (NSUInteger i = 0; i < numberOfPlayersOnTeam; i++) {
        UILabel *currentLabel = [[UILabel alloc] init];
        [currentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        currentLabel.text = [NSString stringWithFormat:@"%@ : N/A", ((Player *)team.players[i]).name];
//        currentLabel.text = ((Player *)team.players[(i+indexOfPlayer)%numberOfPlayersOnTeam]).name;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [((UIView *)self.teamContainersArray[teamIndex]) addSubview:currentLabel];
            [currentLabel.centerXAnchor constraintEqualToAnchor:((UIView *)self.teamContainersArray[teamIndex]).centerXAnchor].active = YES;
            [currentLabel.centerYAnchor constraintEqualToAnchor:((UIView *)self.teamContainersArray[teamIndex]).centerYAnchor constant:20*i].active = YES;
            [self.playerNamesLabelsArray[teamIndex] addObject:currentLabel];
//            [self makeCurrentPlayerNameBig];
        });

    }
}

- (void) setupContainerViewsForTeams:(NSArray *)teamsArray {
    self.teamContainersArray = [NSMutableArray new];
    
    self.team1NameLabel = [UILabel new];
    self.team2NameLabel = [UILabel new];
    self.team3NameLabel = [UILabel new];
    self.team4NameLabel = [UILabel new];
    self.teamNameLabelsArray = @[self.team1NameLabel, self.team2NameLabel, self.team3NameLabel, self.team4NameLabel];
    
    __block NSUInteger counter = 0;
    for (ASNTeam *team in teamsArray) {
        UIView *containerView = [[UIView alloc] init];
        [self.teamContainersArray addObject:containerView];

        dispatch_async(dispatch_get_main_queue(), ^{

            [containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
            containerView.backgroundColor = [UIColor redColor];
            [self.view addSubview:containerView];
            [containerView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.2].active = YES;
            [containerView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.4].active = YES;
            [containerView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
            if (counter == 0) {
                [containerView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
            }
            else if (counter == 1) {
                [containerView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
            }
            else {
                NSLog(@"Dont know how to deal with more than 2 teams layout yet");
            }
            
            UILabel *teamNameLabel = self.teamNameLabelsArray[counter];
            teamNameLabel.numberOfLines = 2;
            [teamNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            teamNameLabel.text = [[NSString stringWithFormat:@"%@\nScore: %lu",team.teamName, team.scoreOfCurrentRound] mutableCopy];
            teamNameLabel.font = [UIFont fontWithName:@"Times" size:20];
            [containerView addSubview:teamNameLabel];
            [teamNameLabel.centerXAnchor constraintEqualToAnchor:containerView.centerXAnchor].active = YES;
            [teamNameLabel.centerYAnchor constraintEqualToAnchor:containerView.centerYAnchor constant:-50].active = YES;
            
            counter++;
        });
    }

}

- (void) setupNumbersContainerView {
    // container view of numbers, lines, buttons
    UIView *numbersContainerView = [[UIView alloc] init];
//    numbersContainerView.backgroundColor = [UIColor blueColor];
    dispatch_async(dispatch_get_main_queue(), ^{
        [numbersContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:numbersContainerView];
        [numbersContainerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
        [numbersContainerView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:self.view.frame.size.height/12].active = YES;
        CGFloat heightMultiplier = 0.7;
        CGFloat heightConstant = self.view.frame.size.height * heightMultiplier;
        [numbersContainerView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:heightMultiplier].active = YES;
        [numbersContainerView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.85].active = YES;
        
        // set up numbers
        CGFloat counterForNumbers = 0;
        for (NSString *number in @[@"20",@"19",@"18",@"17", @"16", @"15", @"Bulls"]) {
            UILabel *numberLabel = [UILabel new];
            numberLabel.text = number;
            numberLabel.font = [UIFont fontWithName:@"Copperplate" size:24];
            numberLabel.textColor = [UIColor whiteColor];
            [numberLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [numbersContainerView addSubview:numberLabel];
            [numberLabel.centerXAnchor constraintEqualToAnchor:numbersContainerView.centerXAnchor].active = YES;
            [numberLabel.centerYAnchor constraintEqualToAnchor:numbersContainerView.topAnchor constant:(heightConstant/7)*(counterForNumbers + 0.5)].active = YES;
            
            // add bottom line
            if (counterForNumbers < 6) {
                UIView *bottomLine = [UIView new];
                bottomLine.backgroundColor = [UIColor whiteColor];
                [bottomLine setTranslatesAutoresizingMaskIntoConstraints:NO];
                [numbersContainerView addSubview:bottomLine];
                [bottomLine.widthAnchor constraintEqualToAnchor:numbersContainerView.widthAnchor].active = YES;
                [bottomLine.heightAnchor constraintEqualToConstant:2].active = YES;
                [bottomLine.centerYAnchor constraintEqualToAnchor:numbersContainerView.topAnchor constant:(heightConstant/7)*(counterForNumbers+1)].active = YES;
                [bottomLine.centerXAnchor constraintEqualToAnchor:numbersContainerView.centerXAnchor].active = YES;
            }
            
            counterForNumbers++;
        }
        
        CGFloat outsideLineConstant = 120;
        CGFloat insideLineConstant = 25;
        
        // vertical lines
        for (NSUInteger i = 0; i<4; i++) {
            UIView *VLine = [UIView new];
            VLine.backgroundColor = [UIColor whiteColor];
            [VLine setTranslatesAutoresizingMaskIntoConstraints:NO];
            [numbersContainerView addSubview:VLine];
            [VLine.widthAnchor constraintEqualToConstant:2].active = YES;
            [VLine.heightAnchor constraintEqualToAnchor:numbersContainerView.heightAnchor].active = YES;
            [VLine.centerYAnchor constraintEqualToAnchor:numbersContainerView.centerYAnchor].active = YES;
            
            if (i == 0) {
                [VLine.centerXAnchor constraintEqualToAnchor:numbersContainerView.centerXAnchor constant:-outsideLineConstant].active = YES;
            }
            else if (i == 1) {
                [VLine.centerXAnchor constraintEqualToAnchor:numbersContainerView.centerXAnchor constant:-insideLineConstant].active = YES;
            }
            else if (i == 2) {
                [VLine.centerXAnchor constraintEqualToAnchor:numbersContainerView.centerXAnchor constant:insideLineConstant].active = YES;
            }
            else if (i == 3) {
                [VLine.centerXAnchor constraintEqualToAnchor:numbersContainerView.centerXAnchor constant:outsideLineConstant].active = YES;
            }
        }
        
        // make image views
        for (NSUInteger i = 0; i < self.team1ImageViewsArray.count; i++) {
            UIImageView *currentTeam1ImageView = self.team1ImageViewsArray[i];
            [currentTeam1ImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [numbersContainerView addSubview:currentTeam1ImageView];
            [currentTeam1ImageView.heightAnchor constraintEqualToConstant:heightConstant/7].active = YES;
            [currentTeam1ImageView.widthAnchor constraintEqualToConstant:outsideLineConstant-insideLineConstant].active = YES;
            [currentTeam1ImageView.centerXAnchor constraintEqualToAnchor:numbersContainerView.centerXAnchor constant:-(insideLineConstant + outsideLineConstant)/2].active = YES;
            [currentTeam1ImageView.centerYAnchor constraintEqualToAnchor:numbersContainerView.topAnchor constant:(heightConstant/7)*(i + 0.5)].active = YES;
            currentTeam1ImageView.alpha = 0.1;
            
            // add tap gesture
            UITapGestureRecognizer *team1Tap =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(handleNumberTap:)];
            [currentTeam1ImageView addGestureRecognizer:team1Tap];
            currentTeam1ImageView.tag = 20 - i;
            currentTeam1ImageView.userInteractionEnabled = YES;
            
            
            UIImageView *currentTeam2ImageView = self.team2ImageViewsArray[i];
            [currentTeam2ImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [numbersContainerView addSubview:currentTeam2ImageView];
            [currentTeam2ImageView.heightAnchor constraintEqualToConstant:heightConstant/7].active = YES;
            [currentTeam2ImageView.widthAnchor constraintEqualToConstant:outsideLineConstant-insideLineConstant].active = YES;
            [currentTeam2ImageView.centerXAnchor constraintEqualToAnchor:numbersContainerView.centerXAnchor constant:(insideLineConstant + outsideLineConstant)/2].active = YES;
            [currentTeam2ImageView.centerYAnchor constraintEqualToAnchor:numbersContainerView.topAnchor constant:(heightConstant/7)*(i + 0.5)].active = YES;
            currentTeam2ImageView.alpha = 0.1;
            
            // add tap gesture
            UITapGestureRecognizer *team2Tap =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(handleNumberTap:)];
            [currentTeam2ImageView addGestureRecognizer:team2Tap];
            currentTeam2ImageView.tag = 20 - i;
            currentTeam2ImageView.userInteractionEnabled = YES;
        }
        [self enableTouchingForTeam:self.currentGame.currentTeam];

    });
    
}

-(void) initializeImageViews {
    // initial image of 'buttons'
    UIImage *testImage = [UIImage imageNamed:@"Chalkboard"];
    
    self.team120 = [[UIImageView alloc] initWithImage:testImage];
    self.team119 = [[UIImageView alloc] initWithImage:testImage];
    self.team118 = [[UIImageView alloc] initWithImage:testImage];
    self.team117 = [[UIImageView alloc] initWithImage:testImage];
    self.team116 = [[UIImageView alloc] initWithImage:testImage];
    self.team115 = [[UIImageView alloc] initWithImage:testImage];
    self.team1Bull = [[UIImageView alloc] initWithImage:testImage];
    self.team1ImageViewsArray = @[self.team120, self.team119, self.team118, self.team117, self.team116, self.team115, self.team1Bull];

    
    self.team220 = [[UIImageView alloc] initWithImage:testImage];
    self.team219 = [[UIImageView alloc] initWithImage:testImage];
    self.team218 = [[UIImageView alloc] initWithImage:testImage];
    self.team217 = [[UIImageView alloc] initWithImage:testImage];
    self.team216 = [[UIImageView alloc] initWithImage:testImage];
    self.team215 = [[UIImageView alloc] initWithImage:testImage];
    self.team2Bull = [[UIImageView alloc] initWithImage:testImage];
    self.team2ImageViewsArray = @[self.team220, self.team219, self.team218, self.team217, self.team216, self.team215, self.team2Bull];
}

-(void)updateImageOfImageView:(UIImageView *)imageView withValue:(NSUInteger)newValue {
    dispatch_async(dispatch_get_main_queue(), ^{
        imageView.tintColor = [UIColor whiteColor];
        if (newValue == 0) {
            imageView.alpha = 0.1;
        }
        else if (newValue == 1) {
            [imageView setImage:[UIImage imageNamed:@"slash"]];
            imageView.alpha = 1;
        }
        else if (newValue == 2) {
            [imageView setImage:[UIImage imageNamed:@"x image"]];
            imageView.alpha = 1;
        }
        else if (newValue == 3) {
            [imageView setImage:[UIImage imageNamed:@"circle cross"]];
            imageView.alpha = 1;
        }
        else if (newValue == 4) {
            [imageView setImage:[UIImage imageNamed:@"slash"]];
            imageView.alpha = 1;
        }
        else {
            NSLog(@"%@ has more than 4", self.currentGame.currentTeam.teamName);
        }

    });
}

-(void)updateTeamNameAndScore:(ASNTeam *)team {
    NSMutableString *teamNameAndScore = [[NSString stringWithFormat:@"%@\nScore: %lu",team.teamName, team.scoreOfCurrentRound] mutableCopy];
    NSUInteger indexOfTeam = [self.currentGame.teams indexOfObject:team];
    dispatch_async(dispatch_get_main_queue(), ^{
        ((UILabel *)self.teamNameLabelsArray[indexOfTeam]).text = teamNameAndScore;;
    });
}

-(void)enableTouchingForTeam:(ASNTeam *)team {
    NSUInteger indexOfTeam = [self.currentGame.teams indexOfObject:team];
    if (indexOfTeam == 0) {
        for (UIImageView *imageView in self.team1ImageViewsArray) {
            imageView.userInteractionEnabled = YES;
        }
        for (UIImageView *imageView in self.team2ImageViewsArray) {
            imageView.userInteractionEnabled = NO;
        }
    }
    else if (indexOfTeam == 1) {
        for (UIImageView *imageView in self.team1ImageViewsArray) {
            imageView.userInteractionEnabled = NO;
        }
        for (UIImageView *imageView in self.team2ImageViewsArray) {
            imageView.userInteractionEnabled = YES;
        }
    }
}

//-(void)updateCurrentPlayerLabel {
//    NSMutableString *labelText = [[NSString stringWithFormat:@"Current Player: \n%@ \nCurrent Hits:\n",self.currentGame.currentPlayer.name] mutableCopy];
//    for (NSString *key in self.currentGame.currentPlayer.currentHits) {
//        NSUInteger countOfHitsForKey = [self.currentGame.currentPlayer.currentHits[key] integerValue];
//        while (countOfHitsForKey>0) {
//            labelText = [[labelText stringByAppendingString:[NSString stringWithFormat:@"%@ ",key]] mutableCopy];
//            countOfHitsForKey--;
//        }
//
//    }
//    self.currentPlayerLabel.text = labelText;
//}

// called when logTurn, rotates names of players
-(void)updatePlayerNamesLabelsOfPreviousTeam:(ASNTeam *)team{
    NSUInteger indexOfPlayer = [team.players indexOfObject:team.previousPlayer]+1;
    NSUInteger numberOfPlayersOnTeam = team.players.count;
    NSUInteger teamIndex = [self.currentGame.teams indexOfObject:team];
//    if ([team.players containsObject:self.currentGame.currentPlayer]) {
//        indexOfPlayer = [team.players indexOfObject:self.currentGame.currentPlayer];
//    }
    for (NSUInteger i = 0; i < numberOfPlayersOnTeam; i++) {
        ASNPlayer *currentPlayer = ((ASNPlayer *)team.players[(i+indexOfPlayer)%numberOfPlayersOnTeam]);
        NSDictionary *previousHits = ((ASNTurn *)[currentPlayer.turnsOfPlayer lastObject]).hits;
        NSString *playersPreviousRoundResults = @"";
        for (NSString *hit in previousHits) {
            if ([previousHits[hit] integerValue] > 0) {
                for (NSUInteger i = 0; i< [previousHits[hit] integerValue]; i++) {
                    playersPreviousRoundResults = [playersPreviousRoundResults stringByAppendingString:[NSString stringWithFormat:@"%@ ",hit]];
                }
            }
        }

        ((UILabel *)self.playerNamesLabelsArray[teamIndex][i]).text = [NSString stringWithFormat:@"%@ : %@", currentPlayer.name, playersPreviousRoundResults];
    }
    
    [self enableTouchingForTeam:self.currentGame.currentTeam];

}

-(void)makeCurrentPlayerNameBig {
    // make all labels small
    for (NSArray *teamPlayerLabelArray in self.playerNamesLabelsArray) {
        for (UILabel *playerNameLabel in teamPlayerLabelArray) {
            playerNameLabel.font = [UIFont systemFontOfSize:15];
            playerNameLabel.textColor = [UIColor blackColor];
        }
    }
    // make current player's label bigger
    NSUInteger teamIndex = [self.currentGame.teams indexOfObject:self.currentGame.currentTeam];
//    NSUInteger playerIndex = [self.currentGame.currentTeam.players indexOfObject:self.currentGame.currentPlayer];
    UILabel *playerLabel = ((UILabel *)self.playerNamesLabelsArray[teamIndex][0]);
    playerLabel.font = [UIFont systemFontOfSize:18];
    playerLabel.textColor = [UIColor whiteColor];
    playerLabel.transform = CGAffineTransformScale(playerLabel.transform, 0.35, 0.35);
    [UIView animateWithDuration:0.25 animations:^{
        playerLabel.transform = CGAffineTransformScale(playerLabel.transform, 3, 3);
    }];
}


# pragma mark -- Event Handling

//The event handling method
-(void)handleNumberTap:(UITapGestureRecognizer *)recognizer {
    NSMutableString *hit = [NSMutableString new];
    if ([recognizer.view tag] == 14) {
        hit = [@"Bull" mutableCopy];
    }
    else {
        hit = [[NSString stringWithFormat:@"%li",[recognizer.view tag]] mutableCopy];
    }
    NSLog(@"Team %@ pressed %@", self.currentGame.currentTeam.teamName, hit);
    [self recordNumberHit:hit andView:((UIImageView *)recognizer.view)];
    
    // send data to everyone in session
    NSData *dataToSend = [hit dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *allPeers = self.appDelegate.mcManager.session.connectedPeers;
    NSError *error;
    
    [self.appDelegate.mcManager.session sendData:dataToSend
                                     toPeers:allPeers
                                    withMode:MCSessionSendDataReliable
                                       error:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }

    NSLog(@"sent a hit %@ to peers %@", hit, allPeers);
}

-(void)recordNumberHit:(NSString *)hit andView:(UIImageView *)associatedView {
    [self.currentGame.currentPlayer addHitToCurrentHits:hit];
    NSUInteger newValueForKey = [self.currentGame addHit:hit toTeamCurrentRound:self.currentGame.currentTeam];
    [self updateTeamNameAndScore:self.currentGame.currentTeam];
    [self updateImageOfImageView:associatedView withValue:newValueForKey];
//    [self updateCurrentPlayerLabel];
    ASNTeam *winner = [self.currentGame returnIfThereIsAWinner];
    if (winner) {
        // present alert
        UIAlertController *gameOverAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ wins!", winner.teamName] message:@"Play Again?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self newGame];
        }];
        UIAlertAction *no = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            // TODO: take me to the welcome page
        }];
        
        [gameOverAlert addAction:no];
        [gameOverAlert addAction:yes];
        [gameOverAlert.view setNeedsLayout];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:gameOverAlert animated:YES completion:nil];
        });
        
    };

}

-(void)handleLogButtonTapped:(id)sender {
    [self logTurn];
    
    // tell everyone turn logged
    NSData *dataToSend = [@"logTurn" dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *allPeers = self.appDelegate.mcManager.session.connectedPeers;
    NSError *error;
    
    [self.appDelegate.mcManager.session sendData:dataToSend
                                         toPeers:allPeers
                                        withMode:MCSessionSendDataReliable
                                           error:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    NSLog(@"sent log Turn to peers %@", allPeers);

}

-(void)logTurn {
    [self.currentGame logTurnOfCurrentPlayer];
    [self updatePlayerNamesLabelsOfPreviousTeam:self.currentGame.previousTeam];
    [self makeCurrentPlayerNameBig];
//    [self updateCurrentPlayerLabel];
    [self enableTouchingForTeam:self.currentGame.currentTeam];
}

-(void)didReceiveDataNotification:(NSNotification *)notification {
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *receivedDataUnarchived = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"this is the unarchived data i received in MainGameVC: %@ from %@", receivedDataUnarchived, peerDisplayName);
    
    NSUInteger indexOfCurrentTeam = [self.currentGame.teams indexOfObject:self.currentGame.currentTeam];
    
    // TODO make this work for more than 2 teams. make this less code and simpler
    if ([receivedDataUnarchived isEqualToString:@"logTurn"]) {
        [self logTurn];
    }
    else if ([receivedDataUnarchived isEqualToString:@"20"]) {
        // find associated view for number
        if (indexOfCurrentTeam == 0) {
            [self recordNumberHit:receivedDataUnarchived andView:self.team120];
        }
        else if (indexOfCurrentTeam == 1) {
            [self recordNumberHit:receivedDataUnarchived andView:self.team220];
        }
    }
    else if ([receivedDataUnarchived isEqualToString:@"19"]) {
        // find associated view for number
        if (indexOfCurrentTeam == 0) {
            [self recordNumberHit:receivedDataUnarchived andView:self.team119];
        }
        else if (indexOfCurrentTeam == 1) {
            [self recordNumberHit:receivedDataUnarchived andView:self.team219];
        }
    }
    else if ([receivedDataUnarchived isEqualToString:@"18"]) {
        // find associated view for number
        if (indexOfCurrentTeam == 0) {
            [self recordNumberHit:receivedDataUnarchived andView:self.team118];
        }
        else if (indexOfCurrentTeam == 1) {
            [self recordNumberHit:receivedDataUnarchived andView:self.team218];
        }
    }
    else if ([receivedDataUnarchived isEqualToString:@"17"]) {
        // find associated view for number
        if (indexOfCurrentTeam == 0) {
            [self recordNumberHit:receivedDataUnarchived andView:self.team117];
        }
        else if (indexOfCurrentTeam == 1) {
            [self recordNumberHit:receivedDataUnarchived andView:self.team217];
        }
    }
    else if ([receivedDataUnarchived isEqualToString:@"16"]) {
        // find associated view for number
        if (indexOfCurrentTeam == 0) {
            [self recordNumberHit:receivedDataUnarchived andView:self.team116];
        }
        else if (indexOfCurrentTeam == 1) {
            [self recordNumberHit:receivedDataUnarchived andView:self.team216];
        }
    }
    else if ([receivedDataUnarchived isEqualToString:@"15"]) {
        // find associated view for number
        if (indexOfCurrentTeam == 0) {
            [self recordNumberHit:receivedDataUnarchived andView:self.team115];
        }
        else if (indexOfCurrentTeam == 1) {
            [self recordNumberHit:receivedDataUnarchived andView:self.team215];
        }
    }
    else if ([receivedDataUnarchived isEqualToString:@"Bull"]) {
        // find associated view for number
        if (indexOfCurrentTeam == 0) {
            [self recordNumberHit:receivedDataUnarchived andView:self.team1Bull];
        }
        else if (indexOfCurrentTeam == 1) {
            [self recordNumberHit:receivedDataUnarchived andView:self.team2Bull];
        }
    }
}


@end
