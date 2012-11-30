//
//  creditsLayer.m
//  gemgem
//
//  Created by Yong-uk Choe on 12. 11. 30..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import "creditsLayer.h"
#import "mainMenuLayer.h"

@implementation creditsLayer

+(CCScene *) scene {
  CCScene *scene = [CCScene node];
  creditsLayer *layer = [creditsLayer node];
  [scene addChild: layer];
  
  return scene;
}

-(id)init {
  if( (self=[super init])) {
    self.isTouchEnabled = YES; // 글로벌 터치 인식
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    // header
    CCLabelTTF *header = [CCLabelTTF labelWithString:@"CREDITS"
                                            fontName:@"Marker Felt" fontSize:36];
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
    
    // Add the menu to the layer
    [self addChild:menu z:99];
    
    
  }
  return self;
}

- (void) dealloc {	[super dealloc]; }

@end
