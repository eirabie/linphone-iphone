/* UICallBar.m
 *
 * Copyright (C) 2012  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or   
 *  (at your option) any later version.                                 
 *                                                                      
 *  This program is distributed in the hope that it will be useful,     
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of      
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the       
 *  GNU Library General Public License for more details.                
 *                                                                      
 *  You should have received a copy of the GNU General Public License   
 *  along with this program; if not, write to the Free Software         
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */ 

#import "UICallBar.h"
#import "LinphoneManager.h"
#import "PhoneMainView.h"

#import "CPAnimationSequence.h"
#import "CPAnimationStep.h"

#include "linphonecore.h"
#include "private.h"

@implementation UICallBar

@synthesize pauseButton;
@synthesize conferenceButton;
@synthesize videoButton;
@synthesize microButton;
@synthesize speakerButton;  
@synthesize optionsButton;
@synthesize hangupButton;

@synthesize optionsAddButton;
@synthesize optionsTransferButton;

@synthesize padView;
@synthesize optionsView;

@synthesize oneButton;
@synthesize twoButton;
@synthesize threeButton;
@synthesize fourButton;
@synthesize fiveButton;
@synthesize sixButton;
@synthesize sevenButton;
@synthesize eightButton;
@synthesize nineButton;
@synthesize starButton;
@synthesize zeroButton;
@synthesize sharpButton;


#pragma mark - Lifecycle Functions

- (id)init {
    return [super initWithNibName:@"UICallBar" bundle:[NSBundle mainBundle]];
}

- (void)dealloc {
    [pauseButton release];
    [conferenceButton release];
    [videoButton release];
    [microButton release];
    [speakerButton release]; 
    [optionsButton release];
    
    [optionsAddButton release];
    [optionsTransferButton release];
    
    [oneButton release];
	[twoButton release];
	[threeButton release];
	[fourButton release];
	[fiveButton release];
	[sixButton release];
	[sevenButton release];
	[eightButton release];
	[nineButton release];
	[starButton release];
	[zeroButton release];
	[sharpButton release];
    
    [padView release];
    [optionsView release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}


#pragma mark - ViewController Functions

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [pauseButton setType:UIPauseButtonType_CurrentCall call:nil];
    
    [zeroButton setDigit:'0'];
    [zeroButton setDtmf:true];
	[oneButton    setDigit:'1'];
    [oneButton setDtmf:true];
	[twoButton    setDigit:'2'];
    [twoButton setDtmf:true];
	[threeButton  setDigit:'3'];
    [threeButton setDtmf:true];
	[fourButton   setDigit:'4'];
    [fourButton setDtmf:true];
	[fiveButton   setDigit:'5'];
    [fiveButton setDtmf:true];
	[sixButton    setDigit:'6'];
    [sixButton setDtmf:true];
	[sevenButton  setDigit:'7'];
    [sevenButton setDtmf:true];
	[eightButton  setDigit:'8'];
    [eightButton setDtmf:true];
	[nineButton   setDigit:'9'];
    [nineButton setDtmf:true];
	[starButton   setDigit:'*'];
    [starButton setDtmf:true];
	[sharpButton  setDigit:'#'];
    [sharpButton setDtmf:true];
    
    // Set selected+disabled background: IB lack !
    [videoButton setImage:[UIImage imageNamed:@"video_on_disabled.png"] 
                           forState:(UIControlStateDisabled | UIControlStateSelected)];
    // Set selected+over background: IB lack !
    [videoButton setImage:[UIImage imageNamed:@"video_on_over.png"] 
                           forState:(UIControlStateHighlighted | UIControlStateSelected)];
    
    // Set selected+disabled background: IB lack !
    [speakerButton setImage:[UIImage imageNamed:@"speaker_on_disabled.png"] 
                 forState:(UIControlStateDisabled | UIControlStateSelected)];
    // Set selected+over background: IB lack !
    [speakerButton setImage:[UIImage imageNamed:@"speaker_on_over.png"] 
                 forState:(UIControlStateHighlighted | UIControlStateSelected)];
    
    // Set selected+disabled background: IB lack !
    [microButton setImage:[UIImage imageNamed:@"micro_on_disabled.png"] 
                   forState:(UIControlStateDisabled | UIControlStateSelected)];
    // Set selected+over background: IB lack !
    [microButton setImage:[UIImage imageNamed:@"micro_on_over.png"] 
                   forState:(UIControlStateHighlighted | UIControlStateSelected)];
    
    // Set selected+over background: IB lack !
    [pauseButton setImage:[UIImage imageNamed:@"pause_on_over.png"] 
                 forState:(UIControlStateHighlighted | UIControlStateSelected)];
    
    // Set selected+over background: IB lack !
    [optionsButton setImage:[UIImage imageNamed:@"options_over.png"] 
                 forState:(UIControlStateHighlighted | UIControlStateSelected)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(callUpdateEvent:) 
                                                 name:@"LinphoneCallUpdate" 
                                               object:nil];
    // Update on show
    LinphoneCall* call = linphone_core_get_current_call([LinphoneManager getLc]);
    LinphoneCallState state = (call != NULL)?linphone_call_get_state(call): 0;
    [self callUpdate:call state:state];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:@"LinphoneCallUpdate" 
                                                  object:nil];
}

#pragma mark - Event Functions

- (void)callUpdateEvent:(NSNotification*)notif {
    LinphoneCall *call = [[notif.userInfo objectForKey: @"call"] pointerValue];
    LinphoneCallState state = [[notif.userInfo objectForKey: @"state"] intValue];
    [self callUpdate:call state:state];
}


#pragma mark - 

- (void)callUpdate:(LinphoneCall*)call state:(LinphoneCallState)state {  
    LinphoneCore* lc = [LinphoneManager getLc]; 

    [speakerButton update];
    [microButton update];
    [pauseButton update];
    [videoButton update];
    [hangupButton update];
    
    
    // Show Pause/Conference button following call count
    if(linphone_core_get_calls_nb(lc) > 1) {
        if(![pauseButton isHidden]) {
            [pauseButton setHidden:true];
            [conferenceButton setHidden:false];
        }
    } else {
        if([pauseButton isHidden]) {
            [pauseButton setHidden:false];
            [conferenceButton setHidden:true];
        }
    }
    
    // Disable menu when no call & no conference
    if(linphone_core_get_current_call(lc) == NULL && linphone_core_is_in_conference(lc) == FALSE) {
        [self hidePad];
        [self hideOptions];
        [optionsButton setEnabled:FALSE];
    } else {
        [optionsButton setEnabled:TRUE];
    }

    // Disable transfert in conference
    if(linphone_core_is_in_conference(lc)) {
        [optionsTransferButton setEnabled:FALSE];
    } else {
        [optionsTransferButton setEnabled:TRUE];
    }
    
    switch(state) {
        LinphoneCallEnd:
        LinphoneCallError:
        LinphoneCallIncoming:
        LinphoneCallOutgoing:
            [self hidePad];
            [self hideOptions];
        default:
            break;
    }
}


#pragma mark -  

- (void)showPad{
    if([padView isHidden]) {
        CGRect frame = [padView frame];
        int original_y = frame.origin.y;
        frame.origin.y = [[self view] frame].size.height;
        [padView setFrame:frame];
        [padView setHidden:FALSE];
        CPAnimationSequence* move = [[CPAnimationSequence sequenceWithSteps:
                                     [[CPAnimationStep after:0.0 
                                                         for:0.5
                                                     options:UIViewAnimationOptionCurveEaseOut
                                                     animate:^{ 
            CGRect frame = [padView frame];
            frame.origin.y = original_y;
            [padView setFrame:frame]; 
        }] autorelease],
                                     nil
                                     ] autorelease];
        [move run];
    }
}

- (void)hidePad{
    if(![padView isHidden]) {
        CGRect frame = [padView frame];
        int original_y = frame.origin.y;
    
        CPAnimationSequence* move = [[CPAnimationSequence sequenceWithSteps:
                                      [[CPAnimationStep after:0.0 
                                                          for:0.5
                                                      options:UIViewAnimationOptionCurveEaseIn
                                                      animate:^{ 
            CGRect frame = [padView frame];
            frame.origin.y = [[self view] frame].size.height;
            [padView setFrame:frame]; 
        }] autorelease],
                                     [[CPAnimationStep after:0.0 
                                                     animate:^{ 
            CGRect frame = [padView frame];
            frame.origin.y = original_y;
            [padView setHidden:TRUE];
            [padView setFrame:frame]; 
        }] autorelease], 
                                     nil
                                     ] autorelease];
    [move run];
    }
}

- (void)showOptions{
    [optionsButton setEnabled:TRUE];
    if([optionsView isHidden]) {
        CGRect frame = [optionsView frame];
        int original_y = frame.origin.y;
        frame.origin.y = [[self view] frame].size.height;
        [optionsView setFrame:frame];
        [optionsView setHidden:FALSE];
        CPAnimationSequence* move = [[CPAnimationSequence sequenceWithSteps:
                                      [[CPAnimationStep after:0.0
                                                          for:0.5 
                                                      options:UIViewAnimationOptionCurveEaseOut
                                                      animate:^{ 
            CGRect frame = [optionsView frame];
            frame.origin.y = original_y;
            [optionsView setFrame:frame]; 
        }] autorelease],
                                      nil
                                      ] autorelease];
        [move run];
    }
}

- (void)hideOptions{
    [optionsButton setEnabled:FALSE];
    if(![optionsView isHidden]) {
        CGRect frame = [optionsView frame];
        int original_y = frame.origin.y;
        
        CPAnimationSequence* move = [[CPAnimationSequence sequenceWithSteps:
                                      [[CPAnimationStep after:0.0
                                                          for:0.5
                                                      options:UIViewAnimationOptionCurveEaseIn
                                                      animate:^{ 
            CGRect frame = [optionsView frame];
            frame.origin.y = [[self view] frame].size.height;
            [optionsView setFrame:frame]; 
        }] autorelease],
                                      [[CPAnimationStep after:0.0 
                                                      animate:^{ 
            CGRect frame = [optionsView frame];
            frame.origin.y = original_y;
            [optionsView setHidden:TRUE];
            [optionsView setFrame:frame]; 
        }] autorelease], 
                                      nil
                                      ] autorelease];
        [move run];
    }
}


#pragma mark - Action Functions

- (IBAction)onPadClick:(id)sender {
    if([padView isHidden]) {
        [self showPad];
    } else {
        [self hidePad];
    }
}

- (IBAction)onOptionsTransferClick:(id)sender {
    [self hideOptions];
    // Go to dialer view
    NSDictionary *dict = [[[NSDictionary alloc] initWithObjectsAndKeys:
                           [[[NSArray alloc] initWithObjects: @"", nil] autorelease]
                           , @"setAddress:",
                           [[[NSArray alloc] initWithObjects: [NSNumber numberWithInt: TRUE], nil] autorelease]
                           , @"setTransferMode:",
                           nil] autorelease];
    [[PhoneMainView instance] changeView:PhoneView_Dialer dict:dict];
}

- (IBAction)onOptionsAddClick:(id)sender {
    [self hideOptions];
    // Go to dialer view
    NSDictionary *dict = [[[NSDictionary alloc] initWithObjectsAndKeys:
                           [[[NSArray alloc] initWithObjects: @"", nil] autorelease]
                           , @"setAddress:",
                           [[[NSArray alloc] initWithObjects: [NSNumber numberWithInt: FALSE], nil] autorelease]
                           , @"setTransferMode:",
                           nil] autorelease];
    [[PhoneMainView instance] changeView:PhoneView_Dialer dict:dict];
}

- (IBAction)onOptionsClick:(id)sender {
    if([optionsView isHidden]) {
        [self showOptions];
    } else {
        [self hideOptions];
    }
}

- (IBAction)onConferenceClick:(id)sender {
    linphone_core_add_all_to_conference([LinphoneManager getLc]);
}

@end
