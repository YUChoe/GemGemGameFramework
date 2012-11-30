//
//  gameOverLayer.m
//  gemgem
//
//  Created by Yong-uk Choe on 12. 11. 29..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import "gameOverLayer.h"
#import "HelloWorldLayer.h"

@implementation gameOverLayer

+(CCScene *) scene
{
  // 'scene' is an autorelease object.
  CCScene *scene = [CCScene node];
  
  // 'layer' is an autorelease object.
  gameOverLayer *layer = [gameOverLayer node];
  
  // add layer as a child to scene
  [scene addChild: layer];
  
  // return the scene
  return scene;
}

-(id)init {
  if( (self=[super init])) {
    self.isTouchEnabled = YES; // 글로벌 터치 인식
  }
  return self;
}

@end
