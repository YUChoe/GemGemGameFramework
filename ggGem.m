//
//  ggGem.m
//  gemgemCCScene
//
//  Created by Yong-uk Choe on 12. 11. 24..
//
//

#import "ggGem.h"

@implementation ggGem

-(id)init {
  if ( self = [super init] ) {
    _obj = [[NSMutableArray alloc] init];
    // 구현 나중에
  }
  return self;
}

-(id)initAsTest:(int)testValue {
  if ( self = [super init] ) {
    _obj = [[NSMutableArray alloc] init];
  
    [self _test:testValue];
    
  }
  return self;
}

-(void)resizeSprite:(CCSprite*)sprite toWidth:(float)width toHeight:(float)height {
  sprite.scaleX = width / sprite.contentSize.width;
  sprite.scaleY = height / sprite.contentSize.height;
}

-(void) _test:(int)testValue {
  if (testValue == 1) {
    _sprite = [CCSprite spriteWithFile:@"1.png"];
  } else if (testValue == 2) {
    _sprite = [CCSprite spriteWithFile:@"2.png"];
  } else if (testValue == 3) {
_sprite = [CCSprite spriteWithFile:@"3.png"];
  } else if (testValue == 4) {
_sprite = [CCSprite spriteWithFile:@"4.png"];
  }
  //[self resizeSprite:_sprite toWidth:32 toHeight:32];
  [self resizeSprite:_sprite toWidth:40 toHeight:40];
  //[_obj addObject:_sprite];
} // end of test

-(CCSprite *)getCCSprite {
  return _sprite;
}

-(id)getObject {
  // 0: CCSprite
  return _obj;
}

@end