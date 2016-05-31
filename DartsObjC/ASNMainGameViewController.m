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

@interface ASNMainGameViewController ()

@property (strong, nonatomic) ASNDataStore *dataStore;

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

@property (strong, nonatomic) UILabel *currentPlayerLabel;

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
    
    
    
    self.currentGame = [[ASNGame alloc] initWithTeams:self.dataStore.teams];
    
    // move this line to other place later
    [self.currentGame.currentPlayer setupPlayerForRound];

    [self setupGameVisuals];
    [self enableTouchingForTeam:self.currentGame.currentTeam];

}

-(void)viewDidLayoutSubviews {
//    [self setupGameVisuals];
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
    
    
    // setup current player label
    self.currentPlayerLabel = [[UILabel alloc] init];
    self.currentPlayerLabel.numberOfLines = 4;
    [self.currentPlayerLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.currentPlayerLabel];
    [self.currentPlayerLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:20].active = YES;
    [self.currentPlayerLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self updateCurrentPlayerLabel];
    
    // setup log turn button
    UIButton *logTurnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:logTurnButton];

    [logTurnButton addTarget:self action:@selector(handleLogButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    logTurnButton.backgroundColor = [UIColor blueColor];
    [logTurnButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [logTurnButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [logTurnButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-200].active = YES;
    [logTurnButton.widthAnchor constraintEqualToConstant:30].active = YES;
    [logTurnButton.heightAnchor constraintEqualToConstant:30].active = YES;
//    [logTurnButton setTitle:@"Log Turn" forState:UIControlStateNormal];
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
        [((UIView *)self.teamContainersArray[teamIndex]) addSubview:currentLabel];
        [currentLabel.centerXAnchor constraintEqualToAnchor:((UIView *)self.teamContainersArray[teamIndex]).centerXAnchor].active = YES;
        [currentLabel.centerYAnchor constraintEqualToAnchor:((UIView *)self.teamContainersArray[teamIndex]).centerYAnchor constant:20*i].active = YES;
        [self.playerNamesLabelsArray[teamIndex] addObject:currentLabel];
    }
}

- (void) setupContainerViewsForTeams:(NSArray *)teamsArray {
    self.teamContainersArray = [NSMutableArray new];
    
    self.team1NameLabel = [UILabel new];
    self.team2NameLabel = [UILabel new];
    self.team3NameLabel = [UILabel new];
    self.team4NameLabel = [UILabel new];
    self.teamNameLabelsArray = @[self.team1NameLabel, self.team2NameLabel, self.team3NameLabel, self.team4NameLabel];
    
    NSUInteger counter = 0;
    for (ASNTeam *team in teamsArray) {
        UIView *containerView = [[UIView alloc] init];
        [containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        containerView.backgroundColor = [UIColor redColor];
        [self.view addSubview:containerView];
        [containerView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.2].active = YES;
        [containerView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.4].active = YES;
        [containerView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
        [self.teamContainersArray addObject:containerView];
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
        teamNameLabel.font = [UIFont fontWithName:@"Times" size:24];
        [containerView addSubview:teamNameLabel];
        [teamNameLabel.centerXAnchor constraintEqualToAnchor:containerView.centerXAnchor].active = YES;
        [teamNameLabel.centerYAnchor constraintEqualToAnchor:containerView.centerYAnchor constant:-50].active = YES;
        
        counter++;
    }

}

- (void) setupNumbersContainerView {
    // container view of numbers, lines, buttons
    UIView *numbersContainerView = [[UIView alloc] init];
//    numbersContainerView.backgroundColor = [UIColor blueColor];
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
        numberLabel.font = [UIFont fontWithName:@"Copperplate" size:25];
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
}

-(void)updateTeamNameAndScore:(ASNTeam *)team {
    NSMutableString *teamNameAndScore = [[NSString stringWithFormat:@"%@\nScore: %lu",team.teamName, team.scoreOfCurrentRound] mutableCopy];
    NSUInteger indexOfTeam = [self.currentGame.teams indexOfObject:team];
    ((UILabel *)self.teamNameLabelsArray[indexOfTeam]).text = teamNameAndScore;
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

-(void)updateCurrentPlayerLabel {
    NSMutableString *labelText = [[NSString stringWithFormat:@"Current Player: \n%@ \nCurrent Hits:\n",self.currentGame.currentPlayer.name] mutableCopy];
    for (NSString *key in self.currentGame.currentPlayer.currentHits) {
        NSUInteger countOfHitsForKey = [self.currentGame.currentPlayer.currentHits[key] integerValue];
        while (countOfHitsForKey>0) {
            labelText = [[labelText stringByAppendingString:[NSString stringWithFormat:@"%@ ",key]] mutableCopy];
            countOfHitsForKey--;
        }

    }
    self.currentPlayerLabel.text = labelText;
}

// called when logTurn, rotates names of players
-(void)updatePlayerNamesLabelsOfPreviousTeam:(ASNTeam *)team{
    NSUInteger indexOfPlayer = [team.players indexOfObject:team.previousPlayer]+1;
    NSUInteger numberOfPlayersOnTeam = team.players.count;
    NSUInteger teamIndex = [self.currentGame.teams indexOfObject:team];
//    if ([team.players containsObject:self.currentGame.currentPlayer]) {
//        indexOfPlayer = [team.players indexOfObject:self.currentGame.currentPlayer];
//    }
    for (NSUInteger i = 0; i < numberOfPlayersOnTeam; i++) {
        Player *currentPlayer = ((Player *)team.players[(i+indexOfPlayer)%numberOfPlayersOnTeam]);
        NSDictionary *previousHits = ((Turn *)[currentPlayer.turnsOfPlayer lastObject]).hits;
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
    [self.currentGame.currentPlayer addHitToCurrentHits:hit];
    NSUInteger newValueForKey = [self.currentGame addHit:hit toTeamCurrentRound:self.currentGame.currentTeam];
    [self updateTeamNameAndScore:self.currentGame.currentTeam];
    [self updateImageOfImageView:((UIImageView *)recognizer.view) withValue:newValueForKey];
    [self updateCurrentPlayerLabel];
    if ([self.currentGame isThereAWinner]) {
        // Do something if there is a winner
    };
}

-(void)handleLogButtonTapped:(id)sender {
    [self.currentGame logTurnOfCurrentPlayer];
    [self updatePlayerNamesLabelsOfPreviousTeam:self.currentGame.previousTeam];
    [self updateCurrentPlayerLabel];
    [self enableTouchingForTeam:self.currentGame.currentTeam];
}

@end
