//
//  LevenstienDistance.swift
//  SymbolSearch
//
//  Created by Joshua Homann on 9/18/22.
//

import Foundation

func levenshteinDistance(_ lhs: String, _ rhs: String) -> Int {
    var left = lhs
    var right = rhs
    if right.count > left.count {
        swap(&left, &right)
    }
    let height = left.count
    let width = right.count
    var row = (0..<width).map { $0 + 1 }
    var leftIndex = left.startIndex
    for y in 0..<height {
        var previousDiagonal = y
        var previous = y + 1
        var rightIndex = right.startIndex
        for x in 0..<width {
            let top = row[x]
            let substitutionCost = left[leftIndex] == right[rightIndex] ? 0 : 1
            row[x] = min(
                previous + 1,
                top + 1,
                previousDiagonal + substitutionCost
            )
            previous = row[x]
            previousDiagonal = top
            rightIndex = right.index(after: rightIndex)
        }
        leftIndex = left.index(after: leftIndex)
    }
    return row.last ?? 0
}
