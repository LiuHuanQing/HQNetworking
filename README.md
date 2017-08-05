# HQNetworking
一个与业务层结合的网络层.

会逐步更新README

使用子类重写**requestURL**的思路是为了把请求路径**锁死**在这个地方,等于在编码上统一规范


> 刚从内网gitlab转过来,没上pod,很多东西暂时没有

具体用法:
```objc
/**
 *  所有请求的父类,所有子类需要继承他
 *  说明:
 *  requestParams:默认请求参数获取接口,若子类含有@property属性,会将所有属性转为NSDictionary作为请求参数
 *              (!注:requestParams或者property会优先作为Restful的参数,不能作为请求参数)
 *  requestURL:请求路径,支持Restful方式,/v1/weather/:city
 *
 *  例:
 *  接口GET:/v1/weather/:city  参数:time = 时间戳
 *  @interface WeatherAPI : HQBaseAPI
 *  @property (nonatomic, strong) NSString *city;
 *  @property (nonatomic, assign) long long time;
 *  @end
 */
@interface HQBaseAPI : NSObject

///设置请求流程中额外处理
- (void)setAopDelegate:(id <HQAOPDelegate> __nonnull)aopDelegate;
- (id <HQAOPDelegate> _Nullable)aopDelegate;

///baseURL
- (NSString * __nonnull)baseURL;

///请求路径
- (NSString * __nonnull)requestURL;

///请求方式 默认:HQRequestMethodGET
- (HQRequestMethod)requestMethod;

///请求的序列化格式 默认:HQRequestSerializerTypeJSON
- (HQRequestSerializerType)requestSerializerType;

///响应的序列化格式 默认:HQResponseSerializerTypeJSON
- (HQResponseSerializerType)responseSerializerType;

///请求的参数: 优先使用子类的requestParams,否则将子类属性(@property)转为NSDictionary
- (NSDictionary * __nullable)requestParams;

///请求头信息
- (NSDictionary * __nullable)HTTPHeaderFields;

///额外的请求头信息(父类持续继承)
- (NSDictionary * __nullable)extraHTTPHeaderFields NS_REQUIRES_SUPER;


///HTTP 请求超时的时间
- (NSTimeInterval)requestTimeoutInterval;

///响应可接受的内容类型
- (nullable NSSet *)responseAcceptableContentTypes;

///设置请求完成的处理
- (void)setCompleteHandler:(__nullable HQAPICompleteHandler)completeHandler;

///请求完成的处理
- (__nullable HQAPICompleteHandler)completeHandler;

///设置POST请求组成Body结构的Block
- (void)setConstructingBodyBlock:(HQRequestConstructingBodyBlock _Nonnull )constructingBodyBlock;

///POST请求组成Body结构的Block
- (__nullable HQRequestConstructingBodyBlock)constructingBodyBlock;

///Progress进度
- (void)setProgressBlock:(HQProgressBlock _Nonnull )progressBlock;
- (__nullable HQProgressBlock)progressBlock;


///请求的唯一标识
- (NSUInteger)identifier;

///暴露这个为了直接使用taskIdentifier,正常应该自动生成
- (void)setIdentifier:(NSUInteger)identifier;

///主线程回调completeHandler,默认YES
- (BOOL)mainThreadCompleteHandler;

/**
 *  ORM解析配置 默认:nil 返回结果完整的responseObject
 *  ******************************************************
 *  ***当你指定了映射后只返回对应结果
 *  ******************************************************
 *  ***非必要情况下请不要自行解析responseObject
 *  ******************************************************
 *  ***解析逻辑:Dictionary->Model, Array-> ModelArray
 *  ******************************************************
 *  示例:
 *      服务端返回 { code : 0, data : { user : obj }, { topic: obj } }
 *      responseResultMapping内容应为 @{ @"/data/user": @"UserModel", @"/data/user" : @"TopicModel" }
 *      completeHandler result的结果为 @{ @"/data/user": UserModel, @"/data/user" : TopicModel }
 *
 *  @return 返回响应结果
 */
- (NSDictionary *__nullable)responseResultMapping;

///额外ORM解析配置(父类持续继承)
- (NSDictionary *__nullable)extraResponseResultMapping NS_REQUIRES_SUPER;

///启动请求
- (void)start;

///停止请求
- (void)stop;

@end
```
