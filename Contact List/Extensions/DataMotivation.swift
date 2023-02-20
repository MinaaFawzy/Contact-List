import UIKit
import SQLite3

extension ContactListVC {

    func openConnection() -> OpaquePointer? {
        var db: OpaquePointer?
        let fileUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil , create: false).appendingPathComponent("Contacts.sqlite")
        if (sqlite3_open(fileUrl?.path, &db) == SQLITE_OK) {
            print("succssfuly opened connection to database")
            return db
        } else {
            print("unable to opened database")
            return nil
        }
    }
    
     func createTable(db: OpaquePointer?) {
        let createTableString = """
        CREATE TABLE Contact(Id INT PRIMARY KEY NOT NULL , Name CHAR(255));
        """
        var CreateTableStatment: OpaquePointer?
        
        if sqlite3_prepare_v2(db, createTableString, -1, &CreateTableStatment, nil) == SQLITE_OK {
            if sqlite3_step(CreateTableStatment) == SQLITE_DONE {
                print("Contact table create")
            } else {
                print("Contact table is not create")
            }
        } else {
            print("Create table statment is not prepared")
        }
        sqlite3_finalize(CreateTableStatment)
    }
    
    func insertRow(id: Int32 , name: NSString ,db: OpaquePointer?) {
        let insertStatmentString = """
        INSERT INTO Contact(Id,Name) VALUES (?,?)
        """
        var insertStatment: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertStatmentString, -1, &insertStatment, nil) == SQLITE_OK {
            
            sqlite3_bind_int(insertStatment, 1, id)
            sqlite3_bind_text(insertStatment, 2, name.utf8String, -1, nil)
            
            if sqlite3_step(insertStatment) == SQLITE_DONE {
                showErrorMessage("Insert Row Succssfuly")
            } else {
                showErrorMessage("Cloud not insert row")
            }
        } else {
            print("insert statment is not prepared")
        }
        sqlite3_finalize(insertStatment)
    }

    func query(db: OpaquePointer?) {
        dataSource = []
        let queryString = """
        SELECT * FROM Contact
        """
        var queryStatment: OpaquePointer?
        
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatment, nil) == SQLITE_OK {
            while sqlite3_step(queryStatment) == SQLITE_ROW {
                    let id = sqlite3_column_int(queryStatment, 0)
                    guard let queryName = sqlite3_column_text(queryStatment, 1) else {
                        print("Error when retrive data")
                        return
                    }
                    let name = String(cString: queryName)
                    
                    
                let tempData: UserData = UserData(id: Int(id), name: name)
                dataSource.append(tempData)
                }
            self.tableView.reloadData()
            }else {
            let error = String(cString: sqlite3_errmsg(queryStatment))
            print("\(error)")
        }
            
       
        sqlite3_finalize(queryStatment)
    }

    func deleteRow(id: Int32, db: OpaquePointer?) {
        let deleteStatmentString = """
        DELETE FROM Contact WHERE Id = ?;
        """
        var deleteStatment: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteStatmentString , -1, &deleteStatment, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatment, 1, id)
            if sqlite3_step(deleteStatment) == SQLITE_DONE {
                showErrorMessage("Deleted Row Succssfuly")
            } else {
                showErrorMessage("Cloud not delete row")
            }
        } else {
            print("Delete statment is not prepared")
        }
        sqlite3_finalize(deleteStatment)
    }

    @objc func createInsertAlert() {
        let ac = UIAlertController(title: "Enter Contact", message: nil, preferredStyle: .alert)
        ac.addTextField { (tf) in
            tf.placeholder = "Enter Id"
        }
        ac.addTextField { (tf) in
            tf.placeholder = "Enter Name"
        }
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak ac, weak self] action in
            guard let id = ac?.textFields?[0].text else {
                return
            }
            guard let name = ac?.textFields?[1].text else {
                return
            }
            guard let idAsInt = Int32(id) else {return}
            self?.insertRow(id: idAsInt, name: name as NSString,db: self?.db)
            self?.query(db: self?.db)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }

    @objc func createDeletAlert() {
        let ac = UIAlertController(title: "Enter ID u need to delete", message: nil, preferredStyle: .alert)
        ac.addTextField { (tf) in
            tf.placeholder = "Enter Id"
        }
        let submitAction = UIAlertAction(title: "Delete", style: .default) { [weak ac, weak self] action in
            guard let id = ac?.textFields?[0].text else {
                return
            }
            guard let idAsInt = Int32(id) else {return}
            self?.deleteRow(id: idAsInt, db: self?.db)
            self?.query(db: self?.db)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    func showErrorMessage(_ errorMessage: String){
        let ac = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        let aleartAction = UIAlertAction(title: "Ok" , style: .default, handler: nil)
        ac.addAction(aleartAction)
        present(ac, animated: true)
    }
    
}
