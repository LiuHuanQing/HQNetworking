# HQNetworking
使用YYModel+AFNetwork实现的业务层结合的网络层
特点
===
-  `一一对应`:每一个网络请求都是一个对象
-  `所见所得`:每一个对象属性就是接口参数
-  `规范代码`:所有请求配置必须重写父类方法
-  `依赖隔离`:与具体请求核心方法隔离
示例
===

##### 1.假设我们有一个接口是这样的
```
查询城市某时刻天气
域名:http://www.weather.com
接口:/v1/weather/:city
参数: {time:时间戳}
返回:
{"data":{"ts":1501570800000,"pres":1004,"tmp":28.5,"hcdc":100,"rh":85,"lcdc":0,"mcdc":0,"mm":0,"snow":0,"tcdc":"100","wdir":190,"gust":21,"wind":16.8,"wave":1.41,"dirpw":163,"perpw":8,"swdir2":0,"swell2":0,"swper2":0,"swdir1":91,"swell1":0.29,"swper1":10,"wvdir":167,"wvper":8,"sst":28.89,"vis":"17248"},"update":1501582720686,"code":0}

```

##### 2.我们创建这样一个api class
```objc
@interface WeatherAPI : HQBaseAPI
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSNumber *time;
@end

@implementation WeatherAPI
//域名,请求头设置最好写一个BaseAPI统一处理
- (NSString *)baseURL
{
    return @"http://www.weather.com";
}

- (NSDictionary *)HTTPHeaderFields
{
    NSMutableDictionary *dict = [[super HTTPHeaderFields] mutableCopy];
    [dict setObject:@"UA!!!" forKey:@"User-Agent"];
    return dict;
}

- (HQRequestMethod)requestMethod
{
    return HQRequestMethodGET;
}

- (NSString *)requestURL
{
    return @"/v1/weather/:city";
}

//处理响应体里面data参数
- (NSDictionary *)responseResultMapping
{
    return @{@"/data":@"WeatherModel"};
}
@end
```
##### 3.使用它
```objc
    WeatherAPI *api = [WeatherAPI new];

    
    [api setCompleteHandler:^(NSDictionary *result, NSError *error)     {
        if(!error)
        {
            //responseResultMapping方法会使用YYModel解析响应体的数据
            //不过在这之前需要你配置好
            WeatherModel *w = result[@"/data"];
            ...
        }
    }];
    [api start];

```
##### 4.更多方法请参考HQBaseAPI.h中的头文件.有很详细的注释

安装
===
    pod 'HQNetworking', '~> 1.0.0'
