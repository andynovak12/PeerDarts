//
//  ASNCreateTeamView.h
//  DartsObjC
//
//  Created by Andy Novak on 5/17/16.
//  Copyright © 2016 Andy Novak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASNTeam.h"


@class ASNCreateTeamView;
@protocol ASNCreateTeamViewDelegate <NSObject>

-(void)addPlayerButtonTappedInView:(UIView *)view;
-(void)teamNameEntered:(UITextField *)textField;
@end

@interface ASNCreateTeamView : UIView <UITextFieldDelegate, UITextViewDelegate>

@property(nonatomic,weak)id <ASNCreateTeamViewDelegate> delegate;

@property (strong, nonatomic) ASNTeam *team;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UITextField *teamNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *p1Label;
@property (weak, nonatomic) IBOutlet UILabel *p2Label;
@property (weak, nonatomic) IBOutlet UILabel *p3Label;
@property (weak, nonatomic) IBOutlet UILabel *p4Label;
@property (weak, nonatomic) IBOutlet UIButton *p1AddButton;
@property (weak, nonatomic) IBOutlet UIButton *p2AddButton;
@property (weak, nonatomic) IBOutlet UIButton *p3AddButton;
@property (weak, nonatomic) IBOutlet UIButton *p4AddButton;

-(void)updateUI;

@end
