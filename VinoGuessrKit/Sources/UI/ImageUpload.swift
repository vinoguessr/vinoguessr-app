import Foundation
import API

enum ImageUploadError: Error {
  case uploadFailed
}

extension API {
  /// Uploads image bytes and returns the registered image's identifier, for use
  /// as an event's or profile's `imageID`.
  ///
  /// The upload URL returned by `createImageUploadURL()` is a Cloudflare Images
  /// direct-upload endpoint, which expects a `multipart/form-data` POST with a
  /// `file` field, built by `imageUploadBody(for:boundary:)`. After the bytes are
  /// uploaded, the image is registered via `createImage(_:)`.
  func uploadImage(_ data: Data) async throws -> UUID {
    let upload = try await createImageUploadURL()

    let boundary = "Boundary-\(UUID().uuidString)"
    let body = Self.imageUploadBody(for: data, boundary: boundary)

    var request = URLRequest(url: upload.uploadURL)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    let (_, response) = try await URLSession.shared.upload(for: request, from: body)
    guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
      throw ImageUploadError.uploadFailed
    }

    let image = try await createImage(CreateImageRequest(imageID: upload.imageID))
    return image.id
  }
}
