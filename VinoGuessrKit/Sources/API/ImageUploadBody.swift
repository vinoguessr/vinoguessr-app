public import Foundation
import HTTPTypes
import MultipartKit

extension API {
  /// The `multipart/form-data` body a Cloudflare Images direct-upload URL expects:
  /// a single `file` part carrying the raw image bytes.
  public static func imageUploadBody(for data: Data, boundary: String) -> Data {
    let headerFields: HTTPFields = [
      HTTPField.Name("Content-Disposition")!: "form-data; name=\"file\"; filename=\"image\"",
      HTTPField.Name("Content-Type")!: "application/octet-stream",
    ]
    let part = MultipartPart<[UInt8]>(headerFields: headerFields, body: [UInt8](data))
    var writer = MemoryMultipartWriter<[UInt8]>(boundary: boundary)
    writer.writePart(part)
    writer.finish()
    return Data(writer.getResult())
  }
}
