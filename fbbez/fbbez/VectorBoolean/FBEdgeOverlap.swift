//
//  FBEdgeOverlap.swift
//  Swift VectorBoolean for iOS
//
//  Based on part of FBContourOverlap - Created by Andrew Finnell on 11/7/12.
//  Copyright (c) 2012 Fortunate Bear, LLC. All rights reserved.
//
//  Created by Leslie Titze on 2015-07-02.
//  Copyright (c) 2015 Leslie Titze. All rights reserved.
//

import UIKit

let FBOverlapThreshold = isRunningOn64BitDevice ? 1e-2 : 1e-1

class FBEdgeOverlap {
  var edge1 : FBBezierCurve
  var edge2 : FBBezierCurve
  fileprivate var _range : FBBezierIntersectRange

  var range : FBBezierIntersectRange {
    return _range
  }

  init(range: FBBezierIntersectRange, edge1: FBBezierCurve, edge2: FBBezierCurve) {
    _range = range
    self.edge1 = edge1
    self.edge2 = edge2
  }

  //- (BOOL) fitsBefore:(FBEdgeOverlap *)nextOverlap
  func fitsBefore(_ nextOverlap: FBEdgeOverlap) -> Bool {
    if FBAreValuesCloseWithOptions(range.parameterRange1.maximum, value2: 1.0, threshold: FBOverlapThreshold) {
      // nextOverlap should start at 0 of the next edge
      let nextEdge = edge1.next
      return nextOverlap.edge1 == nextEdge && FBAreValuesCloseWithOptions(nextOverlap.range.parameterRange1.minimum, value2: 0.0, threshold: FBOverlapThreshold)
    }

    // nextOverlap should start at about maximum on the same edge
    return nextOverlap.edge1 == edge1 && FBAreValuesCloseWithOptions(nextOverlap.range.parameterRange1.minimum, value2: range.parameterRange1.maximum, threshold: FBOverlapThreshold)
  }

  //- (BOOL) fitsAfter:(FBEdgeOverlap *)previousOverlap
  func fitsAfter(_ previousOverlap: FBEdgeOverlap) -> Bool {
    if FBAreValuesCloseWithOptions(range.parameterRange1.minimum, value2: 0.0, threshold: FBOverlapThreshold) {
      // previousOverlap should end at 1 of the previous edge
      let previousEdge = edge1.previous

      return previousOverlap.edge1 == previousEdge && FBAreValuesCloseWithOptions(previousOverlap.range.parameterRange1.maximum, value2: 1.0, threshold: FBOverlapThreshold)
    }

    // previousOverlap should end at about the minimum on the same edge
    return previousOverlap.edge1 == edge1 && FBAreValuesCloseWithOptions(previousOverlap.range.parameterRange1.maximum, value2: range.parameterRange1.minimum, threshold: FBOverlapThreshold)
  }

  //- (void) addMiddleCrossing
  func addMiddleCrossing()
  {
    let intersection = _range.middleIntersection

    let ourCrossing = FBEdgeCrossing(intersection: intersection)
    let theirCrossing = FBEdgeCrossing(intersection: intersection)

    ourCrossing.counterpart = theirCrossing
    theirCrossing.counterpart = ourCrossing

    ourCrossing.fromCrossingOverlap = true
    theirCrossing.fromCrossingOverlap = true

    edge1.addCrossing(ourCrossing)
    edge2.addCrossing(theirCrossing)
  }

  //- (BOOL) doesContainParameter:(CGFloat)parameter onEdge:(FBBezierCurve *)edge startExtends:(BOOL)extendsBeforeStart endExtends:(BOOL)extendsAfterEnd
  func doesContainParameter(_ parameter: Double, onEdge edge:FBBezierCurve, startExtends extendsBeforeStart: Bool, endExtends extendsAfterEnd: Bool) -> Bool {

    // By the time this is called, we know the crossing is on one of our edges.
    if extendsBeforeStart && extendsAfterEnd {
      // The crossing is on the edge somewhere,
      // and the overlap extends past this edge in both directions,
      // so it's safe to say the crossing is contained
      return true
    }

    var parameterRange : FBRange
    if edge == edge1 {
      parameterRange = _range.parameterRange1
    } else {
      parameterRange = _range.parameterRange2
    }

    let inLeftSide = extendsBeforeStart ? parameter >= 0.0 : parameter > parameterRange.minimum
    let inRightSide = extendsAfterEnd ? parameter <= 1.0 : parameter < parameterRange.maximum

    return inLeftSide && inRightSide
  }
}
