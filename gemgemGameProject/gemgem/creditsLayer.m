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

    // labels
    CCLabelTTF *c11 = [CCLabelTTF labelWithString:@"design/code" fontName:@"Marker Felt" fontSize:24];
    c11.position = ccpAdd(header.position, ccp(0,-70));
    CCLabelTTF *c12 = [CCLabelTTF labelWithString:@"Yong-uk.Choe@gmail.com" fontName:@"Marker Felt" fontSize:16];
    c12.position = ccpAdd(c11.position, ccp(0,-20));

    CCLabelTTF *c21 = [CCLabelTTF labelWithString:@"art" fontName:@"Marker Felt" fontSize:24];
    c21.position = ccpAdd(c12.position, ccp(0,-50));
    CCLabelTTF *c22 = [CCLabelTTF labelWithString:@"Yong-uk.Choe@gmail.com" fontName:@"Marker Felt" fontSize:16];
    c22.position = ccpAdd(c21.position, ccp(0,-20));

    CCLabelTTF *c31 = [CCLabelTTF labelWithString:@"sound" fontName:@"Marker Felt" fontSize:24];
    c31.position = ccpAdd(c22.position, ccp(0,-50));
    CCLabelTTF *c32 = [CCLabelTTF labelWithString:@"none" fontName:@"Marker Felt" fontSize:16];
    c32.position = ccpAdd(c31.position, ccp(0,-20));

    CCLabelTTF *c4 = [CCLabelTTF labelWithString:@"http://noizze.net" fontName:@"Marker Felt" fontSize:12];
    c4.position = ccpAdd(c32.position, ccp(0,-50));

    
    [self addChild:c11 z:999];
    [self addChild:c12 z:999];
    [self addChild:c21 z:999];
    [self addChild:c22 z:999];
    [self addChild:c31 z:999];
    [self addChild:c32 z:999];
    
    [self addChild:c4 z:999];
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
