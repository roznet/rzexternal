//  MIT Licence
//
//  Created on 17/03/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//  

@import Foundation;
@import CoreLocation;

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^shapeMatchingFunc)(NSDictionary<NSString*,id>*obj);

@interface RZShapeFile : NSObject

@property (nonatomic,strong,nullable) NSString * lastErrorMessage;

+(RZShapeFile*)shapeFileWithBase:(NSString*)base;
-(NSIndexSet*)indexSetForShapeMatching:(shapeMatchingFunc)match;
-(NSIndexSet*)indexSetForShapeContainingOrClosest:(CLLocationCoordinate2D)coord;
-(NSIndexSet*)indexSetForShapeContaining:(CLLocationCoordinate2D)coord;
-(NSArray*)polygonsForIndexSet:(NSIndexSet*)idxset;
-(NSArray<NSDictionary<NSString*,id>*>*)allShapes;

-(NSString*)fileBaseName;

@end

NS_ASSUME_NONNULL_END
