//
//  ggObject.m
//  gemgemCCScene
//
//  Created by Yong-uk Choe on 12. 11. 24..
//
//

#import "ggObject.h"

@implementation ggObject

-(id)initWithCCLayer:(CCLayer *)_layer {
  CCLOG(@"*** starting init gemgem framework %@ ***", GEMGEM_VERSION);

  if ( self = [super init] ) {
    _ggConfig = [[NSMutableDictionary alloc] init];
    _thisCCLayer = _layer;

    /*
    CCLOG(@"_ggConfig count(before):%d", [_ggConfig count]);
    [_ggConfig setObject:[NSNumber numberWithFloat:0.9f] forKey:@"GemGemVersion"];
    CCLOG(@"_ggConfig count(after):%d", [_ggConfig count]);
    */
    
    [self loadDefaultConfiguration];
    _thisStatus = ggStatusINIT;
  } else {
    CCLOG(@"init failed : crash");
    exit(EXIT_FAILURE);
  }
  
  return self;
}
-(ggStatus) getStatus {
  /*
  if (_thisStatus == ggStatusINIT) {
    CCLOG(@"ggStatus:INIT");
  } else if (_thisStatus == ggStatusReadyToTouch) {
    CCLOG(@"ggStatus:ReadyToTouch");
  } else if (_thisStatus == ggStatusInAnimation) {
    CCLOG(@"ggStatus:InAnimation");
  }
  */
  return _thisStatus;
}

-(void)loadDefaultConfiguration {
  [self setConfig:@"GemGameType" value:[NSNumber numberWithInt:1]];
  
  [self setConfig:@"GemTypeCount" value:[NSNumber numberWithInt:4]];
  /*
  // TODO: Gem Class 재정의 할 수 있도록 할 것 
  [self setConfig:@"GemType_01" value:[[ggGem alloc] initAsTest:1]];
  [self setConfig:@"GemType_02" value:[[ggGem alloc] initAsTest:2]];
  [self setConfig:@"GemType_03" value:[[ggGem alloc] initAsTest:3]];
  [self setConfig:@"GemType_04" value:[[ggGem alloc] initAsTest:4]];
  */
  
  [self setConfig:@"GemBoard_width" value:[NSNumber numberWithInt:8]];
  [self setConfig:@"GemBoard_height" value:[NSNumber numberWithInt:8]];
  [self setConfig:@"GemBoard_unitPixel" value:[NSNumber numberWithInt:32]];
  [self setConfig:@"GemBoard_anchor_pos" value:[NSValue valueWithCGPoint:ccp(10,10)] ];

  
  
}

-(void) setConfig:(NSString *)keyString value:(id)valueObject {
  //CCLOG(@"_ggConfig count(before):%d", [_ggConfig count]);
  [_ggConfig setObject:valueObject forKey:keyString];
  //CCLOG(@"_ggConfig count(after):%d", [_ggConfig count]);

  CCLOG(@"_ggConfig[%@]:%@", keyString, ([_ggConfig objectForKey:keyString] != nil) ? @"ok" : @"failed");
}

-(NSObject *) getConfig:(NSString *)keyString {
  NSObject *o = [_ggConfig objectForKey:keyString];
  if ( o == nil) {
    
    return nil;
  }
  return o;
}

-(void) __drawBoard {
  _board = [[NSMutableDictionary alloc] init];
  int _unitSize = [[_ggConfig objectForKey:@"GemBoard_unitPixel"] intValue];
  
  for (int h = 1; h <= [[_ggConfig objectForKey:@"GemBoard_height"] intValue]; h++) {
    for (int w = 1; w <= [[_ggConfig objectForKey:@"GemBoard_width"] intValue]; w++) {
      NSValue *_posNSValue = [NSValue valueWithCGPoint:(CGPointMake(w, h))];
      /*
       // add:
       [array addObject:[NSValue value:&p withObjCType:@encode(struct Point)]];
       
       // extract:
       struct Point p;
       [[array objectAtIndex:i] getValue:&p];
       */
      ggBoardStruct bs;
      bs.isEmpty = YES;
      bs.Gem = nil;
      bs.position = ccpAdd([(NSValue*)[self getConfig:@"GemBoard_anchor_pos"] CGPointValue], ccp((w-1)*_unitSize, (h-1)*_unitSize));
      
      [_board setObject:[NSValue value:&bs withObjCType:@encode(ggBoardStruct)] forKey:_posNSValue];
    }
  }
}

-(int) __findBottom:(int)columnNumber {
  return 1; // test
}

-(void) __dropGemsForFirstTime {
  ggStatus _lastStatus = _thisStatus;
  _thisStatus = ggStatusInAnimation;
  
  //localAnimationStatus = NO;
  
  int gemBoard_height_from_config = [[_ggConfig objectForKey:@"GemBoard_height"] intValue];
  int _unitSize = [[_ggConfig objectForKey:@"GemBoard_unitPixel"] intValue];
  CGPoint boardAnchorPosition = [(NSValue*)[self getConfig:@"GemBoard_anchor_pos"] CGPointValue];
  //int lastActionTag = 0;
  NSMutableArray *actions = [[NSMutableArray alloc] init];
  
  for (int h = 1; h <= gemBoard_height_from_config; h++) {
    for (int w = 2; w <= [[_ggConfig objectForKey:@"GemBoard_width"] intValue]; w++ ) {
      int bottom = [self __findBottom:w];
      //if (bottom == gemBoard_height_from_config) continue; // 꼭데기 까지 차 있다면 다음줄로 ..
      // TODO: 초기화 과정에선 필요 없음 이 항목을 [self __dropGemAtColumn:(int)] 로 옮길때 같이 옮길 것
      
      //step1: gem 생성
      int gemType = rand() % 4 + 1; // 1,2,3,4
      CCLOG(@"random GemType:%d", gemType);
      ggGem *g = [[ggGem alloc] initAsTest:gemType];
      
      //step2: 해당 _board 객체에 Gem 등록
      NSValue *pos = [NSValue valueWithCGPoint:(CGPointMake(w, bottom))];
      NSValue *valueFrom_board = [_board objectForKey:pos];
      ggBoardStruct bs;
      [valueFrom_board getValue:&bs];
      bs.Gem = g; // 등록(교체)
      NSValue *obj = [NSValue value:&bs withObjCType:@encode(ggBoardStruct)]; // encode as NSValue
      //CCLOG(@"replace before count:%d", [_board count]);
      [_board setObject:obj forKey:pos];
      //CCLOG(@"replace after count:%d", [_board count]);
      
      //step3: 애니메이션
      // pos(w,gemBoard_height_from_config) -> pos(w,bottom)=pos
      CCSprite *gemSprite = [g getCCSprite];
      gemSprite.position = ccpAdd(boardAnchorPosition, ccp((w-1)*_unitSize, (gemBoard_height_from_config+2)*_unitSize)); // starting point
      
      CCAction *ani = [CCSequence actions:
                        [CCCallBlock actionWithBlock:^{
                          [_thisCCLayer addChild:gemSprite];
                          [gemSprite runAction:[CCMoveTo actionWithDuration:0.5f position:ccp((w-1)*_unitSize, (bottom-1)*_unitSize)]];
                        }],
                        //[CCCallBlock actionWithBlock:^{ localAnimationStatus = NO; }],
                        nil];
      [actions addObject:ani];
      break; // TEST
    }
    break; //TEST
  }
  
  //
  CCFiniteTimeAction *seq = nil;
  int actionscount = 0;
	for (CCFiniteTimeAction *anAction in actions) {
    CCLOG(@"actions Count:%d", ++actionscount);
		if (!seq) {
			seq = anAction;
		} else {
			seq = [CCSequence actionOne:seq two:anAction];
		}
	}
  [_thisCCLayer runAction:seq];
}

-(void) run {
  //step 1 : 변수초기화
  _board = [[NSMutableDictionary alloc] init];
  
  //step 2 : board 그리기
  [self __drawBoard];
  //step 3 : gem 낙하 width*height 갯수 만큼
  [self __dropGemsForFirstTime];
  //step 4 :
  
}

-(BOOL) isTouchAvailable:(CGPoint)position {
  return YES;
}

//Game1 :
-(BOOL) isGemBurstable:(NSValue *)posInBoard {
  // TODO : 3개 이상 연속 체크 알고리즘
  return YES;
}


@end