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

+(id) nodeWithGameType:(int)gametype {
 return  [[[self alloc] initWithGameType:gametype] autorelease];
}

-(id) initWithGameType:(int)gametype
{
	if( (self=[super init]) ) {
    _GameType = gametype;
    self.isTouchEnabled = YES;
    CGSize size = [[CCDirector sharedDirector] winSize];

    ScoreLabel = [CCLabelTTF labelWithString:@"0"
                                  dimensions:CGSizeMake(size.width/2, 30) hAlignment:kCCTextAlignmentRight
                                    fontName:@"Marker Felt" fontSize:18 ];
    ScoreLabel.anchorPoint = ccp(1, 0.5f); // 우측 중간을 앵커로 //좌하(0, 0), 우상(1, 1)
    ScoreLabel.position =  ccp( (size.width - 30), (size.height - 30) ); // 가능하면 위쪽 꼭데기. 정렬이 가운데겠지만
    [self addChild:ScoreLabel];
    
    [self performSelector:@selector(finishLoading) withObject:nil afterDelay:1.0f];
	}
	return self;
}

-(void) finishLoading {
  GG = [[ggObject alloc] initWithCCLayer:self];
  [GG loadDefaultConfiguration]; // issue#5, #17 관련
  CCLOG(@"finishing init: game as _GameType:%d", _GameType);
  if (_GameType != 0) {
    [GG setConfig:@"GemGemGameType" value:[NSNumber numberWithInt:_GameType]]; // 1,2,3 이런식으로는 명확치 않음 -_- TODO
  }
  
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

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  
  NSArray* allTouches = [[event allTouches] allObjects];
  
  if ([allTouches count] == 1)
  {
    UITouch *touch = [touches anyObject];
    CGPoint touchedlocation = [[CCDirector sharedDirector] convertToGL: [touch locationInView:touch.view]];
    
    [GG touchesEnded:touchedlocation];
  }
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
  // Game Over
  //
  
  [CCMenuItemFont setFontSize:20];
  CCMenu *menu;
  
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
