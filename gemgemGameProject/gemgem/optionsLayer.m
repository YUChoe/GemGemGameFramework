//
//  optionsLayer.m
//  gemgem
//
//  Created by Yong-uk Choe on 12. 11. 30..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import "optionsLayer.h"
#import "mainMenuLayer.h"

@implementation optionsLayer

+(CCScene *) scene {
  CCScene *scene = [CCScene node];
  optionsLayer *layer = [optionsLayer node];
  [scene addChild: layer];
  
  return scene;
}

-(void) readConfigFromDataplist {
  NSMutableString *message = [NSMutableString string];
  
  NSDictionary *confDict = [[NSBundle mainBundle] infoDictionary];
  NSLog(@"infoDict, count = %d", [[confDict allKeys] count]);
  /*
  for (NSString *key in [confDict allKeys]) {
    CCLOG(@"confDict[%@]", key);
  }
  */
  //[confDict objectForKey:@"isBackgroundMusicON"];
  
}

-(void) saveConfigToDataplist {
  
}

-(id)init {
  if( (self=[super init])) {
    self.isTouchEnabled = YES; // 글로벌 터치 인식
    
    // init as NO
    _isBackgroundMusicON = NO;
    _isEffectSoundON = NO;

    CGSize size = [[CCDirector sharedDirector] winSize];
    
    // header
    CCLabelTTF *header = [CCLabelTTF labelWithString:@"OPTIONS" fontName:@"Marker Felt" fontSize:36];
    header.position =  ccp(size.width/2, size.height - 50);
    [self addChild:header z:999];

    // init config data file path of data.plist
    //plist_path = [[NSBundle mainBundle] pathForResource:@"GemConfig" ofType:@"plist"];
    //plist_path = [[NSBundle bundleForClass:[self class]] pathForResource:@"GemConfig" ofType:@"plist"];
    //plist_path = (NSString *)[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"GemConfig.plist"];
    //CCLOG(@"GemConfig.plist:%@", plist_path);
    [self readConfigFromDataplist];
    CCLOG(@"_isBackgroundMusicON:%@", (_isBackgroundMusicON)?@"YES":@"NO");
    CCLOG(@"_isEffectSoungON:%@", (_isEffectSoundON)?@"YES":@"NO");
    
    // ON/OFF menu
    CCMenuItemFont *bgToggleItem = [CCMenuItemFont itemWithString:(_isBackgroundMusicON)?@"Backgound Music : ON":@"Backgound Music : OFF" block:^(id sender){
      _isBackgroundMusicON = !_isBackgroundMusicON;
      CCLOG(@"_isBackgroundMusicON:%@", (_isBackgroundMusicON)?@"YES":@"NO");
      // update Data.plist
      
      // update sender MenuItem
      [sender setString:(_isBackgroundMusicON)?@"Backgound Music : ON":@"Backgound Music : OFF"];
    }];
    
    CCMenuItemFont *efToggleItem = [CCMenuItemFont itemWithString:(_isEffectSoundON)?@"Sound Effect : ON":@"Sound Effect : OFF" block:^(id sender){
      _isEffectSoundON = !_isEffectSoundON;
      CCLOG(@"_isEffectSoungON:%@", (_isEffectSoundON)?@"YES":@"NO");
      // update Data.plist
      
      // update sender MenuItem
      [sender setString:(_isEffectSoundON)?@"Sound Effect : ON":@"Sound Effect : OFF"];
    }];

    CCMenu *menu2 = [CCMenu menuWithItems: bgToggleItem,efToggleItem, nil];
    [menu2 alignItemsVerticallyWithPadding:20];
    [menu2 setPosition:ccp( size.width/2, header.position.y - 100)];
    [self addChild:menu2 z:98];
    
    // back button
    [CCMenuItemFont setFontSize:24];
    CCMenu *menu;
    
    CCMenuItem *itemBack = [CCMenuItemFont itemWithString:@"Back" block:^(id sender){
      [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[mainMenuLayer scene] withColor:ccWHITE]];
    }
                            ];
    
    menu = [CCMenu menuWithItems:itemBack, nil];
    
    [menu alignItemsVerticallyWithPadding:10];
    [menu setPosition:ccp( size.width/2, 50)];
    // Add the menu to the layer
    [self addChild:menu z:99];
  }
  return self;
}

- (void) dealloc {	[super dealloc]; }

@end
