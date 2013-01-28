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

-(void)onEnter
{
  [super onEnter];
  
  [self createAdmobAds];
  
}

-(void)createAdmobAds
{
  AppController *app =  (AppController*)[[UIApplication sharedApplication] delegate];
  // Create a view of the standard size at the bottom of the screen.
  // Available AdSize constants are explained in GADAdSize.h.
  mBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
  
  // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
  mBannerView.adUnitID = @"a150b5843cd3bf3";
  
  // Let the runtime know which UIViewController to restore after taking
  // the user wherever the ad goes and add it to the view hierarchy.
  
  mBannerView.rootViewController = app.navController;
  [app.navController.view addSubview:mBannerView];
  
  // Initiate a generic request to load it with an ad.
  [mBannerView loadRequest:[GADRequest request]];
  
  CGSize s = [[CCDirector sharedDirector] winSize];
  
  CGRect frame = mBannerView.frame;
  frame.origin.y = s.height;
  frame.origin.x = (s.width/2.0f - frame.size.width/2.0f);
  
  mBannerView.frame = frame;
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.5];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
  
  frame = mBannerView.frame;
  frame.origin.y = s.height - frame.size.height;
  frame.origin.x = (s.width/2.0f - frame.size.width/2.0f);

  // modified : issue #30
  frame.size.width = s.width;
  //frame.size.height =
  frame.origin.x = s.width / 2;
  frame.origin.y = frame.size.height / 2;
  
  mBannerView.frame = frame;
  
  //CCLOG(@"s: w,h = %.0f,%.0f", s.width, s.height);
  CGRect rect2 = (CGRect)mBannerView.frame;
  CCLOG(@"rect2: x,y,w,h = %.0f,%.0f,%.0f,%.0f",rect2.origin.x, rect2.origin.y,rect2.size.width,rect2.size.height);
  
  [UIView commitAnimations];  
}

-(void)showBannerView
{
  CCLOG(@"show");
  if (mBannerView)
  {
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseOut
                     animations:^
     {
       CGSize s = [[CCDirector sharedDirector] winSize];
       
       CGRect frame = mBannerView.frame;
       frame.origin.y = s.height - frame.size.height;
       frame.origin.x = (s.width/2.0f - frame.size.width/2.0f);
       
       mBannerView.frame = frame;
     }
                     completion:^(BOOL finished)
     {
     }];
  }
  
}


-(void)hideBannerView
{
  if (mBannerView)
  {
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseOut
                     animations:^
     {
       CGSize s = [[CCDirector sharedDirector] winSize];
       
       CGRect frame = mBannerView.frame;
       frame.origin.y = frame.origin.y +  frame.size.height;
       frame.origin.x = (s.width/2.0f - frame.size.width/2.0f);
     }
                     completion:^(BOOL finished)
     {
     }];
  }
  
}


-(void)dismissAdView
{
  if (mBannerView)
  {
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseOut
                     animations:^
     {
       CGSize s = [[CCDirector sharedDirector] winSize];
       
       CGRect frame = mBannerView.frame;
       frame.origin.y = frame.origin.y + frame.size.height ;
       frame.origin.x = (s.width/2.0f - frame.size.width/2.0f);
       mBannerView.frame = frame;
     }
                     completion:^(BOOL finished)
     {
       [mBannerView setDelegate:nil];
       [mBannerView removeFromSuperview];
       mBannerView = nil;
       
     }];
  }
  
}




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

    CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 128)];
    [self addChild:colorLayer z:0];
    
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
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                     scene:[HelloWorldLayer nodeWithGameType:1]
                                                                                 withColor:ccWHITE]];
    }
                              ];

    CCMenuItem *itemInfinity = [CCMenuItemFont itemWithString:@"Infinity mode" block:^(id sender){
      [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[HelloWorldLayer nodeWithGameType:2] withColor:ccWHITE]];
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

    //[self performSelector:@selector(requestBannerAd) withObject:nil afterDelay:1.0f];
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
