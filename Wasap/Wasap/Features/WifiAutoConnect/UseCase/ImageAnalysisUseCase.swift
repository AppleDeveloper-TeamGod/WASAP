//
//  ImageAnalysisUseCase.swift
//  Wasap
//
//  Created by Chang Jonghyeon on 10/6/24.
//

import RxSwift
import UIKit


public protocol ImageAnalysisUseCase {
    func performOCR(on image: UIImage) -> Single<(UIImage, String, String)>
    func performOCR(on image: UIImage) -> Single<(boxes: [CGRect], ssid: String, password: String)>
}

public class DefaultImageAnalysisUseCase: ImageAnalysisUseCase {
    let imageAnalysisRepository: ImageAnalysisRepository

    public init(imageAnalysisRepository: ImageAnalysisRepository) {
        self.imageAnalysisRepository = imageAnalysisRepository
    }

    public func performOCR(on image: UIImage) -> Single<(UIImage, String, String)> {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return Single.error(ImageAnalysisError.invalidImage)
        }

        return imageAnalysisRepository.performOCR(from: imageData)
            .map { [weak self] result in
                guard let self = self else { throw  ImageAnalysisError.boxDrawingFailed }

                let imageWithBoxes = self.drawBoundingBoxes(result.boundingBoxes, on: image)
                guard let renderedImage = imageWithBoxes else {
                    throw ImageAnalysisError.boxDrawingFailed
                }
                return (renderedImage, result.ssid, result.password)
            }
    }

    // bounding box를 이미지 위에 그리는 함수
    private func drawBoundingBoxes(_ boxes: [CGRect], on image: UIImage) -> UIImage? {
        let imageSize = image.size
        let renderer = UIGraphicsImageRenderer(size: imageSize)

        let renderedImage = renderer.image { context in
            // 원본 이미지를 배경으로 그림
            image.draw(at: .zero)

            for box in boxes {
                // 경계 상자를 그릴 컨텍스트 설정
                let cgContext = context.cgContext

                UIColor.primary200.setStroke()
                UIColor.primary200.withAlphaComponent(0.5).setFill()
                let rect = CGRect(
                    x: box.origin.x * imageSize.width,
                    y: (1 - box.origin.y - box.height) * imageSize.height,
                    width: box.width * imageSize.width,
                    height: box.height * imageSize.height
                )

                cgContext.fill(rect)
                cgContext.stroke(rect, width: 2.0)
            }
        }

        return renderedImage
    }

    public func performOCR(on image: UIImage) -> Single<(boxes: [CGRect], ssid: String, password: String)> {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return Single.error(ImageAnalysisError.invalidImage)
        }
        return imageAnalysisRepository.performOCR(from: imageData)
            .map { ocrResult in
                let convertedBoxes = ocrResult.boundingBoxes.map { box in
                    CGRect(
                        x: box.origin.x,
                        y: (1 - box.origin.y - box.height),
                        width: box.width,
                        height: box.height
                    )
                }
                return (convertedBoxes, ocrResult.ssid, ocrResult.password)
            }
    }
}
