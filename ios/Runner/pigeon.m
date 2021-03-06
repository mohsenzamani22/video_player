// Autogenerated from Pigeon (v0.1.23), do not edit directly.
// See also: https://pub.dev/packages/pigeon
#import "pigeon.h"
#import <Flutter/Flutter.h>

#if !__has_feature(objc_arc)
#error File requires ARC to be enabled.
#endif

static NSDictionary<NSString*, id>* wrapResult(NSDictionary *result, FlutterError *error) {
  NSDictionary *errorDict = (NSDictionary *)[NSNull null];
  if (error) {
    errorDict = @{
        @"code": (error.code ? error.code : [NSNull null]),
        @"message": (error.message ? error.message : [NSNull null]),
        @"details": (error.details ? error.details : [NSNull null]),
        };
  }
  return @{
      @"result": (result ? result : [NSNull null]),
      @"error": errorDict,
      };
}

@interface TextureMessage ()
+(TextureMessage*)fromMap:(NSDictionary*)dict;
-(NSDictionary*)toMap;
@end
@interface CreateMessage ()
+(CreateMessage*)fromMap:(NSDictionary*)dict;
-(NSDictionary*)toMap;
@end
@interface LoopingMessage ()
+(LoopingMessage*)fromMap:(NSDictionary*)dict;
-(NSDictionary*)toMap;
@end
@interface VolumeMessage ()
+(VolumeMessage*)fromMap:(NSDictionary*)dict;
-(NSDictionary*)toMap;
@end
@interface PlaybackSpeedMessage ()
+(PlaybackSpeedMessage*)fromMap:(NSDictionary*)dict;
-(NSDictionary*)toMap;
@end
@interface PositionMessage ()
+(PositionMessage*)fromMap:(NSDictionary*)dict;
-(NSDictionary*)toMap;
@end
@interface MixWithOthersMessage ()
+(MixWithOthersMessage*)fromMap:(NSDictionary*)dict;
-(NSDictionary*)toMap;
@end

@implementation TextureMessage
+(TextureMessage*)fromMap:(NSDictionary*)dict {
  TextureMessage* result = [[TextureMessage alloc] init];
  result.textureId = dict[@"textureId"];
  if ((NSNull *)result.textureId == [NSNull null]) {
    result.textureId = nil;
  }
  return result;
}
-(NSDictionary*)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.textureId ? self.textureId : [NSNull null]), @"textureId", nil];
}
@end

@implementation CreateMessage
+(CreateMessage*)fromMap:(NSDictionary*)dict {
  CreateMessage* result = [[CreateMessage alloc] init];
  result.asset = dict[@"asset"];
  if ((NSNull *)result.asset == [NSNull null]) {
    result.asset = nil;
  }
  result.uri = dict[@"uri"];
  if ((NSNull *)result.uri == [NSNull null]) {
    result.uri = nil;
  }
  result.packageName = dict[@"packageName"];
  if ((NSNull *)result.packageName == [NSNull null]) {
    result.packageName = nil;
  }
  result.formatHint = dict[@"formatHint"];
  if ((NSNull *)result.formatHint == [NSNull null]) {
    result.formatHint = nil;
  }
  result.httpHeaders = dict[@"httpHeaders"];
  if ((NSNull *)result.httpHeaders == [NSNull null]) {
    result.httpHeaders = nil;
  }
  return result;
}
-(NSDictionary*)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.asset ? self.asset : [NSNull null]), @"asset", (self.uri ? self.uri : [NSNull null]), @"uri", (self.packageName ? self.packageName : [NSNull null]), @"packageName", (self.formatHint ? self.formatHint : [NSNull null]), @"formatHint", (self.httpHeaders ? self.httpHeaders : [NSNull null]), @"httpHeaders", nil];
}
@end

@implementation LoopingMessage
+(LoopingMessage*)fromMap:(NSDictionary*)dict {
  LoopingMessage* result = [[LoopingMessage alloc] init];
  result.textureId = dict[@"textureId"];
  if ((NSNull *)result.textureId == [NSNull null]) {
    result.textureId = nil;
  }
  result.isLooping = dict[@"isLooping"];
  if ((NSNull *)result.isLooping == [NSNull null]) {
    result.isLooping = nil;
  }
  return result;
}
-(NSDictionary*)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.textureId ? self.textureId : [NSNull null]), @"textureId", (self.isLooping ? self.isLooping : [NSNull null]), @"isLooping", nil];
}
@end

@implementation VolumeMessage
+(VolumeMessage*)fromMap:(NSDictionary*)dict {
  VolumeMessage* result = [[VolumeMessage alloc] init];
  result.textureId = dict[@"textureId"];
  if ((NSNull *)result.textureId == [NSNull null]) {
    result.textureId = nil;
  }
  result.volume = dict[@"volume"];
  if ((NSNull *)result.volume == [NSNull null]) {
    result.volume = nil;
  }
  return result;
}
-(NSDictionary*)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.textureId ? self.textureId : [NSNull null]), @"textureId", (self.volume ? self.volume : [NSNull null]), @"volume", nil];
}
@end

@implementation PlaybackSpeedMessage
+(PlaybackSpeedMessage*)fromMap:(NSDictionary*)dict {
  PlaybackSpeedMessage* result = [[PlaybackSpeedMessage alloc] init];
  result.textureId = dict[@"textureId"];
  if ((NSNull *)result.textureId == [NSNull null]) {
    result.textureId = nil;
  }
  result.speed = dict[@"speed"];
  if ((NSNull *)result.speed == [NSNull null]) {
    result.speed = nil;
  }
  return result;
}
-(NSDictionary*)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.textureId ? self.textureId : [NSNull null]), @"textureId", (self.speed ? self.speed : [NSNull null]), @"speed", nil];
}
@end

@implementation PositionMessage
+(PositionMessage*)fromMap:(NSDictionary*)dict {
  PositionMessage* result = [[PositionMessage alloc] init];
  result.textureId = dict[@"textureId"];
  if ((NSNull *)result.textureId == [NSNull null]) {
    result.textureId = nil;
  }
  result.position = dict[@"position"];
  if ((NSNull *)result.position == [NSNull null]) {
    result.position = nil;
  }
  return result;
}
-(NSDictionary*)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.textureId ? self.textureId : [NSNull null]), @"textureId", (self.position ? self.position : [NSNull null]), @"position", nil];
}
@end

@implementation MixWithOthersMessage
+(MixWithOthersMessage*)fromMap:(NSDictionary*)dict {
  MixWithOthersMessage* result = [[MixWithOthersMessage alloc] init];
  result.mixWithOthers = dict[@"mixWithOthers"];
  if ((NSNull *)result.mixWithOthers == [NSNull null]) {
    result.mixWithOthers = nil;
  }
  return result;
}
-(NSDictionary*)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.mixWithOthers ? self.mixWithOthers : [NSNull null]), @"mixWithOthers", nil];
}
@end

void VideoPlayerApiSetup(id<FlutterBinaryMessenger> binaryMessenger, id<VideoPlayerApi> api) {
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.VideoPlayerApi.initialize"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        [api initialize:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.VideoPlayerApi.create"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        CreateMessage *input = [CreateMessage fromMap:message];
        FlutterError *error;
        TextureMessage *output = [api create:input error:&error];
        callback(wrapResult([output toMap], error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.VideoPlayerApi.dispose"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        TextureMessage *input = [TextureMessage fromMap:message];
        FlutterError *error;
        [api dispose:input error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.VideoPlayerApi.setLooping"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        LoopingMessage *input = [LoopingMessage fromMap:message];
        FlutterError *error;
        [api setLooping:input error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.VideoPlayerApi.setVolume"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        VolumeMessage *input = [VolumeMessage fromMap:message];
        FlutterError *error;
        [api setVolume:input error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.VideoPlayerApi.setPlaybackSpeed"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        PlaybackSpeedMessage *input = [PlaybackSpeedMessage fromMap:message];
        FlutterError *error;
        [api setPlaybackSpeed:input error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.VideoPlayerApi.play"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        TextureMessage *input = [TextureMessage fromMap:message];
        FlutterError *error;
        [api play:input error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.VideoPlayerApi.position"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        TextureMessage *input = [TextureMessage fromMap:message];
        FlutterError *error;
        PositionMessage *output = [api position:input error:&error];
        callback(wrapResult([output toMap], error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.VideoPlayerApi.seekTo"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        PositionMessage *input = [PositionMessage fromMap:message];
        FlutterError *error;
        [api seekTo:input error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.VideoPlayerApi.pause"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        TextureMessage *input = [TextureMessage fromMap:message];
        FlutterError *error;
        [api pause:input error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.VideoPlayerApi.setMixWithOthers"
        binaryMessenger:binaryMessenger];
    if (api) {
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        MixWithOthersMessage *input = [MixWithOthersMessage fromMap:message];
        FlutterError *error;
        [api setMixWithOthers:input error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
}
