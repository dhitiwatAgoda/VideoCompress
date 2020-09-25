#import "Utility.h"

@implementation Utility

+ (NSString *)basePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *tempPath = NSTemporaryDirectory();
    NSString *path = [tempPath stringByAppendingString:@"video_compress"];
    
    if (![fileManager fileExistsAtPath:path]){
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:true attributes:nil error:nil];
    }
    return path;
}

+ (NSString *)excludeFileProtocol:(NSString *)path {
    return [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
}

+ (NSURL *)getPathUrl:(NSString *)path {
    return [NSURL fileURLWithPath:[self excludeFileProtocol:path]];
}

+ (NSString *)getFileName:(NSString *)path {
    return [[path lastPathComponent] stringByDeletingPathExtension];
}

+ (void)deleteFile:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [self getPathUrl:path];
    [fileManager removeItemAtURL:url error:nil];
}

+ (NSString *)keyValueToJson:(NSDictionary *)keyAndValue {
    NSData *data = [NSJSONSerialization dataWithJSONObject:keyAndValue options:NSJSONWritingFragmentsAllowed error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
