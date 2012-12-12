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
    
    //[self loadDefaultConfiguration];
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
  CCLOG(@"Loading DefaultConfiguration *** ");
  // game
  [self setConfig:@"GemGemGameType" value:[NSNumber numberWithInt:1]];
  [self setConfig:@"GemGame_MadeGems" value:[NSNumber numberWithInt:4]]; // *******************
  [self setConfig:@"GemGame_MadeGems_Bonus" value:[NSNumber numberWithInt:8]];
  [self setConfig:@"GemGame_Score_Add" value:[NSNumber numberWithInt:10]];
  [self setConfig:@"GemGame_ScoreBonus_Add" value:[NSNumber numberWithInt:20]];
  
  
  // gem
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
  [self setConfig:@"GemBoard_unitPixel" value:[NSNumber numberWithInt:40]];
  //[self setConfig:@"GemBoard_anchor_pos" value:[NSValue valueWithCGPoint:ccp(48, 180)] ];
  [self setConfig:@"GemBoard_anchor_pos" value:[NSValue valueWithCGPoint:ccp(20, 100)] ];
}

-(void) setConfig:(NSString *)keyString value:(id)valueObject {
  //CCLOG(@"_ggConfig count(before):%d", [_ggConfig count]);
  [_ggConfig setObject:valueObject forKey:keyString];
  //CCLOG(@"_ggConfig count(after):%d", [_ggConfig count]);

  //CCLOG(@"_ggConfig[%@]:%@", keyString, ([_ggConfig objectForKey:keyString] != nil) ? @"ok" : @"failed");
}

-(NSObject *) getConfig:(NSString *)keyString {
  NSObject *o = [_ggConfig objectForKey:keyString];
  if ( o == nil) {
    
    return nil;
  }
  return o;
}


-(int) getScore {
  return _gameScore;
}
-(void) setScore:(int)newScore {
  int margin = newScore - _gameScore;
  _gameScore = newScore;
  
  NSMutableDictionary *userInfoMDic = [[NSMutableDictionary alloc] init];
  
  [userInfoMDic setObject:[NSNumber numberWithInt:margin] forKey:@"margin"];
  [userInfoMDic setObject:[NSNumber numberWithInt:_gameScore] forKey:@"score"];
  [userInfoMDic setObject:[NSValue valueWithCGPoint:_lastEventTouchPoint] forKey:@"point"];
  
  NSDictionary *userInfoDic = [[userInfoMDic copy] autorelease];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:GG_NOTIFICATION_SCORE_UPDATE object:self userInfo:userInfoDic];
  
}

-(void) __drawBoard {
  _board = [[NSMutableDictionary alloc] init];
  
  for (int h = 1; h <= ggConfig.BoardHeight; h++) {
    for (int w = 1; w <= ggConfig.BoardWidth ; w++) {
      NSValue *_posNSValue = [NSValue valueWithCGPoint:(CGPointMake(w, h))];

      ggBoardStruct bs;
      bs.isEmpty = YES;
      bs.Gem = nil;
      bs.gemType = 0;
      bs.position = ccpAdd(ggConfig.BoardAnchorPosition, ccp((w-1)*ggConfig.GemSizeBYPixel, (h-1)*ggConfig.GemSizeBYPixel));
      // TODO: 만약 여기 CGRect 가 있어서 touch 와 비교 한다면?
      
      [_board setObject:[NSValue value:&bs withObjCType:@encode(ggBoardStruct)] forKey:_posNSValue];
    }
  }
}

-(int) __findBottom:(int)columnNumber {
  for (int h = ggConfig.BoardHeight; h>=1 ; h--) {
    NSValue *pos = [NSValue valueWithCGPoint:CGPointMake(columnNumber, h)];
    NSValue *valueFrom_board = [_board objectForKey:pos];
    ggBoardStruct bs;
    [valueFrom_board getValue:&bs];
    if (bs.isEmpty == NO) {
      //CCLOG(@"(%d,%d) is NOT empty;return %d", columnNumber, h, h+1);
      return (h+1);
    }
    //CCLOG(@"Gem at pos(%d,%d) is %@", columnNumber, h, (bs.Gem == nil)?@"nil":@"CCSprite");
  }
  return 1; // default 
}

-(void) __dropGemsForFirstTime {
  ggStatus _lastStatus = _thisStatus;
  _thisStatus = ggStatusInAnimation;
  
  NSMutableArray *actions = [[NSMutableArray alloc] init];
  
  for (int h = 1; h <= ggConfig.BoardHeight; h++) {
    for (int w = 1; w <= ggConfig.BoardWidth; w++ ) {
      int bottom = [self __findBottom:w];
      CCAction *ani = [self __gemDropAtColumn:w bottom:bottom];
      if (ani != nil) [actions addObject:ani];
    }
  }
  // state flag 원래 대로 변경을 가장 마지막 action 으로 push 
  [actions addObject:[CCCallBlock actionWithBlock:^{ _thisStatus = _lastStatus; }]];
  
  //
  CCFiniteTimeAction *seq = nil;
  //int actionscount = 0;
	for (CCFiniteTimeAction *anAction in actions) {
    //CCLOG(@"actions Count:%d", ++actionscount);
		if (!seq) {
			seq = anAction;
		} else {
			seq = [CCSequence actionOne:seq two:anAction];
		}
	}

  [_thisCCLayer runAction:seq];
}

-(void) run {
  // 이 method 가 실행 되는 위치가 custom setting 이후이므로 여기에서 전역 변수 전달
  
  //step 1 : 변수초기화
  srand(time(NULL));
  _board = [[NSMutableDictionary alloc] init];

  // config
  ggConfig.GameType            = [[_ggConfig objectForKey:@"GemGemGameType"]     intValue];
  
  ggConfig.GemSizeBYPixel      = [[_ggConfig objectForKey:@"GemBoard_unitPixel"] intValue];
  ggConfig.BoardHeight         = [[_ggConfig objectForKey:@"GemBoard_height"]    intValue];
  ggConfig.BoardWidth          = [[_ggConfig objectForKey:@"GemBoard_width"]     intValue];
  ggConfig.BoardAnchorPosition = [[_ggConfig objectForKey:@"GemBoard_anchor_pos"] CGPointValue];
  
  ggConfig.GemTypeCount        = [[_ggConfig objectForKey:@"GemTypeCount"] intValue];
  ggConfig.GameMadeGems        = [[_ggConfig objectForKey:@"GemGame_MadeGems"] intValue];
  ggConfig.GameMadeBonusGems   = [[_ggConfig objectForKey:@"GemGame_MadeGems_Bonus"] intValue];
  ggConfig.GameScodeAdd        = [[_ggConfig objectForKey:@"GemGame_Score_Add"] intValue];
  ggConfig.GameScodeBonus      = [[_ggConfig objectForKey:@"GemGame_ScoreBonus_Add"] intValue];

  //step 2 : board 그리기
  [self __drawBoard];
  
  //step 3 : gem 낙하 width*height 갯수 만큼
  [self __dropGemsForFirstTime];
  
  //step 4 : items 자리 잡기
  _thisItems = [[ggItems alloc] initWithCCLayer:_thisCCLayer at_y:(ggConfig.BoardAnchorPosition.y - 25)];
  
  //TEST
  [_thisItems pushItem:0];
    [_thisItems pushItem:0];
    [_thisItems pushItem:0];
    [_thisItems pushItem:0];
    [_thisItems pushItem:0];
  
  //step 5 : timer 초기화 + 이벤트 받을 셀렉터 설정
  if (ggConfig.GameType == 1) {
    // challenge mode
  _thisTimer = [[ggTimer alloc] initWithCCLayer:_thisCCLayer
                                             at:(ccpAdd(ggConfig.BoardAnchorPosition, ccp(-16,+15))) // TODO 변수 사용 
                                      startSize:([[CCDirector sharedDirector] winSize].width)-4];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(__setAllStateAsGameover:)
                                               name:GG_NOTIFICATION_TIMEOUT
                                             object:_thisTimer];
  } else if (ggConfig.GameType == 2) {
    // infinity mode 
    // timer 없음 
  }
  CCLOG(@"*** Game Board init complete ***");
}

-(void) setGamePause {
  [_thisTimer pause];
}

-(void) setGameResume {
  [_thisTimer resume];
}

-(void) __giveBonusTime:(float)bonustime {
  //CCLOG(@"before bonus:%d", [_thisTimer getCurrentValue]);
  [_thisTimer setBonusTime:bonustime];
  CCLOG(@"after bonus:%.1f", [_thisTimer getCurrentValue]);
  
}

-(void) touchesEnded:(CGPoint)touchedLocation {

  for (NSValue *posAsNSValue in _board) {
    NSValue *valueFrom_board = [_board objectForKey:posAsNSValue];
    ggBoardStruct bs;
    [valueFrom_board getValue:&bs];
    CCSprite *s = [bs.Gem getCCSprite];
    CGRect box = CGRectMake(s.boundingBox.origin.x - ((ggConfig.GemSizeBYPixel - s.boundingBox.size.width) / 2),
                             s.boundingBox.origin.y - ((ggConfig.GemSizeBYPixel - s.boundingBox.size.height) / 2),
                             ggConfig.GemSizeBYPixel, ggConfig.GemSizeBYPixel);
 
    if (CGRectContainsPoint(box, touchedLocation)) {
      // Start Timer
      if ([_thisTimer getState] == ggTimerSTAT_STOPPED) {
        [_thisTimer start];
      } else if ([_thisTimer getState] == ggTimerSTAT_PAUSED) {
        [_thisTimer resume];
      }
 
      if ( ggConfig.GameType == 1 || ggConfig.GameType == 2) {
        // BurstGem Style : challenge or infinity modes
        if ([self isTouchAvailable:touchedLocation]) {
          // go Burst !
          _lastEventTouchPoint = touchedLocation;
          [self goGemBurst:posAsNSValue];
        }
      } else if (ggConfig.GameType == 3) {
        // beJuweled Style
      }
      return;
    }
  }
}

-(BOOL) isTouchAvailable:(CGPoint)position {
  if (_thisStatus == ggStatusInAnimation || _thisStatus == ggStatusStopTheGame) return NO;
  
  return YES;
}

//Game1 :
-(void) goGemBurst:(NSValue *)posInBoard {
  NSMutableArray *gems = [[NSMutableArray alloc] init];
  
  // seeding
  NSValue *valueFrom_board = [_board objectForKey:posInBoard];
  ggBoardStruct bs;
  [valueFrom_board getValue:&bs];
  int thisType = bs.gemType;
  if (thisType ==0) {
    CCLOG(@"게임 중에는 gravityJob 때문에 발생하지 않지만 빈칸?!");
    return;
  }
  // 돌리고 돌리고 돌리고
  [self GemContinuous:posInBoard gemType:thisType refArray:gems fromBoard:_board];
  
  // 결과물인 gems 의 카운트가 3개 이상?
  if ([gems count] >= ggConfig.GameMadeGems) {
    [self gemBurst:gems];
    // TODO: 빈칸채우기
    NSMutableDictionary *blankColumns = [self __gravityJob:gems];
    // Score Update
    if ([gems count] >= ggConfig.GameMadeBonusGems) {
      // no Bonus !!
      [self setScore: _gameScore + ([gems count] * ggConfig.GameScodeBonus)];
    } else {
      // bonus !
      [self setScore: _gameScore + ([gems count] * ggConfig.GameScodeAdd)];
    }

    [self __giveBonusTime:1];

    [[NSNotificationCenter defaultCenter] postNotificationName:GG_NOTIFICATION_ACTION_BURST object:self];
    
    // 다시 gem drop
    [self __fillBlank:blankColumns];
  
  } else {
    CCLOG(@"모자라는데 잘못터치!");
    // 감점
  }
}

-(void) __afterAnimations {
  // 연쇄 판정

  // 게임오버 판정
  if ([self __isPossible:_board] == NO) {
    [self __setAllStateAsGameover:nil];
  }
}

-(void) __setAllStateAsGameover:(NSNotification *)notice {
  _thisStatus = ggStatusStopTheGame;
  CCLOG(@"game over");
  //NSDictionary * userInfoDic = [NSDictionary dictionaryWithObject:@"" forKey:@""];
  //[[NSNotificationCenter defaultCenter] postNotificationName:GG_NOTIFICATION_GAME_OVER object:self userInfo:userInfoDic];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:GG_NOTIFICATION_GAME_OVER object:self];

}


-(BOOL) __isPossible:(NSMutableDictionary *)_tempBoard {
  NSMutableArray *gems = [[NSMutableArray alloc] init]; // 연속 확인 할 결과물
  NSMutableArray *checkedGem = [[NSMutableArray alloc] init]; // 확인 했는지 체크 gems 가 돌아오면 여기에 더한다
  
  int possibleCount = 0;
  
  for (NSValue *posAsNSValue in _tempBoard) {
    //CCLOG(@"checkLoop:_board(%.f,%.f)", [posAsNSValue CGPointValue].x, [posAsNSValue CGPointValue].y);
    NSValue *valueFrom_board = [_tempBoard objectForKey:posAsNSValue];
    ggBoardStruct bs;
    [valueFrom_board getValue:&bs];
    if (bs.gemType == 0 || [checkedGem containsObject:posAsNSValue]) {
      if (bs.gemType == 0) CCLOG(@"이러면 안됨 [%.f,%.f] = 0 !!!", [posAsNSValue CGPointValue].x, [posAsNSValue CGPointValue].y);
      continue; // 중복방지
    }

    // 돌리고 돌리고 돌리고
    [checkedGem addObject:posAsNSValue];
    [gems removeAllObjects]; // 돌리기 전에 초기화 
    
    [self GemContinuous:posAsNSValue gemType:bs.gemType refArray:gems fromBoard:_tempBoard];
    
    // TODO 로직 정리
    if ([gems count] >= ggConfig.GameMadeGems ) {
      possibleCount++;
      if (possibleCount > 1) {
      return YES; // 풀게 있음
      } else {
        // checked 에 집어 넣고 for문 계속
        for (NSValue *v in gems) {
          [checkedGem addObject:v];
        }
        continue;
      }
    } else {
      // checked 에 집어 넣고 for문 계속
      for (NSValue *v in gems) {
        [checkedGem addObject:v];
      }
      continue;
    }
  }
  return NO;
}

-(void) __fillBlank:(NSMutableDictionary *)blankColumns {
  // blankColumns 을 bGems 배열로 다시 변환.
  NSMutableArray *bGems = [[NSMutableArray alloc] init];
  for (NSNumber *colNum in blankColumns) {
    NSMutableArray *blankOnBoards = [blankColumns objectForKey:colNum];
    
    for (int n = ggConfig.BoardHeight; n > (ggConfig.BoardHeight - [blankOnBoards count]); n--) {
      NSValue *npos = [NSValue valueWithCGPoint:CGPointMake([colNum intValue], n)];
      //CCLOG(@"(%d,%d)", [colNum intValue], n);
      [bGems addObject:npos];
    }
  }
  
  NSMutableDictionary *_decision = [[NSMutableDictionary alloc] init];
  NSMutableDictionary *_tempBoard = [[NSMutableDictionary alloc] init];
  
  
  do {                                                // 여기서 부터 ................
    [_tempBoard removeAllObjects];
    _tempBoard = [[NSMutableDictionary alloc] initWithDictionary:_board];
    [_decision removeAllObjects];

    for (NSValue *blnkPos in bGems) {    // gems 참조해서 random 으로 각 빈칸을 채움
      int gemType = rand() % ggConfig.GemTypeCount + 1;

      ggGem *g = [self __registAGemTypeof:gemType AtPositionAsNSValue:blnkPos onBoard:_tempBoard];
      
      NSMutableArray *unit = [[NSMutableArray alloc] init];
      [unit addObject:[NSNumber numberWithInt:gemType]];
      [unit addObject:[g getCCSprite]];
      [unit addObject:blnkPos];

      [_decision setObject:unit forKey:blnkPos];
    }
  } while ([self __isPossible:_tempBoard] == NO);     // made 가 가능 할 때 까지 재시도

  // 결정 되었으니 overwrap !
  [_board removeAllObjects];
  _board = [[NSMutableDictionary alloc] initWithDictionary:_tempBoard];
  
  // ready animation
  ggStatus _lastStatus = _thisStatus;
  _thisStatus = ggStatusInAnimation;
  
  NSMutableArray *actions = [[NSMutableArray alloc] init];
  [actions addObject:[CCDelayTime actionWithDuration:0.5f]]; //gravity 기다리는 시간

  //CCLOG(@"decision count:%d", [_decision count]);
  
  //for (NSValue *decisionPos in _decision) {
  for (int h = 1; h <= ggConfig.BoardHeight; h++) {
    for (int w = 1; w <= ggConfig.BoardWidth; w++) {
      NSValue *decisionPos = [NSValue valueWithCGPoint:CGPointMake(w, h)];
      if ([_decision objectForKey:decisionPos] != nil) {
        
        NSMutableArray *unit = [_decision objectForKey:decisionPos];
        
        CCSprite *g = [unit objectAtIndex:1];
        CGPoint _topReadyPosition = [self __TopReadyPosition_NSValue2CGPoint:decisionPos];
        CGPoint _targetPosition = [self __Position_NSValue2CGPoint:[unit objectAtIndex:2]];
        int distance = ggConfig.BoardHeight - [[unit objectAtIndex:2] CGPointValue].y + 2; // 2 칸 위 부터
        float _speed_unit = 0.1f; // 1칸을 내려오는데 걸리는 시간 단위
        float dropSpeed = _speed_unit * distance;
        
        // spawn / ready starting position
        g.position = _topReadyPosition;
        [_thisCCLayer addChild:g z:10];
        
        CCAction *ani =
        [CCSpawn actionOne:[CCCallBlock actionWithBlock:^{ [g runAction:[CCMoveTo actionWithDuration:dropSpeed position:_targetPosition]]; }]
                       two:[CCDelayTime actionWithDuration:(_speed_unit * 1.2f)] ];
        
        //
        [actions addObject:ani];
      }
    }
  }
  
  // do animation
  [actions addObject:[CCCallBlock actionWithBlock:^{ _thisStatus = _lastStatus; }]];
  
  // 채우기 끝내면 각종 판정 들
  [actions addObject:[CCCallBlock actionWithBlock:^{ [self __afterAnimations]; }]];
  
  //
  CCFiniteTimeAction *seq = nil;
  //int actionscount = 0;
	for (CCFiniteTimeAction *anAction in actions) {
    //CCLOG(@"actions Count:%d", ++actionscount);
		if (!seq) {
			seq = anAction;
		} else {
			seq = [CCSequence actionOne:seq two:anAction];
		}
	}
  
  [_thisCCLayer runAction:seq];
}

-(void) __dumpBoard:(NSMutableDictionary *)board gems:(NSMutableArray *)gems {
  for (int h = ggConfig.BoardHeight; h >= 1; h--) {
    NSString *row = @"";
    for (int w = 1; w <= ggConfig.BoardWidth; w++) {
      NSValue *pos = [NSValue valueWithCGPoint:CGPointMake(w, h)];
      NSValue *v = [board objectForKey:pos];
      ggBoardStruct bs; [v getValue:&bs];
      
      if ([gems containsObject:pos]) {
        row = [NSString stringWithFormat:@"%@ [*%d]", row, bs.gemType];
      } else {
        row = [NSString stringWithFormat:@"%@ [ %d]", row, bs.gemType];
      }
    }
    CCLOG(@"%d: %@", h, row);
  }
}

-(ggGem *) __registAGemTypeof:(int)gemType AtPositionAsNSValue:(NSValue *)posAsVal onBoard:(NSMutableDictionary *)targetBoard {
  ggGem *g = [[ggGem alloc] initAsTest:gemType size:ggConfig.GemSizeBYPixel];
  
  NSValue *valueFrom_board = [targetBoard objectForKey:posAsVal];
  ggBoardStruct bs;
  [valueFrom_board getValue:&bs];
  
  bs.Gem = g; // 등록(교체)
  bs.gemType = gemType;
  bs.isEmpty = NO;
  bs.position = [self __Position_NSValue2CGPoint:posAsVal];
  
  NSValue *obj = [NSValue value:&bs withObjCType:@encode(ggBoardStruct)];
  
  [targetBoard setObject:obj forKey:posAsVal];
  
  return g;
}

-(CCAction *) __gemDropAtColumn:(int)columnNumber bottom:(int)bottom {
  //step1: gem 생성
  int gemType = rand() % ggConfig.GemTypeCount + 1; // 1,2,3,4
  
  NSValue *pos = [NSValue valueWithCGPoint:(CGPointMake(columnNumber, bottom))];
  
  ggGem *g = [self __registAGemTypeof:gemType AtPositionAsNSValue:pos onBoard:_board];
  
  //step3: 애니메이션
  // pos(w,gemBoard_height_from_config) -> pos(w,bottom)=pos
  CCSprite *gemSprite = [g getCCSprite];
  gemSprite.position = ccpAdd(ggConfig.BoardAnchorPosition,
                              ccp((columnNumber - 1)*ggConfig.GemSizeBYPixel, (ggConfig.BoardHeight+2)*ggConfig.GemSizeBYPixel)); // starting point
  [_thisCCLayer addChild:gemSprite z:10];
  
  float dropSpeed = 0.1f * (ggConfig.BoardHeight + 2 - bottom);
  CGPoint targetPosition = ccpAdd(ggConfig.BoardAnchorPosition, ccp((columnNumber - 1)*ggConfig.GemSizeBYPixel, (bottom)*ggConfig.GemSizeBYPixel));
  
  CCAction *ani = [CCSequence actions:
                   [CCCallBlock actionWithBlock:^{ [gemSprite runAction:[CCMoveTo actionWithDuration:dropSpeed position:targetPosition]]; }],
                   [CCDelayTime actionWithDuration:0.02f],
                   //[CCCallBlock actionWithBlock:^{ localAnimationStatus = NO; }],
                   nil];
  return ani;
}

-(NSMutableDictionary *) __GemsArray2Dictionary:(NSMutableArray *) gems {
  NSMutableDictionary *colDic = [[NSMutableDictionary alloc] init]; // key: 칼럼#, value: pos배열
  
  for (NSValue *gemPos in gems) {
    CGPoint p = [gemPos CGPointValue];
    NSNumber *xx = [NSNumber numberWithFloat: p.x];
    if ([colDic objectForKey:xx] == nil) {
      NSMutableArray *points = [[NSMutableArray alloc] init];
      [points addObject:gemPos];
      [colDic setObject:points forKey:xx];
    } else {
      // 이미 있는 칼럼
      NSMutableArray *points = [colDic objectForKey:xx];
      [points addObject:gemPos];
      [colDic setObject:points forKey:xx];
    }
  }
  return colDic;
}

-(CGPoint) __TopReadyPosition_NSValue2CGPoint:(NSValue *)value {
  int columnNum = [value CGPointValue].x;
  return ccpAdd( ggConfig.BoardAnchorPosition, ccp((columnNum - 1) * ggConfig.GemSizeBYPixel, (ggConfig.BoardHeight + 2) * ggConfig.GemSizeBYPixel));
}

-(CGPoint) __Position_NSValue2CGPoint:(NSValue *)value {
  CGPoint xy = [value CGPointValue];
  return ccpAdd( ggConfig.BoardAnchorPosition,
                ccp( (xy.x -1) * ggConfig.GemSizeBYPixel, (xy.y) * ggConfig.GemSizeBYPixel ));
}

// gravity job
-(NSMutableDictionary *) __gravityJob:(NSMutableArray *)gems {
  NSMutableDictionary *colDic = [self __GemsArray2Dictionary:gems];
  
  //CCLOG(@"columns count:%d", [colDic count]);
  for (NSNumber *c in colDic) {
    //CCLOG(@"채우기:col[%d]:%d개", [c intValue], [points count]);

    for (int h = 1; h <= ggConfig.BoardHeight; h++) {
      //CCLOG(@"%d회차 중력 작동", h);
      
      NSValue *blankBoardPos = nil;
      NSValue *fallingGemPos = nil;
      
      for (int hh = 1; hh <= ggConfig.BoardHeight; hh++) {
        NSValue *posAsNSValue = [NSValue valueWithCGPoint:CGPointMake([c intValue], hh)];
        NSValue *valueFrom_board = [_board objectForKey:posAsNSValue];
        ggBoardStruct bs;
        [valueFrom_board getValue:&bs];
        if (bs.isEmpty == YES && blankBoardPos == nil) {
          //CCLOG(@"아래로부터 거슬러 올라가면서 최초의 빈칸:%d", hh);
          blankBoardPos = posAsNSValue;
        } else if (bs.isEmpty == NO && fallingGemPos == nil && blankBoardPos != nil) {
          //CCLOG(@"아래로부터 거슬러 올라가면서 최초의 Gem:%d", hh);
          fallingGemPos = posAsNSValue;
          break;
        }
      } // of for hh loop
      
      // _board 안의 gem@fallingGemPos 속성 변경
      
      if (blankBoardPos != nil && fallingGemPos != nil) {
        //CCLOG(@"Gem is falling down");
        
        NSValue *valueFrom_board = [_board objectForKey:fallingGemPos];
        ggBoardStruct bs;
        [valueFrom_board getValue:&bs];
        
        CCSprite *gemSpr = [bs.Gem getCCSprite];
        
        NSValue *targetValueFrom_board = [_board objectForKey:blankBoardPos];
        ggBoardStruct bs_blank;
        [targetValueFrom_board getValue:&bs_blank];
        
        bs_blank.Gem = bs.Gem;
        bs_blank.gemType = bs.gemType;
        //bs_blank.position = bs.position;
        bs_blank.isEmpty = NO;
        [_board setObject:[NSValue value:&bs_blank withObjCType:@encode(ggBoardStruct)] forKey:blankBoardPos];
        
        bs.Gem = nil;
        bs.gemType = 0;
        bs.isEmpty = YES;
        [_board setObject:[NSValue value:&bs withObjCType:@encode(ggBoardStruct)] forKey:fallingGemPos];
        
        // fallingGemPos -> blankBoardPos 애니메이션
        [gemSpr runAction:[CCSequence actions:
                           [CCDelayTime actionWithDuration:0.2f],
                           [CCMoveTo actionWithDuration:(0.2f) position:bs_blank.position],
                           nil]
         ];
        
        blankBoardPos = nil;
        fallingGemPos = nil;
        
      } else {
        //CCLOG(@"nil nil");
      }
      
      //
      
    } // of for h
  } // of for columns
  
  return colDic;
}

// Burst!
-(void) gemBurst:(NSMutableArray *)gems {
  for (NSValue *gemPos in gems) {
    //CGPoint pos = [gemPos CGPointValue];
    //CCLOG(@"butst:(%.f,%.f)", pos.x, pos.y);
    NSValue *valueFrom_board = [_board objectForKey:gemPos];
    ggBoardStruct bs;
    [valueFrom_board getValue:&bs];
    
    CCSprite *pong = [CCSprite spriteWithFile:@"pong.png"];
    
    //step1: 해당하는 Gem Sprite 를 날리고
    pong.position = [bs.Gem getCCSprite].position;
    [_thisCCLayer removeChild:[bs.Gem getCCSprite] cleanup:YES];
    //step2: 버스트 애니메이션
    
    //pong.position = [gemPos CGPointValue];
    [_thisCCLayer addChild:pong];
    id ac = [CCSequence actions:
             [CCRotateTo actionWithDuration:0.025f angle:-10],
             [CCRotateTo actionWithDuration:0.05f angle:10],
             [CCRotateTo actionWithDuration:0.05f angle:-10],
             [CCRotateTo actionWithDuration:0.05f angle:10],
             [CCDelayTime actionWithDuration:0.15f],
             [CCCallBlock actionWithBlock:^{ [_thisCCLayer removeChild:pong cleanup:YES]; }],
             nil];
    [pong runAction:ac];
    //step3: 구조체 reset
    bs.gemType = 0;
    bs.isEmpty = YES;
    [_board setObject:[NSValue value:&bs withObjCType:@encode(ggBoardStruct)] forKey:gemPos];
  }
}


// 재귀로 호출 될 함수
-(void) GemContinuous:(NSValue *)posAsNSValue gemType:(int)thisType refArray:(NSMutableArray* )gems fromBoard:(NSMutableDictionary *)tempBoard {
  //CCLOG(@"continuous check :GemType[%d](%.f,%.f)", thisType, [posAsNSValue CGPointValue].x, [posAsNSValue CGPointValue].y);

  if (![gems containsObject:posAsNSValue] && [self isSameGem:thisType withPos:posAsNSValue fromBoard:tempBoard]) {
    // 배열에 추가
    [gems addObject:posAsNSValue];
    
    CGPoint _posSeed = [posAsNSValue CGPointValue];
    NSValue *_pos;
    // 북쪽호출
    if (_posSeed.y != ggConfig.BoardHeight) {
      _pos = [NSValue valueWithCGPoint:CGPointMake(_posSeed.x, _posSeed.y + 1)];
      [self GemContinuous:_pos gemType:thisType refArray:gems fromBoard:tempBoard];
    }
    // 남쪽
    if (_posSeed.y != 1) {
    _pos = [NSValue valueWithCGPoint:CGPointMake(_posSeed.x, _posSeed.y - 1)];
    [self GemContinuous:_pos gemType:thisType refArray:gems fromBoard:tempBoard];
    }
    // 동
    if (_posSeed.x != ggConfig.BoardWidth) {
    _pos = [NSValue valueWithCGPoint:CGPointMake(_posSeed.x + 1, _posSeed.y)];
    [self GemContinuous:_pos gemType:thisType refArray:gems fromBoard:tempBoard];
    }
    // 서
    if (_posSeed.x != 1) {
    _pos = [NSValue valueWithCGPoint:CGPointMake(_posSeed.x - 1, _posSeed.y)];
    [self GemContinuous:_pos gemType:thisType refArray:gems fromBoard:tempBoard];
    }
  }
}

-(BOOL) isSameGem:(int)thisType withPos:(NSValue *)posAsNSValue fromBoard:(NSMutableDictionary *)tempBoard {
  NSValue *valueFrom_board = [tempBoard objectForKey:posAsNSValue];
  ggBoardStruct bs;
  [valueFrom_board getValue:&bs];
  //CCLOG(@"isSameGem: thisGem[%d] vs SeedGem[%d]", bs.gemType, thisType);
  if (bs.gemType == thisType) {
    return YES;
  } else {
    return NO;
  }
}

@end