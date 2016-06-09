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
#import "ASNHitsContainerViews.h"

@interface ASNMainGameViewController ()

//@property (strong, nonatomic) ASNDataStore *dataStore;
@property (nonatomic, strong) AppDelegate *appDelegate;

@property (strong, nonatomic) NSMutableArray *teamContainersArray;

@property (strong, nonatomic) UILabel *team1NameLabel;
@property (strong, nonatomic) UILabel *team2NameLabel;
@property (strong, nonatomic) UILabel *team3NameLabel;
@property (strong, nonatomic) UILabel *team4NameLabel;
@property (strong, nonatomic) NSArray *teamNameLabelsArray;

@property (strong, nonatomic) NSMutableArray *playerNamesLabelsArray;

@property (strong,nonatomic) NSString *fontName;

@property (strong, nonatomic) ASNGame *currentGame;

@property (nonatomic) BOOL isAlertControllerPresented;

@end

@implementation ASNMainGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isAlertControllerPresented = NO;

    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    self.fontName = @"Copperplate";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    
    
    self.navigationController.navigationBarHidden = YES;
    
    // set chalkboard background image
    UIImageView *chalkboardImageView = [[UIImageView alloc] init];
    [chalkboardImageView setImage:[UIImage imageNamed:@"Chalkboard"]];
    [chalkboardImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:chalkboardImageView];
    });

    self.playerNamesLabelsArray = [NSMutableArray new];
//    self.dataStore = [ASNDataStore sharedDataStore];
    
    // setup game 
    if (self.teamsArray.count > 0) {
        self.currentGame = [[ASNGame alloc] initWithTeams:self.teamsArray];
    }
    else{
        NSLog(@"there was an error receiving the TeamsArray from previous VC");
    }

    [self setupGameVisuals];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // leave session
    [self.appDelegate.mcManager.session disconnect];
    [self.appDelegate.mcManager.advertiser stopAdvertisingPeer];
    [self.appDelegate.mcManager.serviceBrowser  stopBrowsingForPeers];

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
    

    dispatch_async(dispatch_get_main_queue(), ^{
        // setup log turn button
        UIButton *logTurnButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:logTurnButton];
        
        [logTurnButton addTarget:self action:@selector(handleLogButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//        logTurnButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.7 alpha:0.2];
        [logTurnButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [logTurnButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
        [logTurnButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-200].active = YES;
        [logTurnButton.widthAnchor constraintEqualToConstant:150].active = YES;
        [logTurnButton.heightAnchor constraintEqualToConstant:30].active = YES;
        [logTurnButton setTitle:@"Log Turn" forState:UIControlStateNormal];
        logTurnButton.titleLabel.font = [UIFont fontWithName:self.fontName size:20];
        [logTurnButton setTitleColor:[UIColor colorWithRed:255.0/255 green:239.0/255 blue:129.0/255 alpha:0.8] forState:UIControlStateNormal];
        
        [self makeCurrentPlayerNameBig];
    });
}

- (void) loadPlayerNamesOfTeam:(ASNTeam *)team{
    NSUInteger numberOfPlayersOnTeam = team.players.count;
    
    // get index of team
    NSUInteger teamIndex = [self.currentGame.teams indexOfObject:team];
    for (NSUInteger i = 0; i < numberOfPlayersOnTeam; i++) {
        UILabel *currentLabel = [[UILabel alloc] init];
        [currentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        currentLabel.text = [NSString stringWithFormat:@"%@ : Didn't go", ((Player *)team.players[i]).name];
        currentLabel.font = [UIFont fontWithName:self.fontName size:15];
//        currentLabel.text = ((Player *)team.players[(i+indexOfPlayer)%numberOfPlayersOnTeam]).name;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [((UIView *)self.teamContainersArray[teamIndex]) addSubview:currentLabel];
            [currentLabel.centerXAnchor constraintEqualToAnchor:((UIView *)self.teamContainersArray[teamIndex]).centerXAnchor].active = YES;
            [currentLabel.centerYAnchor constraintEqualToAnchor:((UIView *)self.teamContainersArray[teamIndex]).centerYAnchor constant:20*i].active = YES;
            [self.playerNamesLabelsArray[teamIndex] addObject:currentLabel];
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
//            containerView.backgroundColor = [UIColor redColor];
            [self.view addSubview:containerView];
            [containerView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.2].active = YES;
            [containerView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.4].active = YES;
            [containerView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:20].active = YES;
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
            teamNameLabel.numberOfLines = 3;
            [teamNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            [self updateTeamNameAndWins:team];
//            // team name and wins/loses
//            UIFont *largerFont = [UIFont fontWithName:self.fontName size:22.0];
//            NSDictionary *largerFontDict = [NSDictionary dictionaryWithObject: largerFont forKey:NSFontAttributeName];
//            NSMutableAttributedString *firstLine = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", team.teamName] attributes: largerFontDict];
//            
//            UIFont *smallerFont = [UIFont fontWithName:self.fontName size:15.0];
//            NSDictionary *smallerFontDict = [NSDictionary dictionaryWithObject:smallerFont forKey:NSFontAttributeName];
//            NSMutableAttributedString *secondLine = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"W:%lu L:%lu", team.wins, team.loses] attributes:smallerFontDict];
//            [firstLine appendAttributedString:secondLine];
//            teamNameLabel.attributedText = firstLine;
            teamNameLabel.textAlignment = NSTextAlignmentCenter;
            

            teamNameLabel.textColor = [UIColor whiteColor];
            [containerView addSubview:teamNameLabel];
            [teamNameLabel.centerXAnchor constraintEqualToAnchor:containerView.centerXAnchor].active = YES;
            [teamNameLabel.topAnchor constraintEqualToAnchor:containerView.topAnchor].active = YES;
            
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
        for (NSString *number in @[@"20",@"19",@"18",@"17", @"16", @"15", @"Bull"]) {
            UILabel *numberLabel = [UILabel new];
            numberLabel.text = number;
            numberLabel.font = [UIFont fontWithName:self.fontName size:24];
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
        
        // End Game and New Game Buttons
        UIButton *newGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:newGameButton];
        [newGameButton addTarget:self action:@selector(handleNewGameButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [newGameButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [newGameButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:-80].active = YES;
        [newGameButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
        [newGameButton.widthAnchor constraintEqualToConstant:150].active = YES;
        [newGameButton.heightAnchor constraintEqualToConstant:30].active = YES;
        [newGameButton setTitle:@"New Game" forState:UIControlStateNormal];
        newGameButton.titleLabel.font = [UIFont fontWithName:self.fontName size:20];
        [newGameButton setTitleColor:[UIColor colorWithRed:255.0/255 green:239.0/255 blue:129.0/255 alpha:0.8] forState:UIControlStateNormal];
        
        UIButton *endGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:endGameButton];
        [endGameButton addTarget:self action:@selector(handleEndGameButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [endGameButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [endGameButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:80].active = YES;
        [endGameButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
        [endGameButton.widthAnchor constraintEqualToConstant:150].active = YES;
        [endGameButton.heightAnchor constraintEqualToConstant:30].active = YES;
        [endGameButton setTitle:@"End Game" forState:UIControlStateNormal];
        endGameButton.titleLabel.font = [UIFont fontWithName:self.fontName size:20];
        [endGameButton setTitleColor:[UIColor colorWithRed:255.0/255 green:239.0/255 blue:129.0/255 alpha:0.8] forState:UIControlStateNormal];
        
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
        
        // for every team, create the tapable numbers
        for (ASNTeam *team in self.currentGame.teams) {
            NSUInteger teamIndex = [self.currentGame.teams indexOfObject:team];
            for (NSUInteger j = 20; j>=14; j--) {
                ASNHitsContainerViews *hitsContainerView = [ASNHitsContainerViews new];
                hitsContainerView.tag = j;
                [team.arrayOfNumberViews addObject:hitsContainerView];
                
                
                [hitsContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
                [numbersContainerView addSubview:hitsContainerView];
                [hitsContainerView.heightAnchor constraintEqualToConstant:(heightConstant/7)-(heightConstant/20)].active = YES;
                [hitsContainerView.widthAnchor constraintEqualToConstant:outsideLineConstant-insideLineConstant-(heightConstant/20)].active = YES;
                // This moves the column of numberviews horizontally, based on the number of teams
                // TODO check with 3, 4 teams
                NSInteger teamHorizontalMultiplier = 0;
                if (teamIndex == 0) {
                    teamHorizontalMultiplier = -1;
                }
                else if (teamIndex == 1) {
                    teamHorizontalMultiplier = 1;
                }
                else if (teamIndex == 2) {
                    teamHorizontalMultiplier = -2;
                }
                else if (teamIndex == 3) {
                    teamHorizontalMultiplier = 2;
                }
                [hitsContainerView.centerXAnchor constraintEqualToAnchor:numbersContainerView.centerXAnchor constant:teamHorizontalMultiplier * (insideLineConstant + outsideLineConstant)/2].active = YES;
                [hitsContainerView.centerYAnchor constraintEqualToAnchor:numbersContainerView.topAnchor constant:(heightConstant/7)*((20-j) + 0.5)].active = YES;
                hitsContainerView.alpha = 0.1;
                
                // add tap gesture
                UITapGestureRecognizer *teamTap =
                [[UITapGestureRecognizer alloc] initWithTarget:self
                                                        action:@selector(handleNumberTap:)];
                [hitsContainerView addGestureRecognizer:teamTap];
                hitsContainerView.userInteractionEnabled = YES;
            }
        }
        [self enableTouchingForTeam:self.currentGame.currentTeam];

    });
    
}

-(void)updateImageOfImageView:(ASNHitsContainerViews *)imageView withValue:(NSUInteger)newValue {
    dispatch_async(dispatch_get_main_queue(), ^{
        imageView.tintColor = [UIColor whiteColor];
        if (newValue == 0) {
            imageView.alpha = 0.1;
        }
        else if (newValue == 1) {
            [imageView.hitImageView setImage:[UIImage imageNamed:@"one"]];
            imageView.alpha = 1;
            
        }
        else if (newValue == 2) {
            [imageView.hitImageView setImage:[UIImage imageNamed:@"two"]];
            imageView.alpha = 1;
        }
        else if (newValue == 3) {
            [imageView.hitImageView setImage:[UIImage imageNamed:@"three"]];
            imageView.alpha = 1;
        }
        else if (newValue > 3) {
            imageView.additionalHitsLabel.text =[NSString stringWithFormat:@"+%lu", newValue-3];
            
        }
        else {
            NSLog(@"%@ has more than 4", self.currentGame.currentTeam.teamName);
        }

    });
}

-(void)updateTeamNameAndWins:(ASNTeam *)team {
    // team name and wins/loses
    UIFont *largerFont = [UIFont fontWithName:self.fontName size:22.0];
    NSDictionary *largerFontDict = [NSDictionary dictionaryWithObject: largerFont forKey:NSFontAttributeName];
    NSMutableAttributedString *firstLine = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", team.teamName] attributes: largerFontDict];
    
    UIFont *smallerFont = [UIFont fontWithName:self.fontName size:15.0];
    NSDictionary *smallerFontDict = [NSDictionary dictionaryWithObject:smallerFont forKey:NSFontAttributeName];
    NSMutableAttributedString *secondLine = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"W:%lu L:%lu", team.wins, team.loses] attributes:smallerFontDict];
    [firstLine appendAttributedString:secondLine];
//    teamNameLabel.attributedText = firstLine;
    
    
//    NSMutableString *teamNameAndScore = [[NSString stringWithFormat:@"%@\nScore: %lu",team.teamName, team.scoreOfCurrentRound] mutableCopy];
    NSUInteger indexOfTeam = [self.currentGame.teams indexOfObject:team];
    dispatch_async(dispatch_get_main_queue(), ^{
        ((UILabel *)self.teamNameLabelsArray[indexOfTeam]).attributedText = firstLine;;
    });
}

-(void)enableTouchingForTeam:(ASNTeam *)team {
    for (ASNTeam *allTeam in self.currentGame.teams) {
        if (allTeam == team) {
            for (ASNHitsContainerViews *view in allTeam.arrayOfNumberViews) {
                view.userInteractionEnabled = YES;
            }
        }
        else {
            for (ASNHitsContainerViews *view in allTeam.arrayOfNumberViews) {
                view.userInteractionEnabled = NO;
            }
        }
    }

}

// called when logTurn, rotates names of players
// TODO: this should ONLY rotate the players names, and it should be animated. The 'updateCurrentPlayerLabel' method should be enough to handle the hits of the current player
-(void)updatePlayerNamesLabelsOfPreviousTeam:(ASNTeam *)team{
    NSUInteger indexOfPlayer = [team.players indexOfObject:team.previousPlayer]+1;
    NSUInteger numberOfPlayersOnTeam = team.players.count;
    NSUInteger teamIndex = [self.currentGame.teams indexOfObject:team];

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
        if (playersPreviousRoundResults.length == 0) {
            playersPreviousRoundResults = @"Nada";
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            ((UILabel *)self.playerNamesLabelsArray[teamIndex][i]).text = [NSString stringWithFormat:@"%@ : %@", currentPlayer.name, playersPreviousRoundResults];
        });
    }
    
    [self enableTouchingForTeam:self.currentGame.currentTeam];

}

-(void)makeCurrentPlayerNameBig {
    // make all labels small
    for (NSArray *teamPlayerLabelArray in self.playerNamesLabelsArray) {
        for (UILabel *playerNameLabel in teamPlayerLabelArray) {
            dispatch_async(dispatch_get_main_queue(), ^{
                playerNameLabel.font = [UIFont systemFontOfSize:15];
                playerNameLabel.textColor = [UIColor whiteColor];
                playerNameLabel.transform = CGAffineTransformIdentity;
            });
        }
    }
    // make current player's label bigger
    NSUInteger teamIndex = [self.currentGame.teams indexOfObject:self.currentGame.currentTeam];
    UILabel *playerLabel = ((UILabel *)self.playerNamesLabelsArray[teamIndex][0]);
    dispatch_async(dispatch_get_main_queue(), ^{
        playerLabel.font = [UIFont systemFontOfSize:18];
        playerLabel.textColor = [UIColor colorWithRed:255.0/255 green:239.0/255 blue:129.0/255 alpha:1];
        [UIView animateWithDuration:0.25 animations:^{
            playerLabel.transform = CGAffineTransformScale(playerLabel.transform, 1.25, 1.25);
        }];
    });
}

-(void)updateCurrentPlayerLabel {
    NSString *playersCurrentHits = @"";
    for (NSString *hit in self.currentGame.currentPlayer.currentHits) {
        if ([self.currentGame.currentPlayer.currentHits[hit] integerValue] > 0) {
            for (NSUInteger i = 0; i< [self.currentGame.currentPlayer.currentHits[hit] integerValue]; i++) {
                playersCurrentHits = [playersCurrentHits stringByAppendingString:[NSString stringWithFormat:@"%@ ",hit]];
            }
        }
    }
    NSUInteger teamIndex = [self.currentGame.teams indexOfObject:self.currentGame.currentTeam];
    UILabel *playerLabel = ((UILabel *)self.playerNamesLabelsArray[teamIndex][0]);
    dispatch_async(dispatch_get_main_queue(), ^{
        playerLabel.text = [NSString stringWithFormat:@"%@ : %@", self.currentGame.currentPlayer.name, playersCurrentHits];        
    });
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
    
    // check if number not closed when number of hits is 3 or more
    if ([self.currentGame.currentTeam.hitsInCurrentRound[hit] integerValue] >=3 && [self.currentGame isCurrentTeamsNumberClosed:hit]) {
        // TODO: make the other team's views glow red
        return;
    }

    [self recordNumberHit:hit andView:((ASNHitsContainerViews *)recognizer.view)];
    [self sendToAllConnectedPeersString:hit];
}

-(void)recordNumberHit:(NSString *)hit andView:(ASNHitsContainerViews *)associatedView {
    [self.currentGame.currentPlayer addHitToCurrentHits:hit];
    NSUInteger newValueForKey = [self.currentGame addHit:hit toTeamCurrentRound:self.currentGame.currentTeam];
    [self updateTeamNameAndWins:self.currentGame.currentTeam];
    [self updateCurrentPlayerLabel];
    [self updateImageOfImageView:associatedView withValue:newValueForKey];

    ASNTeam *winner = [self.currentGame returnIfThereIsAWinner];
    if (winner) {
        //update wins/losses for each team
        for (ASNTeam *team in self.currentGame.teams) {
            if (team == winner) {
                team.wins++;
            }
            else {
                team.loses++;
            }
        }
        
        // present alert if there is a winner
        UIAlertController *gameOverAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ wins!", winner.teamName] message:@"Play Again?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self handleNewGameTappedAtEndOfGame];
            self.isAlertControllerPresented = NO;
        }];
        UIAlertAction *no = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self handleEndGameTapped];
            self.isAlertControllerPresented = NO;
        }];
        
        [gameOverAlert addAction:no];
        [gameOverAlert addAction:yes];
        [gameOverAlert.view setNeedsLayout];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:gameOverAlert animated:YES completion:nil];
            self.isAlertControllerPresented = YES;
        });
    };
}



-(void)handleLogButtonTapped:(id)sender {
    [self logTurn];
    [self sendToAllConnectedPeersString:@"logTurn"];
}

-(void)logTurn {
    [self.currentGame logTurnOfCurrentPlayer];
    [self updatePlayerNamesLabelsOfPreviousTeam:self.currentGame.previousTeam];
    [self makeCurrentPlayerNameBig];
    [self enableTouchingForTeam:self.currentGame.currentTeam];
    [self updateCurrentPlayerLabel];
}

-(void)handleNewGameButtonTapped:(id)sender {
    // present alert
    UIAlertController *newGameAlert = [UIAlertController alertControllerWithTitle:@"New Game" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self handleNewGameTappedAtEndOfGame];
        self.isAlertControllerPresented = NO;
    }];
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.isAlertControllerPresented = NO;
    }];
    
    [newGameAlert addAction:no];
    [newGameAlert addAction:yes];
    [newGameAlert.view setNeedsLayout];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:newGameAlert animated:YES completion:nil];
        self.isAlertControllerPresented = YES;
    });
}

-(void)handleNewGameTappedAtEndOfGame {
    [self sendToAllConnectedPeersString:@"newGame"];
    [self newGame];
}

-(void)newGame {
    self.currentGame = [[ASNGame alloc] initWithTeams:self.teamsArray];
    
    for (ASNTeam *team in self.currentGame.teams) {
        [self updateTeamNameAndWins:team];
        [self updatePlayerNamesLabelsOfPreviousTeam:team];
    }
    for (ASNTeam *team in self.currentGame.teams) {
        for (ASNHitsContainerViews *view in team.arrayOfNumberViews) {
            dispatch_async(dispatch_get_main_queue(), ^{
                view.alpha = 0.1;
            });
        }
    }
}
-(void)handleEndGameButtonTapped:(id)sender {
    // present alert
    UIAlertController *endGameAlert = [UIAlertController alertControllerWithTitle:@"End Game" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self handleEndGameTapped];
        self.isAlertControllerPresented = NO;
    }];
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.isAlertControllerPresented = NO;
    }];
    
    [endGameAlert addAction:no];
    [endGameAlert addAction:yes];
    [endGameAlert.view setNeedsLayout];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:endGameAlert animated:YES completion:nil];
        self.isAlertControllerPresented = YES;
    });
}

-(void)handleEndGameTapped {
    [self sendToAllConnectedPeersString:@"endGame"];
    [self endGame];
}

-(void)endGame {
    // go to welcome page
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self navigationController] popToRootViewControllerAnimated:YES];
    });
}


-(void)sendToAllConnectedPeersString:(NSString *)string {
    // tell everyone turn logged
    if (self.appDelegate.mcManager.session.connectedPeers.count > 0) {
        NSData *dataToSend = [string dataUsingEncoding:NSUTF8StringEncoding];
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

}

-(void)didReceiveDataNotification:(NSNotification *)notification {
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *receivedDataUnarchived = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"this is the unarchived data i received in MainGameVC: %@ from %@", receivedDataUnarchived, peerDisplayName);
    
    if ([receivedDataUnarchived isEqualToString:@"logTurn"]) {
        [self logTurn];
    }
    else if ([receivedDataUnarchived integerValue] >= 15 && [receivedDataUnarchived integerValue] <= 20 ) {
        [self recordNumberHit:receivedDataUnarchived andView:self.currentGame.currentTeam.arrayOfNumberViews[20-[receivedDataUnarchived integerValue]]];
    }
    else if ([receivedDataUnarchived isEqualToString:@"Bull"]) {
        [self recordNumberHit:receivedDataUnarchived andView:self.currentGame.currentTeam.arrayOfNumberViews[6]];
    }
    else if ([receivedDataUnarchived isEqualToString:@"endGame"]) {
        // dismiss presented view controller
        if (self.isAlertControllerPresented) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        // present alert
        UIAlertController *peerEndedGameAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ ended the game", peerDisplayName] message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK, I guess..." style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self endGame];
            self.isAlertControllerPresented = NO;
        }];
        
        [peerEndedGameAlert addAction:ok];
        [peerEndedGameAlert.view setNeedsLayout];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:peerEndedGameAlert animated:YES completion:nil];
            self.isAlertControllerPresented = YES;
        });
    }
    else if ([receivedDataUnarchived isEqualToString:@"newGame"]) {
        // dismiss presented view controller
        if (self.isAlertControllerPresented) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        [self newGame];
    }
}

@end
