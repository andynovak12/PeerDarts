//
//  ASNCreateTeamView.m
//  DartsObjC
//
//  Created by Andy Novak on 5/17/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import "ASNCreateTeamView.h"

@implementation ASNCreateTeamView


-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [ super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [ super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit {
    [[NSBundle mainBundle] loadNibNamed:@"TeamForCreateGame" owner:self options:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addSubview:self.contentView];
        [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        [self.contentView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
        [self.contentView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
        self.contentView.userInteractionEnabled = YES;
        self.teamNameTextField.userInteractionEnabled = YES;
        
        self.p1Label.hidden = YES;
        self.p2Label.hidden = YES;
        self.p3Label.hidden = YES;
        self.p4Label.hidden = YES;
        self.p2AddButton.hidden = YES;
        self.p3AddButton.hidden = YES;
        self.p4AddButton.hidden = YES;
    });
    self.teamNameTextField.delegate = self;
}

-(void)setTeam:(ASNTeam *)team {
    _team = team;
    [self updateUI];
}


-(void)updateUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.teamNameTextField.text = self.team.teamName;
        if (self.team.players.count > 0) {
            self.p1Label.hidden = NO;
            self.p1Label.text = ((ASNPlayer *)self.team.players[0]).name;
            self.p1Label.minimumScaleFactor = 8./self.p1Label.font.pointSize;
            self.p1Label.adjustsFontSizeToFitWidth = YES;
            self.p1AddButton.hidden = YES;
            self.p2AddButton.hidden = NO;
        }
        if (self.team.players.count > 1) {
            self.p2Label.text = ((ASNPlayer *)self.team.players[1]).name;
            self.p2Label.hidden = NO;
            self.p2Label.minimumScaleFactor = 8./self.p2Label.font.pointSize;
            self.p2Label.adjustsFontSizeToFitWidth = YES;
            self.p2AddButton.hidden = YES;
            self.p3AddButton.hidden = NO;
        }
        if (self.team.players.count > 2) {
            self.p3Label.text = ((ASNPlayer *)self.team.players[2]).name;
            self.p3Label.hidden = NO;
            self.p3Label.minimumScaleFactor = 8./self.p3Label.font.pointSize;
            self.p3Label.adjustsFontSizeToFitWidth = YES;
            self.p3AddButton.hidden = YES;
            self.p4AddButton.hidden = NO;
        }
        if (self.team.players.count > 3) {
            self.p4Label.text = ((ASNPlayer *)self.team.players[3]).name;
            self.p4Label.hidden = NO;
            self.p4Label.minimumScaleFactor = 8./self.p4Label.font.pointSize;
            self.p4Label.adjustsFontSizeToFitWidth = YES;
            self.p4AddButton.hidden = YES;
        }
    });
}

- (IBAction)p1AddButtonTapped:(id)sender {
    [self.delegate addPlayerButtonTappedInView:self];
}
- (IBAction)p2AddButtonTapped:(id)sender {
    [self.delegate addPlayerButtonTappedInView:self];
}
- (IBAction)p3AddButtonTapped:(id)sender {
    [self.delegate addPlayerButtonTappedInView:self];
}
- (IBAction)p4AddButtonTapped:(id)sender {
    [self.delegate addPlayerButtonTappedInView:self];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    self.team.teamName = textField.text;
    [textField resignFirstResponder];
    [self.delegate teamNameEntered:textField];
    return YES;
}


@end
