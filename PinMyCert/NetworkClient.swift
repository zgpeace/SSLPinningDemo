/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
  case users
  
  static let baseURLString = "https://api.stackexchange.com/2.2"
  
  func asURLRequest() throws -> URLRequest {
    let path: String
    switch self {
    case .users:
      path = "/users?order=desc&sort=reputation&site=stackoverflow"
    }
    
    let url = URL(string: Router.baseURLString + path)!
    return URLRequest(url: url)
  }
}

final class NetworkClient {
  // 1
  let evaluators = [
    "api.stackexchange.com":
      PinnedCertificatesTrustEvaluator(certificates: [
        Certificates.stackExchange
      ])
  ]
  
  let session: Session
  
  // 2
  private init() {
    session = Session(
      serverTrustManager: ServerTrustManager(evaluators: evaluators)
    )
  }
  
  // MARK: - Static Definitions
  
  private static let shared = NetworkClient()
  
  static func request(_ convertible: URLRequestConvertible) -> DataRequest {
    return shared.session.request(convertible)
  }
}

struct Certificates {
  static let stackExchange = Certificates.certificate(filename: "stackexchange.com")
  
  private static func certificate(filename: String) -> SecCertificate {
    let filePath = Bundle.main.path(forResource: filename, ofType: "der")!
    let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
    let certificate = SecCertificateCreateWithData(nil, data as CFData)!
    
    return certificate
  }
}

