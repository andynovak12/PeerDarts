
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
#import "ASNUIElements.h"
#import "UISwitch+ASNSwitchStyle.h"
#import "UILabel+ASNLabelStyle.h"
#import "UIButton+ASNButtonStyle.h"
#import <DCPathButton/DCPathButton.h>

@interface ASNMainGameViewController () <DCPathButtonDelegate>

//@property (strong, nonatomic) ASNDataStore *dataStore;
@property (nonatomic, strong) AppDelegate *appDelegate;

@property (strong, nonatomic) NSMutableArray *teamContainersArray;

@property (strong, nonatomic) UILabel *team1NameLabel;
@property (strong, nonatomic) UILabel *team2NameLabel;
@property (strong, nonatomic) UILabel *team3NameLabel;
@property (strong, nonatomic) UILabel *team4NameLabel;
@property (strong, nonatomic) NSArray *teamNameLabelsArray;

@property (strong, nonatomic) UILabel *team1ScoreLabel;
@property (strong, nonatomic) UILabel *team2ScoreLabel;
@property (strong, nonatomic) UILabel *team3ScoreLabel;
@property (strong, nonatomic) UILabel *team4ScoreLabel;
@property (strong, nonatomic) NSArray *teamScoreLabelsArray;

@property (strong, nonatomic) NSMutableArray *playerNamesLabelsArray;
@property (strong, nonatomic) NSMutableArray *teamTouchIndicatorArray;

@property (strong, nonatomic) ASNGame *currentGame;

@property (nonatomic) BOOL isAlertControllerPresented;

@property (nonatomic) CGFloat heightOfScoreBoardArea;
@property (nonatomic) CGFloat insideLineConstraint;
@property (nonatomic) CGFloat outsideLineConstraint;

@property (strong, nonatomic) UIView *numbersContainerView;
@property (strong, nonatomic) UIButton *logTurnButton;
@property (strong, nonatomic) DCPathButton *centerButton;


@end

@implementation ASNMainGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isAlertControllerPresented = NO;

    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.navigationController.navigationBarHidden = YES;

    
    // set chalkboard background image
    UIImageView *chalkboardImageView = [[UIImageView alloc] init];
    [chalkboardImageView setImage:[UIImage imageNamed:@"background"]];
    chalkboardImageView.contentMode = UIViewContentModeScaleAspectFill;
    [chalkboardImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:chalkboardImageView];
    });

    self.playerNamesLabelsArray = [NSMutableArray new];
    self.teamTouchIndicatorArray = [NSMutableArray new];
//    self.dataStore = [ASNDataStore sharedDataStore];
    
    // setup game 
    if (self.teamsArray.count > 0) {
        self.currentGame = [[ASNGame alloc] initWithTeams:self.teamsArray];
    }
    else{
        NSLog(@"there was an error receiving the TeamsArray from previous VC");
        // alert user and go back to home page
        UIAlertController *errorStartingGameAlertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"You lost connection while game was being created" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"That Sucks" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self endGame];
            self.isAlertControllerPresented = NO;
        }];
        
        [errorStartingGameAlertController addAction:ok];
        [errorStartingGameAlertController.view setNeedsLayout];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:errorStartingGameAlertController animated:YES completion:nil];
            self.isAlertControllerPresented = YES;
        });

    }

    // this controls the height of the scoreboard area
    self.heightOfScoreBoardArea = 0.6;
    
    // this controls the x position of the vertical lines in the scoreboard area
    if (self.currentGame.teams.count <= 2) {
        self.outsideLineConstraint = self.view.frame.size.width/2.8;
    }
    else {
        self.outsideLineConstraint = self.view.frame.size.width/3.6;
    }
    self.insideLineConstraint = self.view.frame.size.width/12;

    
    
    
    [self setupGameVisuals];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
}
-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.logTurnButton buttonWithMyStyleAndSizePriority:medium];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // leave session
    [self.appDelegate.mcManager.session disconnect];
    [self.appDelegate.mcManager.advertiser stopAdvertisingPeer];
    [self.appDelegate.mcManager.serviceBrowser  stopBrowsingForPeers];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MCDidReceiveDataNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MCDidChangeStateNotification" object:nil];

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
    

    // center Button
    self.centerButton = [[DCPathButton alloc] initWithCenterImage:[UIImage imageNamed:@"more"] highlightedImage:[UIImage imageNamed:@"more"]];
    self.centerButton.delegate = self;
    self.centerButton.allowSounds = NO;
    self.centerButton.bloomDirection = kDCPathButtonBloomDirectionTopLeft;
    // controls the color of the background view when button pressed
    self.centerButton.bottomViewColor = ASNDarkestColor;
    self.centerButton.dcButtonCenter = CGPointMake(self.view.frame.size.width - 30, self.view.frame.size.height - 30);

    DCPathItemButton *refreshButton = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"refresh"]
                                                            highlightedImage:[UIImage imageNamed:@"refresh"]
                                                             backgroundImage:[UIImage imageNamed:@"refresh"]
                                                  backgroundHighlightedImage:[UIImage imageNamed:@"lightCircle"]];
    DCPathItemButton *endGameButton = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"exit"]
                                                            highlightedImage:[UIImage imageNamed:@"exit"]
                                                             backgroundImage:[UIImage imageNamed:@"exit"]
                                                  backgroundHighlightedImage:[UIImage imageNamed:@"lightCircle"]];
    DCPathItemButton *undoButton = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"undo"]
                                                         highlightedImage:[UIImage imageNamed:@"undo"]
                                                          backgroundImage:[UIImage imageNamed:@"undo"]
                                               backgroundHighlightedImage:[UIImage imageNamed:@"lightCircle"]];
    DCPathItemButton *eraseButton = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"erase"]
                                                         highlightedImage:[UIImage imageNamed:@"erase"]
                                                          backgroundImage:[UIImage imageNamed:@"erase"]
                                               backgroundHighlightedImage:[UIImage imageNamed:@"lightCircle"]];
    
    self.centerButton.tintColor = ASNYellowColor;
    
    refreshButton.tintColor = ASNYellowColor;
    endGameButton.tintColor = ASNYellowColor;
    undoButton.tintColor = ASNYellowColor;
    eraseButton.tintColor = ASNYellowColor;
    [self.centerButton addPathItems:@[refreshButton, undoButton, eraseButton, endGameButton]];
    

    [self makeCurrentPlayerNameBig];
    
    [self setupLogTurnButton];

    dispatch_async(dispatch_get_main_queue(), ^{
        // setup log turn butto
        [self.view insertSubview:self.centerButton aboveSubview:self.logTurnButton];
        
        
    });
}

-(void)setupLogTurnButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.logTurnButton) {
            // setup log turn button
            self.logTurnButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [self.view addSubview:self.logTurnButton];
            
            [self.logTurnButton addTarget:self action:@selector(handleLogButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.logTurnButton setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self.logTurnButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
            [self.logTurnButton.topAnchor constraintEqualToAnchor:self.numbersContainerView.bottomAnchor constant:20].active = YES;
            [self.logTurnButton.widthAnchor constraintEqualToConstant:self.insideLineConstraint*2].active = YES;
            [self.logTurnButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-11].active = YES;
            
            [self.logTurnButton setTitle:@"Log\nTurn" forState:UIControlStateNormal];
            self.logTurnButton.titleLabel.numberOfLines = 2;            
        }
        
    });
}


// Loads the player name labels when game starts
- (void) loadPlayerNamesOfTeam:(ASNTeam *)team{
    NSUInteger numberOfPlayersOnTeam = team.players.count;
    // get index of team
    NSUInteger teamIndex = [self.currentGame.teams indexOfObject:team];
    
    
    
    
    
    

    
    
    //Stack View
    UIStackView *playerNamesStackView = [[UIStackView alloc] init];
    
    playerNamesStackView.axis = UILayoutConstraintAxisVertical;
    playerNamesStackView.distribution = UIStackViewDistributionEqualSpacing;
    playerNamesStackView.alignment = UIStackViewAlignmentCenter;
    playerNamesStackView.spacing = 10;

    playerNamesStackView.translatesAutoresizingMaskIntoConstraints = false;

    dispatch_async(dispatch_get_main_queue(), ^{
        [((UIView *)self.teamContainersArray[teamIndex]) addSubview:playerNamesStackView];
        [playerNamesStackView.centerXAnchor constraintEqualToAnchor:((UIView *)self.teamContainersArray[teamIndex]).centerXAnchor].active = YES;
        [playerNamesStackView.centerYAnchor constraintEqualToAnchor:((UIView *)self.teamContainersArray[teamIndex]).centerYAnchor].active = YES;
        [playerNamesStackView.widthAnchor constraintEqualToAnchor:((UIView *)self.teamContainersArray[teamIndex]).widthAnchor multiplier:0.9].active = YES;
        [playerNamesStackView.heightAnchor constraintEqualToAnchor:((UIView *)self.teamContainersArray[teamIndex]).heightAnchor multiplier:0.3].active = YES;
    });
    

    
    for (NSUInteger i = 0; i <= numberOfPlayersOnTeam; i++) {

        UILabel *currentLabel = [[UILabel alloc] init];
        currentLabel.textAlignment = NSTextAlignmentCenter;
        currentLabel.minimumScaleFactor = 0.5;
        currentLabel.adjustsFontSizeToFitWidth = YES;
        
//        currentLabel.font = [UIFont fontWithName:fontName size:15];
        [currentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        if (i < numberOfPlayersOnTeam) {
            currentLabel.text = ((Player *)team.players[i]).name;

            dispatch_async(dispatch_get_main_queue(), ^{
                [playerNamesStackView addArrangedSubview:currentLabel];

//                [((UIView *)self.teamContainersArray[teamIndex]) addSubview:currentLabel];
//                [currentLabel.centerXAnchor constraintEqualToAnchor:playerNamesSubView.centerXAnchor].active = YES;
                [currentLabel.widthAnchor constraintEqualToAnchor:playerNamesStackView.widthAnchor].active = YES;
                [currentLabel.heightAnchor constraintEqualToAnchor:playerNamesStackView.heightAnchor multiplier:0.22].active = YES;
            });

        }
        // for "Previous: " label
        else {
            currentLabel.text = @"Previous: \nN/A";
            [currentLabel labelWithMyStyleAndSizePriority:low];
            currentLabel.numberOfLines = 2;
            dispatch_async(dispatch_get_main_queue(), ^{
                [((UIView *)self.teamContainersArray[teamIndex]) addSubview:currentLabel];
                [currentLabel.centerXAnchor constraintEqualToAnchor:((UIView *)self.teamContainersArray[teamIndex]).centerXAnchor].active = YES;
                [currentLabel.bottomAnchor constraintEqualToAnchor:((UIView *)self.teamContainersArray[teamIndex]).bottomAnchor constant:-5].active = YES;
                [currentLabel.widthAnchor constraintEqualToAnchor:((UIView *)self.teamContainersArray[teamIndex]).widthAnchor multiplier:0.9].active = YES;
                [currentLabel.heightAnchor constraintEqualToAnchor:((UIView *)self.teamContainersArray[teamIndex]).heightAnchor multiplier:0.25].active = YES;
                
            });

        }


        
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

    
    self.team1ScoreLabel = [UILabel new];
    self.team2ScoreLabel = [UILabel new];
    self.team3ScoreLabel = [UILabel new];
    self.team4ScoreLabel = [UILabel new];
    self.teamScoreLabelsArray = @[self.team1ScoreLabel, self.team2ScoreLabel, self.team3ScoreLabel, self.team4ScoreLabel];
    
    __block NSUInteger counter = 0;
    NSUInteger numberOfTeams = teamsArray.count;
    for (ASNTeam *team in teamsArray) {
        UIView *containerView = [[UIView alloc] init];
        [self.teamContainersArray addObject:containerView];
        CGFloat containerWidth;
        switch (numberOfTeams) {
            case 1:
                containerWidth = 2 * self.outsideLineConstraint;
                containerView.layer.cornerRadius = 10;
                break;
            case 2:
                containerWidth = self.outsideLineConstraint;
                containerView.layer.cornerRadius = 10;
                break;
                
            default:
                containerWidth = (self.outsideLineConstraint-self.insideLineConstraint);
                containerView.layer.cornerRadius = 5;

                break;
        }
        
        CGFloat containerBuffer = containerWidth / 18;
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
            containerView.backgroundColor = ASNDarkestColor;
            [self.view addSubview:containerView];
            [containerView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:(1-self.heightOfScoreBoardArea-0.18)].active = YES;
            [containerView.widthAnchor constraintEqualToConstant:containerWidth-(2*containerBuffer)].active = YES;
            [containerView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-self.view.frame.size.height/2.8].active = YES;
            
            // adjusts the x position of the team container views
            switch (numberOfTeams) {
                case 1:
                    [containerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
                    break;
                case 2:
                    if (counter == 0) {
                        [containerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:-(containerWidth/2 + self.insideLineConstraint)].active = YES;
                    }
                    else if (counter == 1) {
                        [containerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:(containerWidth/2 + self.insideLineConstraint)].active = YES;
                    }
                    break;
                case 3:
                    if (counter == 0) {
                        [containerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:-(containerWidth/2 + self.insideLineConstraint)].active = YES;
                    }
                    else if (counter == 1) {
                        [containerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:(containerWidth/2 + self.insideLineConstraint)].active = YES;
                    }
                    else if (counter == 2) {
                        [containerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:-2.2*(containerWidth/2 + self.insideLineConstraint)].active = YES;
                        
                    }
                    break;
                    
                case 4:
                    if (counter == 0) {
                        [containerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:-(containerWidth/2 + self.insideLineConstraint)].active = YES;
                    }
                    else if (counter == 1) {
                        [containerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:(containerWidth/2 + self.insideLineConstraint)].active = YES;
                    }
                    else if (counter == 2) {
                        [containerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:-2.2*(containerWidth/2 + self.insideLineConstraint)].active = YES;
                        
                    }
                    else if (counter == 3) {
                        [containerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:2.2*(containerWidth/2 + self.insideLineConstraint)].active = YES;
                    }
                    else {
                        NSLog(@"Dont know how to deal with more than 4 teams layout");
                    }
                    break;
                    
            }
            
            
            UILabel *teamNameLabel = self.teamNameLabelsArray[counter];
            teamNameLabel.numberOfLines = 2;
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
            

            teamNameLabel.textColor = ASNLightestColor;
            [containerView addSubview:teamNameLabel];
            [teamNameLabel.centerXAnchor constraintEqualToAnchor:containerView.centerXAnchor].active = YES;
            [teamNameLabel.topAnchor constraintEqualToAnchor:containerView.topAnchor].active = YES;
            [teamNameLabel.widthAnchor constraintEqualToAnchor:containerView.widthAnchor multiplier:0.9].active = YES;
//            [teamNameLabel.heightAnchor constraintEqualToAnchor:containerView.heightAnchor multiplier:0.25].active = YES;
            counter++;
        });
    }

}

- (void) setupNumbersContainerView {
    // container view of numbers, lines, buttons
    self.numbersContainerView = [[UIView alloc] init];
//    numbersContainerView.backgroundColor = [UIColor blueColor];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.numbersContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:self.numbersContainerView];
        [self.numbersContainerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
        [self.numbersContainerView.topAnchor constraintEqualToAnchor:((UIView *)self.teamContainersArray[0]).bottomAnchor constant:10].active = YES;
        // this controls the height of the scoreboard
        CGFloat heightConstant = self.view.frame.size.height * self.heightOfScoreBoardArea;
        [self.numbersContainerView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:self.heightOfScoreBoardArea].active = YES;
        [self.numbersContainerView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.85].active = YES;
        
        // set up numbers
        CGFloat counterForNumbers = 0;
        for (NSString *number in @[@"20",@"19",@"18",@"17", @"16", @"15", @"Bull"]) {
            UILabel *numberLabel = [UILabel new];
            numberLabel.text = number;
            [numberLabel labelWithMyStyleAndSizePriority:low];
            numberLabel.font = [UIFont fontWithName:fontName size:20];
            [numberLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self.numbersContainerView addSubview:numberLabel];
            [numberLabel.centerXAnchor constraintEqualToAnchor:self.numbersContainerView.centerXAnchor].active = YES;
            [numberLabel.centerYAnchor constraintEqualToAnchor:self.numbersContainerView.topAnchor constant:(heightConstant/7)*(counterForNumbers + 0.5)].active = YES;
            
            // add bottom line
            if (counterForNumbers < 6) {
                UIView *bottomLine = [UIView new];
                bottomLine.backgroundColor = ASNLightestColor;
                [bottomLine setTranslatesAutoresizingMaskIntoConstraints:NO];
                [self.numbersContainerView addSubview:bottomLine];
                [bottomLine.widthAnchor constraintEqualToAnchor:self.numbersContainerView.widthAnchor constant:20].active = YES;
                [bottomLine.heightAnchor constraintEqualToConstant:2].active = YES;
                [bottomLine.centerYAnchor constraintEqualToAnchor:self.numbersContainerView.topAnchor constant:(heightConstant/7)*(counterForNumbers+1)].active = YES;
                [bottomLine.centerXAnchor constraintEqualToAnchor:self.numbersContainerView.centerXAnchor].active = YES;
            }
            
            counterForNumbers++;
        }
        
        
        // vertical lines
        for (NSUInteger i = 0; i<4; i++) {
            UIView *VLine = [UIView new];
            VLine.backgroundColor = ASNLightestColor;
            [VLine setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self.numbersContainerView addSubview:VLine];
            [VLine.widthAnchor constraintEqualToConstant:2].active = YES;
            [VLine.heightAnchor constraintEqualToAnchor:self.numbersContainerView.heightAnchor].active = YES;
            [VLine.centerYAnchor constraintEqualToAnchor:self.numbersContainerView.centerYAnchor].active = YES;
            
            if (i == 0) {
                [VLine.centerXAnchor constraintEqualToAnchor:self.numbersContainerView.centerXAnchor constant:-self.outsideLineConstraint].active = YES;
            }
            else if (i == 1) {
                [VLine.centerXAnchor constraintEqualToAnchor:self.numbersContainerView.centerXAnchor constant:-self.insideLineConstraint].active = YES;
            }
            else if (i == 2) {
                [VLine.centerXAnchor constraintEqualToAnchor:self.numbersContainerView.centerXAnchor constant:self.insideLineConstraint].active = YES;
            }
            else if (i == 3) {
                [VLine.centerXAnchor constraintEqualToAnchor:self.numbersContainerView.centerXAnchor constant:self.outsideLineConstraint].active = YES;
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
                [self.numbersContainerView addSubview:hitsContainerView];
                [hitsContainerView.heightAnchor constraintEqualToConstant:(heightConstant/7)-(heightConstant/20)].active = YES;
                [hitsContainerView.widthAnchor constraintEqualToConstant:self.outsideLineConstraint-self.insideLineConstraint].active = YES;
                // This moves the column of tappable numberviews horizontally, based on the number of teams
                CGFloat teamHorizontalMultiplier = 0;
                if (teamIndex == 0) {
                    teamHorizontalMultiplier = -1;
                }
                else if (teamIndex == 1) {
                    teamHorizontalMultiplier = 1;
                }
                else if (teamIndex == 2) {
                    teamHorizontalMultiplier = -2.2;
                }
                else if (teamIndex == 3) {
                    teamHorizontalMultiplier = 2.2;
                }
                [hitsContainerView.centerXAnchor constraintEqualToAnchor:self.numbersContainerView.centerXAnchor constant:teamHorizontalMultiplier * (self.insideLineConstraint + self.outsideLineConstraint)/2].active = YES;
                [hitsContainerView.centerYAnchor constraintEqualToAnchor:self.numbersContainerView.topAnchor constant:(heightConstant/7)*((20-j) + 0.5)].active = YES;
//                hitsContainerView.backgroundColor = ASNLightestColor;
//                hitsContainerView.alpha = 0.1;
                
                // add tap gesture
                UITapGestureRecognizer *teamTap =
                [[UITapGestureRecognizer alloc] initWithTarget:self
                                                        action:@selector(handleNumberTap:)];
                [hitsContainerView addGestureRecognizer:teamTap];
                hitsContainerView.userInteractionEnabled = YES;
            }
            
            // create highlight view for every team
            UIView *teamTouchIndicatorView = [[UIView alloc] initWithFrame:CGRectNull];
            [self.teamTouchIndicatorArray addObject:teamTouchIndicatorView];
            teamTouchIndicatorView.backgroundColor = ASNLightestColor;
            teamTouchIndicatorView.alpha = 0.1;
            [self.view insertSubview:teamTouchIndicatorView belowSubview:self.numbersContainerView];
            [teamTouchIndicatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [teamTouchIndicatorView.topAnchor constraintEqualToAnchor:self.numbersContainerView.topAnchor].active = YES;
            [teamTouchIndicatorView.bottomAnchor constraintEqualToAnchor:self.numbersContainerView.bottomAnchor].active = YES;
            [teamTouchIndicatorView.widthAnchor constraintEqualToAnchor:((UIView *)team.arrayOfNumberViews[0]).widthAnchor].active = YES;
            CGFloat teamHorizontalMultiplier = 0;
            if (teamIndex == 0) {
                teamHorizontalMultiplier = -1;
            }
            else if (teamIndex == 1) {
                teamHorizontalMultiplier = 1;
            }
            else if (teamIndex == 2) {
                teamHorizontalMultiplier = -2.2;
            }
            else if (teamIndex == 3) {
                teamHorizontalMultiplier = 2.2;
            }
            [teamTouchIndicatorView.centerXAnchor constraintEqualToAnchor:self.numbersContainerView.centerXAnchor constant:teamHorizontalMultiplier * (self.insideLineConstraint + self.outsideLineConstraint)/2].active = YES;
            
            
            // layout the score label
            UILabel *scoreLabel = self.teamScoreLabelsArray[teamIndex];
            [scoreLabel labelWithMyStyleAndSizePriority:low];
            scoreLabel.textColor = ASNLightColor;
            scoreLabel.textAlignment = NSTextAlignmentCenter;
            [self.view insertSubview:scoreLabel aboveSubview:teamTouchIndicatorView];
            [scoreLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [scoreLabel.topAnchor constraintEqualToAnchor:teamTouchIndicatorView.bottomAnchor constant:2].active = YES;
            [scoreLabel.centerXAnchor constraintEqualToAnchor:teamTouchIndicatorView.centerXAnchor].active = YES;
            [scoreLabel.widthAnchor constraintEqualToAnchor:teamTouchIndicatorView.widthAnchor multiplier:0.9].active = YES;
            scoreLabel.text = [NSString stringWithFormat:@"Score: 0"];
        }
        [self enableTouchingForTeam:self.currentGame.currentTeam];

    });
}

-(void)updateScoreOfTeam:(ASNTeam *)team {
    NSUInteger indexOfTeam = [self.currentGame.teams indexOfObject:team];
    dispatch_async(dispatch_get_main_queue(), ^{
         ((UILabel *)self.teamScoreLabelsArray[indexOfTeam]).text = [NSString stringWithFormat:@"%lu", ((ASNTeam *)self.currentGame.teams[indexOfTeam]).scoreOfCurrentRound];
    });
}

-(void)updateImageOfImageView:(ASNHitsContainerViews *)containerView withValue:(NSUInteger)newValue {
    dispatch_async(dispatch_get_main_queue(), ^{

        if (newValue == 0) {
            containerView.hitImageViewBottom.hidden = YES;
            containerView.hitImageViewMiddle.hidden = YES;
            containerView.hitImageViewTop.hidden = YES;
            containerView.additionalHitsLabel.hidden = YES;
        }
        else if (newValue == 1) {
            containerView.hitImageViewBottom.hidden = NO;
            containerView.hitImageViewBottom.tintColor = ASNYellowColor;
            
            containerView.hitImageViewMiddle.hidden = YES;
            containerView.hitImageViewTop.hidden = YES;
            containerView.additionalHitsLabel.hidden = YES;
            
        }
        else if (newValue == 2) {
            containerView.hitImageViewBottom.hidden = NO;
            
            containerView.hitImageViewMiddle.hidden = NO;
            containerView.hitImageViewMiddle.tintColor = ASNYellowColor;
            containerView.hitImageViewTop.hidden = YES;
            containerView.additionalHitsLabel.hidden = YES;

        }
        else if (newValue == 3) {
            containerView.hitImageViewBottom.hidden = NO;
            
            containerView.hitImageViewMiddle.hidden = NO;
            containerView.hitImageViewTop.hidden = NO;
            containerView.hitImageViewTop.tintColor = ASNYellowColor;
            
            containerView.additionalHitsLabel.hidden = YES;
        }
        else if (newValue > 3) {
            containerView.additionalHitsLabel.text =[NSString stringWithFormat:@"+%lu", newValue-3];
            
            containerView.hitImageViewBottom.hidden = NO;
            
            containerView.hitImageViewMiddle.hidden = NO;
            containerView.hitImageViewTop.hidden = NO;
            
            containerView.additionalHitsLabel.hidden = NO;
            containerView.additionalHitsLabel.textColor = ASNYellowColor;
            
        }
        else {
            NSLog(@"%@ has a problem", self.currentGame.currentTeam.teamName);
        }

    });
}

-(void)makeHitsImagesWhiteForTeam:(ASNTeam *)team {
    for (ASNHitsContainerViews *view in team.arrayOfNumberViews) {
        for (UIView *UIView in view.hitImageViewsArray) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIView.tintColor = ASNLightestColor;
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            view.additionalHitsLabel.textColor = ASNLightestColor;
        });
    }

}

-(void)updateTeamNameAndWins:(ASNTeam *)team {
    // team name and wins/loses
    UIFont *largerFont = [UIFont fontWithName:fontName size:22.0];
    NSDictionary *largerFontDict = [NSDictionary dictionaryWithObject: largerFont forKey:NSFontAttributeName];
    NSMutableAttributedString *firstLine = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", team.teamName] attributes: largerFontDict];
    UIFont *smallerFont = [UIFont fontWithName:fontName size:15.0];
    NSDictionary *smallerFontDict = [NSDictionary dictionaryWithObject:smallerFont forKey:NSFontAttributeName];
    NSMutableAttributedString *secondLine = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"W:%lu L:%lu", team.wins, team.loses] attributes:smallerFontDict];
    [firstLine appendAttributedString:secondLine];
//    teamNameLabel.attributedText = firstLine;
    
    
//    NSMutableString *teamNameAndScore = [[NSString stringWithFormat:@"%@\nScore: %lu",team.teamName, team.scoreOfCurrentRound] mutableCopy];
    NSUInteger indexOfTeam = [self.currentGame.teams indexOfObject:team];
    dispatch_async(dispatch_get_main_queue(), ^{
        ((UILabel *)self.teamNameLabelsArray[indexOfTeam]).attributedText = firstLine;
        ((UILabel *)self.teamNameLabelsArray[indexOfTeam]).adjustsFontSizeToFitWidth = YES;
        ((UILabel *)self.teamNameLabelsArray[indexOfTeam]).minimumScaleFactor = 0.5;
    });
}

-(void)enableTouchingForTeam:(ASNTeam *)team {
    // Enable touching for team's numbers
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
    
    // highlight teamTouchIndicator
    NSUInteger teamIndex = [self.currentGame.teams indexOfObject:team];
    for (UIView *view in self.teamTouchIndicatorArray) {
        NSUInteger viewIndex = [self.teamTouchIndicatorArray indexOfObject:view];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (viewIndex == teamIndex) {
                view.hidden = NO;
            }
            else {
                view.hidden = YES;
            }
        });
    }
}

// called when logTurn, rotates names of players
// TODO: this should ONLY rotate the players names, and it should be animated. The 'updateCurrentPlayerLabel' method should be enough to handle the hits of the current player
-(void)updatePlayerNamesLabelsOfPreviousTeam:(ASNTeam *)team{
    NSUInteger indexOfPlayer = [team.players indexOfObject:team.previousPlayer]+1;
    NSUInteger numberOfPlayersOnTeam = team.players.count;
    NSUInteger teamIndex = [self.currentGame.teams indexOfObject:team];

    for (NSUInteger i = 0; i <= numberOfPlayersOnTeam; i++) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (i < numberOfPlayersOnTeam) {
                ASNPlayer *currentPlayer = ((ASNPlayer *)team.players[(i+indexOfPlayer)%numberOfPlayersOnTeam]);
                ((UILabel *)self.playerNamesLabelsArray[teamIndex][i]).text = currentPlayer.name;
            }
            else {
                // for "Previous: " label
                NSDictionary *previousHits = ((ASNTurn *)[team.previousPlayer.turnsOfPlayer lastObject]).hits;
                NSString *playersPreviousRoundResults = @"";
                for (NSString *hit in previousHits) {
                    if ([previousHits[hit] integerValue] > 0) {
                        for (NSUInteger i = 0; i< [previousHits[hit] integerValue]; i++) {
                            playersPreviousRoundResults = [playersPreviousRoundResults stringByAppendingString:[NSString stringWithFormat:@"%@ ",hit]];
                        }
                    }
                }
                if (playersPreviousRoundResults.length == 0) {
                    playersPreviousRoundResults = @"None";
                }

                
                ((UILabel *)self.playerNamesLabelsArray[teamIndex][i]).text = [NSString stringWithFormat:@"Previous: \n%@", playersPreviousRoundResults];
            }
            
        });
    }
    
    [self enableTouchingForTeam:self.currentGame.currentTeam];

}

-(void)makeCurrentPlayerNameBig {
    
    // make all labels small
    for (NSArray *teamPlayerLabelArray in self.playerNamesLabelsArray) {
        for (UILabel *playerNameLabel in teamPlayerLabelArray) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([playerNameLabel.text hasPrefix:self.currentGame.currentPlayer.name]) {
                    // for current player
                    playerNameLabel.font = [UIFont fontWithName:fontNameBold size:16];
//                    playerNameLabel.font = [UIFont systemFontOfSize:16];
                    playerNameLabel.textColor = ASNLightestColor;
                    
                    
//                    [UIView animateWithDuration:0.25 animations:^{
//                        playerNameLabel.transform = CGAffineTransformScale(playerNameLabel.transform, 1.25, 1.25);
//                    }];

                }
                else {
                    // for all other players
                    [playerNameLabel labelWithMyStyleAndSizePriority:low];
//                    playerNameLabel.font = [UIFont systemFontOfSize:15];
                    playerNameLabel.textColor = ASNLightColor;
//                    playerNameLabel.transform = CGAffineTransformIdentity;
                    
                }
                
            });
        }
    }
//    // make current player's label bigger
//    NSUInteger teamIndex = [self.currentGame.teams indexOfObject:self.currentGame.currentTeam];
//    UILabel *playerLabel = ((UILabel *)self.playerNamesLabelsArray[teamIndex][0]);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        playerLabel.font = [UIFont systemFontOfSize:16];
//        playerLabel.textColor = ASNLightestColor;
//        [UIView animateWithDuration:0.25 animations:^{
//            playerLabel.transform = CGAffineTransformScale(playerLabel.transform, 1.25, 1.25);
//        }];
//    });
}

//-(void)updateCurrentPlayerLabel {
//    NSString *playersCurrentHits = @"";
//    for (NSString *hit in self.currentGame.currentPlayer.currentHits) {
//        if ([self.currentGame.currentPlayer.currentHits[hit] integerValue] > 0) {
//            for (NSUInteger i = 0; i< [self.currentGame.currentPlayer.currentHits[hit] integerValue]; i++) {
//                playersCurrentHits = [playersCurrentHits stringByAppendingString:[NSString stringWithFormat:@"%@ ",hit]];
//            }
//        }
//    }
//    NSUInteger teamIndex = [self.currentGame.teams indexOfObject:self.currentGame.currentTeam];
//    UILabel *playerLabel = ((UILabel *)self.playerNamesLabelsArray[teamIndex][0]);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        playerLabel.text = [NSString stringWithFormat:@"%@ : %@", self.currentGame.currentPlayer.name, playersCurrentHits];        
//    });
//}


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
//    [self updateCurrentPlayerLabel];
    [self updateImageOfImageView:associatedView withValue:newValueForKey];
    [self updateScoreOfTeam:self.currentGame.currentTeam];
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
    [self makeHitsImagesWhiteForTeam:self.currentGame.currentTeam];
    [self.currentGame logTurnOfCurrentPlayer];
    [self updatePlayerNamesLabelsOfPreviousTeam:self.currentGame.previousTeam];
    [self makeCurrentPlayerNameBig];
    [self enableTouchingForTeam:self.currentGame.currentTeam];
//    [self updateCurrentPlayerLabel];
}

-(void)handleNewGameButtonTapped:(id)sender {
    // present alert
    UIAlertController *newGameAlert = [UIAlertController alertControllerWithTitle:@"Restart Game" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self handleNewGameTappedAtEndOfGame];
        self.isAlertControllerPresented = NO;
    }];
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.isAlertControllerPresented = NO;
    }];
    
    [newGameAlert addAction:no];
    [newGameAlert addAction:yes];
//    [newGameAlert.view setNeedsLayout];
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
        [self refreshNumbersUIForTeam:team];
        [self updateScoreOfTeam:self.currentGame.currentTeam];
//        for (ASNHitsContainerViews *view in team.arrayOfNumberViews) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                view.tintColor = [UIColor clearColor];
//            });
//        }
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
        
    }

}



-(void)didReceiveDataNotification:(NSNotification *)notification {
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *receivedDataUnarchived = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
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
    else if ([receivedDataUnarchived isEqualToString:@"undo"]) {
        [self undoTurn];
    }
    else if ([receivedDataUnarchived isEqualToString:@"erase"]) {
        [self eraseCurrentHits];
    }
}

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification {
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
            NSLog(@"Connected to %@", peerDisplayName);
        }
        else if (state == MCSessionStateNotConnected){
            NSLog(@"Connection lost with %@", peerDisplayName);
            // TODO: alert user, reconnect
//            [self.appDelegate.mcManager.serviceBrowser invitePeer:peerID toSession:self.appDelegate.mcManager.session withContext:nil timeout:30];

        }
    }
}



# pragma mark -- DCPathButton Delegate

// Disable Buttons (undo and erase)
-(void)willPresentDCPathButtonItems:(DCPathButton *)dcPathButton {
    // Erase Button
    if ([self playerHasNoCurrentHits:self.currentGame.currentPlayer]) {
        // Disable Erase Button
        ((DCPathItemButton *)dcPathButton.itemButtons[2]).enabled = NO;
        ((DCPathItemButton *)dcPathButton.itemButtons[2]).tintColor = ASNDarkColor;
    }
    else {
        // Enable Erase Button
        ((DCPathItemButton *)dcPathButton.itemButtons[2]).enabled = YES;
        ((DCPathItemButton *)dcPathButton.itemButtons[2]).tintColor = ASNYellowColor;
    }
    
    // Undo button
    if (!self.currentGame.previousTeam) {
        // Disable Undo Button
        ((DCPathItemButton *)dcPathButton.itemButtons[1]).enabled = NO;
        ((DCPathItemButton *)dcPathButton.itemButtons[1]).tintColor = ASNDarkColor;
    }
    else {
        // Enable Undo Button
        ((DCPathItemButton *)dcPathButton.itemButtons[1]).enabled = YES;
        ((DCPathItemButton *)dcPathButton.itemButtons[1]).tintColor = ASNYellowColor;
    }
    
}

-(BOOL)playerHasNoCurrentHits:(ASNPlayer *)player {
    for (NSString *key in player.currentHits) {
        NSInteger numberOfHitsForKey = [player.currentHits[key] integerValue];
        if (numberOfHitsForKey > 0) {
            return NO;
        }
    }
    return YES;
}

- (void)pathButton:(DCPathButton *)dcPathButton clickItemButtonAtIndex:(NSUInteger)itemButtonIndex {
    
//    for (DCPathItemButton *itemButton in dcPathButton.itemButtons) {
//        itemButton.tintColor = ASNYellowColor;
//    }

    
    if (itemButtonIndex == 0) {
        [self handleNewGameButtonTapped:nil];
    }
    else if (itemButtonIndex == 1) {
        [self handleUndoPressed];
    }
    else if (itemButtonIndex == 2) {
        [self handleEraseTapped];
    }
    else if (itemButtonIndex == 3) {
        [self handleEndGameButtonTapped:nil];
    }
}

-(void)handleUndoPressed {
    // present alert
    UIAlertController *undoAlert = [UIAlertController alertControllerWithTitle:@"Undo?" message:[NSString stringWithFormat:@"Undo %@'s last turn? This will erase any current hits of %@)", self.currentGame.previousTeam.previousPlayer.name, self.currentGame.currentPlayer.name] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self undoTurn];
        [self sendToAllConnectedPeersString:@"undo"];
        self.isAlertControllerPresented = NO;
    }];
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.isAlertControllerPresented = NO;
    }];
    
    [undoAlert addAction:no];
    [undoAlert addAction:yes];
    [undoAlert.view setNeedsLayout];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:undoAlert animated:YES completion:nil];
        self.isAlertControllerPresented = YES;
    });
}


-(void)undoTurn {
    [self eraseCurrentHits];
    [self.currentGame undoPreviousTurn];
    
    [self updatePlayerNamesLabelsOfTeam:self.currentGame.currentTeam];
    [self updateTeamNameAndWins:self.currentGame.currentTeam];
    
    [self refreshNumbersUIForTeam:self.currentGame.currentTeam];
    [self updateScoreOfTeam:self.currentGame.currentTeam];
    [self makeHitsImagesWhiteForTeam:self.currentGame.currentTeam];
    
    [self makeCurrentPlayerNameBig];
    [self enableTouchingForTeam:self.currentGame.currentTeam];
}

-(void)handleEraseTapped {
    // present alert
    UIAlertController *eraseAlert = [UIAlertController alertControllerWithTitle:@"Erase?" message:[NSString stringWithFormat:@"Erase what's currently entered for %@", self.currentGame.currentPlayer.name] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self eraseCurrentHits];
        [self sendToAllConnectedPeersString:@"erase"];
        self.isAlertControllerPresented = NO;
    }];
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.isAlertControllerPresented = NO;
    }];
    
    [eraseAlert addAction:no];
    [eraseAlert addAction:yes];
    [eraseAlert.view setNeedsLayout];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:eraseAlert animated:YES completion:nil];
        self.isAlertControllerPresented = YES;
    });

}

-(void)eraseCurrentHits {
    // erase any progress of currentPlayer
    NSMutableDictionary *tempDictOfCurrentPlayerHits = [self.currentGame.currentPlayer.currentHits copy];
    for (NSString *key in tempDictOfCurrentPlayerHits) {
        NSInteger amountOfHits = [tempDictOfCurrentPlayerHits[key] integerValue];
        NSUInteger newValue;
        if ([tempDictOfCurrentPlayerHits[key] integerValue] - amountOfHits < 0) {
            newValue = 0;
        }
        else {
            newValue = ([self.currentGame.currentTeam.hitsInCurrentRound[key] integerValue] - amountOfHits);
        }
        
        self.currentGame.currentTeam.hitsInCurrentRound[key] = [NSString stringWithFormat:@"%li", newValue];
    }

    [self.currentGame.currentPlayer setupPlayerForRound];
    [self refreshNumbersUIForTeam:self.currentGame.currentTeam];
    [self makeHitsImagesWhiteForTeam:self.currentGame.currentTeam];
    [self updateScoreOfTeam:self.currentGame.currentTeam];

}

-(void)refreshNumbersUIForTeam:(ASNTeam *)team {
    // update current teams hits images
    for (NSUInteger j = 20; j>=14; j--) {
        NSString *teamValueForKey = [NSString new];
        if (j == 14) {
            teamValueForKey = team.hitsInCurrentRound[@"Bull"];
        }
        else {
            teamValueForKey = team.hitsInCurrentRound[[NSString stringWithFormat:@"%lu", j]];
            if ([teamValueForKey integerValue]<0) {
                NSLog(@"the key is %lu and the amount it %@", j, teamValueForKey);

            }
        }
        ASNHitsContainerViews *view = team.arrayOfNumberViews[20-j];
        
        [self updateImageOfImageView:view withValue:[teamValueForKey integerValue]];
    }
}
-(void)updatePlayerNamesLabelsOfTeam:(ASNTeam *)team{
    NSUInteger indexOfPlayer = [team.players indexOfObject:team.previousPlayer];
    NSUInteger numberOfPlayersOnTeam = team.players.count;
    NSUInteger teamIndex = [self.currentGame.teams indexOfObject:team];
    
    for (NSUInteger i = 0; i <= numberOfPlayersOnTeam; i++) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (i < numberOfPlayersOnTeam) {
                ASNPlayer *currentPlayer = ((ASNPlayer *)team.players[(i+indexOfPlayer)%numberOfPlayersOnTeam]);
                ((UILabel *)self.playerNamesLabelsArray[teamIndex][i]).text = currentPlayer.name;
            }
            else {
                // for "Previous: " label
                NSDictionary *previousHits = ((ASNTurn *)[team.previousPlayer.turnsOfPlayer lastObject]).hits;
                NSString *playersPreviousRoundResults = @"";
                for (NSString *hit in previousHits) {
                    if ([previousHits[hit] integerValue] > 0) {
                        for (NSUInteger i = 0; i< [previousHits[hit] integerValue]; i++) {
                            playersPreviousRoundResults = [playersPreviousRoundResults stringByAppendingString:[NSString stringWithFormat:@"%@ ",hit]];
                        }
                    }
                }
                if (playersPreviousRoundResults.length == 0) {
                    playersPreviousRoundResults = @"None";
                }
                
                
                ((UILabel *)self.playerNamesLabelsArray[teamIndex][i]).text = [NSString stringWithFormat:@"Previous: \n%@", playersPreviousRoundResults];
            }
            
        });
    }
    
    [self enableTouchingForTeam:self.currentGame.currentTeam];
    
}

@end
