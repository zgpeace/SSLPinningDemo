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

import UIKit
import Alamofire

class ViewController: UIViewController {
  @IBOutlet var tableView: UITableView!
  
  private var selectedUser: User?
  
  var users: [User] = [] {
    didSet {
      tableView.isHidden = false
      tableView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Stack Overflow Users"
    
    tableView.isHidden = true
    tableView.dataSource = self
    
    NetworkClient.request(Router.users)
      .responseDecodable { (response: DataResponse<UserList>) in
        switch response.result {
        case .success(let value):
          self.users = value.users
        case .failure(let error):
          let isServerTrustEvaluationError = error.asAFError?.isServerTrustEvaluationError ?? false
          let message: String
          if isServerTrustEvaluationError {
            message = "Certificate Pinning Error"
          } else {
            message = error.localizedDescription
          }
          self.presentError(withTitle: "Oops!", message: message)
        }
      }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetailSegue",
      let destination = segue.destination as? DetailViewController,
      let cell = sender as? UITableViewCell,
      let indexPath = tableView.indexPath(for: cell) {
      destination.user = users[indexPath.item]
      cell.isSelected = false
    }
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return users.count
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                             for: indexPath)
    cell.textLabel?.text = users[indexPath.item].displayName
    return cell
  }
}
