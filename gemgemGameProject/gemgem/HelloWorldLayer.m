//
//  HelloWorldLayer.m
//  gemgem
//
//  Created by Yong-uk Choe on 12. 11. 24..
//  Copyright noizze.net 2012년. All rights reserved.
//


#import "HelloWorldLayer.h"
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

@implementation HelloWorldLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if( (self=[super init]) ) {
    self.isTouchEnabled = YES;
    
    ScoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:18];
    ScoreLabel.position =  ccp( 80 , 455 ); // 가능하면 위쪽 꼭데기. 정렬이 가운데겠지만
    [self addChild:ScoreLabel];
    
    [self performSelector:@selector(finishLoading) withObject:nil afterDelay:1.0f];
	}
	return self;
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  
  NSArray* allTouches = [[event allTouches] allObjects];
  
  if ([allTouches count] == 1)
  {
    UITouch *touch = [touches anyObject];
    CGPoint touchedlocation = [[CCDirector sharedDirector] convertToGL: [touch locationInView:touch.view]];
    
    [GG touchesEnded:touchedlocation];
  }
}

-(void) finishLoading {
  GG = [[ggObject alloc] initWithCCLayer:self];
  [GG loadDefaultConfiguration];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(scoreUpdator:)
                                               name:GG_NOTIFICATION_SCORE_UPDATE
                                             object:GG];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(show_GameOver:)
                                               name:GG_NOTIFICATION_GAME_OVER
                                             object:GG];

  [GG run];
}

-(void) show_GameOver:(NSNotification *)notification {
  self.isTouchEnabled = NO;
  CGSize size = [[CCDirector sharedDirector] winSize];

  CCSprite *shadow = [CCSprite spriteWithFile:@"shadow.png"];
  shadow.scaleX = size.width / shadow.contentSize.width;
  shadow.scaleY = size.height / shadow.contentSize.height;
  shadow.position = ccp(size.width/2, size.height/2);
  [self addChild:shadow z:98];
  
  CCLabelTTF *label = [CCLabelTTF labelWithString:@"GAME OVER" fontName:@"Marker Felt" fontSize:64];
  label.color = ccRED;
  label.position =  ccp( size.width /2 , size.height/2 );
  [self addChild: label z:99];
  
  //
  // Leaderboards and Achievements
  //
  
  [CCMenuItemFont setFontSize:20];
  CCMenu *menu;
  
  // Achievement Menu Item using blocks
  /*
  CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
    GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
    achivementViewController.achievementDelegate = self;
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    [[app navController] presentModalViewController:achivementViewController animated:YES];
    [achivementViewController release];
  }
                                 ];
  */
  
  CCMenuItem *itemReplay = [CCMenuItemFont itemWithString:@"Replay" block:^(id sender){
    //[[CCDirector sharedDirector] replaceScene:[CCTransitionMoveInR transitionWithDuration:0.5f scene:[HelloWorldLayer scene]]];
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
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
  
  menu = [CCMenu menuWithItems:itemReplay, itemLeaderboard, nil];
  
  [menu alignItemsHorizontallyWithPadding:20];
  [menu setPosition:ccp( size.width/2, size.height/2 - 50)];
  
  // Add the menu to the layer
  [self addChild:menu z:99];
}

-(void) scoreUpdator:(NSNotification *)notification {
  NSDictionary *score = [notification userInfo];
  //CCLOG(@"Score!:%d", [(NSNumber*)[score objectForKey:@"score"] intValue]);
  ScoreLabel.string = [NSString stringWithFormat:@"%0d", [(NSNumber*)[score objectForKey:@"score"] intValue]];
 
  
  
  CCLabelTTF *mLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%0d", [(NSNumber*)[score objectForKey:@"margin"] intValue]]
                                          fontName:@"Marker Felt" fontSize:20];
  //mLabel.position =  ccp( 80 , 450 );
  mLabel.position = [(NSValue*)[score objectForKey:@"point"] CGPointValue];
  //CCLOG(@"miniLabel(%.f,%.f)", mLabel.position.x, mLabel.position.y);
  [self addChild:mLabel z:999];
  [mLabel runAction:[CCSequence actions:[CCMoveBy actionWithDuration:0.5f position:ccp(0,16)],
                     [CCDelayTime actionWithDuration:0.1f],
                     [CCCallBlock actionWithBlock:^{ [self removeChild:mLabel cleanup:YES]; }],
                     nil]
   ];

}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	CCLOG(@"dealloc: quit");
	// don't forget to call "super dealloc"
	[super dealloc];
}

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
