import Foundation
import Testing
@testable import API

/// Offline tests for the body sent to the Cloudflare Images direct-upload URL.
@Suite
struct ImageUploadBodyTests {
  @Test
  func bodyIsASingleFilePartWithTheRawBytes() {
    let data = Data([0x00, 0xFF, 0x0D, 0x0A, 0x42])
    let body = API.imageUploadBody(for: data, boundary: "Boundary-TEST")

    var expected = Data()
    expected.append(contentsOf: Array("--Boundary-TEST\r\n".utf8))
    expected.append(contentsOf: Array("Content-Disposition: form-data; name=\"file\"; filename=\"image\"\r\n".utf8))
    expected.append(contentsOf: Array("Content-Type: application/octet-stream\r\n".utf8))
    expected.append(contentsOf: Array("\r\n".utf8))
    expected.append(data)
    expected.append(contentsOf: Array("\r\n--Boundary-TEST--\r\n".utf8))
    #expect(body == expected)
  }

  @Test
  func emptyImageStillProducesATerminatedMessage() {
    let body = API.imageUploadBody(for: Data(), boundary: "B")
    #expect(String(decoding: body, as: UTF8.self) == "--B\r\nContent-Disposition: form-data; name=\"file\"; filename=\"image\"\r\nContent-Type: application/octet-stream\r\n\r\n\r\n--B--\r\n")
  }
}
