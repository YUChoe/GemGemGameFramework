//
//  ggGem.h
//  gemgemCCScene
//
//  Created by Yong-uk Choe on 12. 11. 24..
//
//

#import <Foundation/Foundation.h>
#import "ggConfig.h"

@interface ggGem : NSObject
{
  NSMutableArray *_obj;
  CCSprite *_sprite;
}

-(id)init;
-(id)initAsTest:(int)testValue;

-(id)getObject; // return _obj as NSMutableArray
-(CCSprite *)getCCSprite;

//
-(void)resizeSprite:(CCSprite*)sprite toWidth:(float)width toHeight:(float)height;

@end
