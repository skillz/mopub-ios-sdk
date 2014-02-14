//
// Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MRImageDownloaderDelegateSKZ;

@interface MRImageDownloaderSKZ : NSObject

@property (nonatomic, weak) id<MRImageDownloaderDelegateSKZ> delegate;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableDictionary *pendingOperations;

- (id)initWithDelegate:(id<MRImageDownloaderDelegateSKZ>)delegate;
- (void)downloadImageWithURL:(NSURL *)URL;

@end

@protocol MRImageDownloaderDelegateSKZ <NSObject>

@required
- (void)downloaderDidFailToSaveImageWithURL:(NSURL *)URL error:(NSError *)error;

@end
