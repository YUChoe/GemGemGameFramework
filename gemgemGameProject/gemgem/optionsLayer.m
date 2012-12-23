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

-(id)init {
  if( (self=[super init])) {
    self.isTouchEnabled = YES; // 글로벌 터치 인식
    CGSize size = [[CCDirector sharedDirector] winSize];
    // header
    CCLabelTTF *header = [CCLabelTTF labelWithString:@"OPTIONS" fontName:@"Marker Felt" fontSize:36];
    header.position =  ccp(size.width/2, size.height - 50);
    [self addChild:header z:999];

    // config
    
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
    
    // 2menus test
    CCMenu *menu2 = [CCMenu menuWithItems:
                     [CCMenuItemFont itemWithString:@"Backgound Music : ON" block:^(id sender){}],
                     [CCMenuItemFont itemWithString:@"Sound Effect : ON" block:^(id sender){}],
                     nil];
    [menu2 alignItemsVerticallyWithPadding:20];
    [menu2 setPosition:ccp( size.width/2, header.position.y - 100)];
    [self addChild:menu2 z:98];
    
    // Add the menu to the layer
    [self addChild:menu z:99];
  }
  return self;
}

- (void) dealloc {	[super dealloc]; }

@end
