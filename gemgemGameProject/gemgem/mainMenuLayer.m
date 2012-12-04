//
//  mainMenuLayer.m
//  gemgem
//
//  Created by Yong-uk Choe on 12. 11. 30..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import "mainMenuLayer.h"
#import "AppDelegate.h"

#import "HelloWorldLayer.h"
#import "optionsLayer.h"
#import "creditsLayer.h"

@implementation mainMenuLayer

#pragma mark - mainMenuLayer

+(CCScene *) scene {
  CCScene *scene = [CCScene node];
  mainMenuLayer *layer = [mainMenuLayer node];
  [scene addChild: layer];
  
  return scene;
}

-(id)init {
  if( (self=[super init])) {
    self.isTouchEnabled = YES; // 글로벌 터치 인식
    CGSize size = [[CCDirector sharedDirector] winSize];

    // LOGO
    CCSprite *logo = [CCSprite spriteWithFile:@"logo.png"];
    float rate = size.width / logo.contentSize.width;
    logo.scaleX = rate;
    logo.scaleY = rate;
    logo.position = ccp(size.width/2, size.height - ([logo boundingBox].size.height /2) - 25);
    [self addChild:logo];
    
    //MENU
    [CCMenuItemFont setFontSize:24];
    CCMenu *menu;
    
    CCMenuItem *itemChallenge = [CCMenuItemFont itemWithString:@"Challenge mode" block:^(id sender){
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[HelloWorldLayer scene] withColor:ccWHITE]];
    }
                              ];

    CCMenuItem *itemInfinity = [CCMenuItemFont itemWithString:@"Infinity mode" block:^(id sender){
      [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[HelloWorldLayer scene] withColor:ccWHITE]];
    }
                              ];
    
    CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
      GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
      achivementViewController.achievementDelegate = self;
      AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
      [[app navController] presentModalViewController:achivementViewController animated:YES];
      [achivementViewController release];
    }
                                   ];
    
    // Leaderboard Menu Item using blocks
    CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
      GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
      leaderboardViewController.leaderboardDelegate = self;
      AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
      [[app navController] presentModalViewController:leaderboardViewController animated:YES];
      [leaderboardViewController release];
    }
                                   ];
    
    CCMenuItem *itemCredits = [CCMenuItemFont itemWithString:@"Credits" block:^(id sender){
      [[CCDirector sharedDirector] replaceScene:
       [CCTransitionFade transitionWithDuration:1.0
                                          scene:[creditsLayer scene] withColor:ccWHITE]
       ];
    }
                                ];

    CCMenuItem *itemOptions = [CCMenuItemFont itemWithString:@"Options" block:^(id sender){
      [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[optionsLayer scene] withColor:ccWHITE]];
    }
                                ];

    
    menu = [CCMenu menuWithItems:itemChallenge, itemInfinity, itemOptions, itemAchievement, itemLeaderboard, itemCredits, nil];
    
    //[menu alignItemsHorizontallyWithPadding:20];
    [menu alignItemsVerticallyWithPadding:10];
    
    [menu setPosition:ccp( size.width/2, size.height/2 - 105)];
    
    // Add the menu to the layer
    [self addChild:menu z:99];
    
  }
  return self;
}

- (void) dealloc {	[super dealloc]; }

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

@end
