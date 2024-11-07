//
//  ImageAnalysisVO.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 11/6/24.
//
import Foundation

public struct OCRResultVO {
    let boundingBoxes: [CGRect]
    let ssid: String
    let password: String
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
