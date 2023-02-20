import UIKit
import SQLite3

class ContactListVC: UITableViewController {

    var db: OpaquePointer?
    var dataSource = [UserData] ()
    override func viewDidLoad() {
        super.viewDidLoad()
        db = openConnection()
        query(db: db)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createInsertAlert))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit , target: self, action: #selector(createDeletAlert))
    }
}

//MARK :- table extensions
extension ContactListVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell")
        cell?.textLabel?.text = "\(dataSource[indexPath.row].id!) -> \(dataSource[indexPath.row].name!)"
        return cell!
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
}


