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
