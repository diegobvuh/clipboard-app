import Foundation
import UIKit
import Vision

/// Reads text from a user-selected photo locally. Recognition is advisory and
/// never modifies a price, receipt total, or garment description automatically.
enum TextRecognition {
    enum RecognitionError: LocalizedError {
        case invalidImage
        var errorDescription: String? { "This photo could not be read. Try another photo." }
    }

    static func recognize(_ data: Data) async throws -> String {
        try await Task.detached(priority: .userInitiated) {
            guard let image = UIImage(data: data)?.cgImage else { throw RecognitionError.invalidImage }
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false
            try VNImageRequestHandler(cgImage: image).perform([request])
            return (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
        }.value
    }
}
