//
//  HelloWorldLayer.h
//  gemgem
//
//  Created by Yong-uk Choe on 12. 11. 24..
//  Copyright __MyCompanyName__ 2012년. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "ggObject.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
  ggObject *GG;
  CCLabelTTF *ScoreLabel;
  int   _GameType;
  CCSprite            *pauseButtonSprite;
  BOOL _isGamePaused;
  NSMutableArray *overLayerObjects;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
+(id) nodeWithGameType:(int)gametype;

@end
