//
//  mainMenuLayer.h
//  gemgem
//
//  Created by Yong-uk Choe on 12. 11. 30..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "cocos2d.h"

#import "GADBannerView.h"

@interface mainMenuLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate> {
  GADBannerView *mBannerView;
}

+(CCScene *) scene;

@end
