//
//  MPAdServerCommunicator.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPAdServerCommunicatorSKZ.h"

#import "MPAdConfigurationSKZ.h"
#import "MPLogging.h"
#import "MPInstanceProviderSKZ.h"

const NSTimeInterval kRequestTimeoutInterval = 10.0;

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPAdServerCommunicatorSKZ ()

@property (nonatomic, assign, readwrite) BOOL loading;
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSDictionary *responseHeaders;

- (NSError *)errorForStatusCode:(NSInteger)statusCode;
- (NSURLRequest *)adRequestForURL:(NSURL *)URL;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPAdServerCommunicatorSKZ

@synthesize delegate = _delegate;
@synthesize URL = _URL;
@synthesize connection = _connection;
@synthesize responseData = _responseData;
@synthesize responseHeaders = _responseHeaders;
@synthesize loading = _loading;

- (id)initWithDelegate:(id<MPAdServerCommunicatorDelegateSKZ>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [self.connection cancel];

}

#pragma mark - Public

- (void)loadURL:(NSURL *)URL
{
    [self cancel];
    self.URL = URL;
    self.connection = [NSURLConnection connectionWithRequest:[self adRequestForURL:URL]
                                                    delegate:self];
    self.loading = YES;
}

- (void)cancel
{
    self.loading = NO;
    [self.connection cancel];
    self.connection = nil;
    self.responseData = nil;
    self.responseHeaders = nil;
}

#pragma mark - NSURLConnection delegate (NSURLConnectionDataDelegate in iOS 5.0+)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response respondsToSelector:@selector(statusCode)]) {
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        if (statusCode >= 400) {
            [connection cancel];
            self.loading = NO;
            [self.delegate communicatorDidFailWithError:[self errorForStatusCode:statusCode]];
            return;
        }
    }

    self.responseData = [NSMutableData data];
    self.responseHeaders = [(NSHTTPURLResponse *)response allHeaderFields];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.loading = NO;
    [self.delegate communicatorDidFailWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    MPAdConfigurationSKZ *configuration = [[MPAdConfigurationSKZ alloc]
                                         initWithHeaders:self.responseHeaders
                                         data:self.responseData];
    self.loading = NO;
    [self.delegate communicatorDidReceiveAdConfiguration:configuration];
}

#pragma mark - Internal

- (NSError *)errorForStatusCode:(NSInteger)statusCode
{
    NSString *errorMessage = [NSString stringWithFormat:@"MoPub returned status code %ld.",
                              (long)statusCode];
    NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:errorMessage
                                                          forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"mopub.com" code:statusCode userInfo:errorInfo];
}

- (NSURLRequest *)adRequestForURL:(NSURL *)URL
{
    NSMutableURLRequest *request = [[MPInstanceProviderSKZ sharedProvider] buildConfiguredURLRequestWithURL:URL];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:kRequestTimeoutInterval];
    return request;
}

@end