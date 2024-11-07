//
//  ImageAnalysisVO.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/6/24.
//
import Foundation

public struct OCRResultVO {
    let ssidBoundingBox: CGRect?
    let passwordBoundingBox: CGRect?
    let ssid: String?
    let password: String?

    var boundingBoxes: [CGRect] {
        var boxes: [CGRect] = []
        if let ssidBoundingBox { boxes.append(ssidBoundingBox) }
        if let passwordBoundingBox { boxes.append(passwordBoundingBox) }
        return boxes
    }
}

public struct KeywordBox {
    let label: String
    let content: String
    let contentBox: CGRect
    let labelBox: CGRect
    let index: Int?
}

struct ExtractedBoxes {
    let idBoxes: [KeywordBox]
    let pwBoxes: [KeywordBox]
    let otherBoxes: [(rect: CGRect, text: String)]
}
