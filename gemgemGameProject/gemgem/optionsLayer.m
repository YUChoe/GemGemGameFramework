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
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  //CCLOG(@"Documents path:%@",documentsDirectory);
  
  NSString *plistPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@.plist", CONFIG_PLIST_FILENAME]];
  NSDictionary *confDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
  //CCLOG(@"confDict:%@", confDict);

  if ([confDict objectForKey:@"isBackgroundMusicON"] != nil) {
    _isBackgroundMusicON = [[confDict objectForKey:@"isBackgroundMusicON"] boolValue];
  } else {
    [self saveConfigToDataplist];
    return;
  }
  
  if ([confDict objectForKey:@"isEffectSoundON"] != nil) {
    _isEffectSoundON = [[confDict objectForKey:@"isEffectSoundON"] boolValue];
  } else {
    [self saveConfigToDataplist];
    return;
  }
}

-(void) saveConfigToDataplist {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  //CCLOG(@"Documents path:%@",documentsDirectory);
  
  NSString *plistPath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@.plist", CONFIG_PLIST_FILENAME]];

  NSMutableDictionary *confDict = [[[NSMutableDictionary alloc]init]  autorelease];
  
  [confDict setObject:[NSNumber numberWithBool:_isBackgroundMusicON] forKey:@"isBackgroundMusicON"];
  [confDict setObject:[NSNumber numberWithBool:_isEffectSoundON] forKey:@"isEffectSoundON"];
  
  [confDict writeToFile:plistPath atomically:YES];

  
  //CCLOG(@"writeToFile:%@",plistPath);
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
    [self readConfigFromDataplist];
    //CCLOG(@"_isBackgroundMusicON:%@", (_isBackgroundMusicON)?@"YES":@"NO");
    //CCLOG(@"_isEffectSoungON:%@", (_isEffectSoundON)?@"YES":@"NO");
    
    // ON/OFF menu
    CCMenuItemFont *bgToggleItem = [CCMenuItemFont itemWithString:(_isBackgroundMusicON)?@"Backgound Music : ON":@"Backgound Music : OFF" block:^(id sender){
      _isBackgroundMusicON = !_isBackgroundMusicON;
      //CCLOG(@"_isBackgroundMusicON:%@", (_isBackgroundMusicON)?@"YES":@"NO");
      // update Data.plist
      [self saveConfigToDataplist];
      // update sender MenuItem
      [sender setString:(_isBackgroundMusicON)?@"Backgound Music : ON":@"Backgound Music : OFF"];
    }];
    
    CCMenuItemFont *efToggleItem = [CCMenuItemFont itemWithString:(_isEffectSoundON)?@"Sound Effect : ON":@"Sound Effect : OFF" block:^(id sender){
      _isEffectSoundON = !_isEffectSoundON;
      //CCLOG(@"_isEffectSoungON:%@", (_isEffectSoundON)?@"YES":@"NO");
      // update Data.plist
      [self saveConfigToDataplist];
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
