//
//  DateCellTableViewController.swift
//  DateCell
//

import UIKit

class OrderAgainTableViewController: UITableViewController {
    
    let pickerAnimationDuration = 0.40 // duration for the animation to slide the date picker into view
    let datePickerTag           = 99   // view tag identifiying the date picker view
    
    let titleKey = "title" // key for obtaining the data source item's title
    let dateKey  = "date"  // key for obtaining the data source item's date value
    let valueKey = "value"
    // keep track of which rows have date cells
    let dateStartRow = 0
    let dateEndRow   = 0
    
    let detailCellID       = "detailCell"               // the cells which carry the date
    let detailEditCellID   = "detailEditCell"
    let datePickerCellID = "datePickerCell"             // the cell containing the date picker
    let removeProductCellID      = "removeProductCell"  // the cell to remove product
    let deliveryInstructionsCellID = "deliveryInstructionsCell" // the cell with delivery instructions
    
    var dataArray: [[String: AnyObject]] = []
    var dataArray1:
        [String: [[String: AnyObject]]] = ["": []]
    var headerDataArray = [String]()
    
    var dateFormatter = DateFormatter()
    
    // keep track which indexPath points to the cell with UIDatePicker
    var datePickerIndexPath: NSIndexPath?
    
    let pickerCellRowHeight: CGFloat = 216
    let deliveryInstructionsRowHeight: CGFloat = 132
    let tableViewRowHeight: CGFloat = 44
    let rowsForSection0 = 3
    let rowsForSectionGraterThan0 = 5
    
    @IBOutlet var pickerView: UIDatePicker!

    var tableContentInset = UIEdgeInsets()
    var selectedTextFieldIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataArray()
        dateFormatter.dateFormat = "h:mm a"
        addLocaleChangedObserver()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300.0
        
        hideKeyboard()

    }
    //Moves the view upwards when keyboard appears
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var contentInsets = self.tableView.contentInset
            contentInsets.bottom = keyboardSize.height
            tableContentInset = contentInsets
            guard let selIndPath = selectedTextFieldIndexPath,
                let cellFrame = self.tableView.cellForRow(at: selIndPath)?.frame
                else {
                    return
            }
            self.tableView.scrollRectToVisible(cellFrame, animated: true)
        }
    }
    @objc func keyboardWillHide(_ notification: NSNotification) {
        tableContentInset.bottom = 0
        self.tableView.contentInset = tableContentInset//contentInset
    }
    func addLocaleChangedObserver() {
        // if the local changes while in the background, we need to be notified so we can update the date
        // format in the table view cells
        //
        NotificationCenter.default.addObserver(self, selector: #selector(OrderAgainTableViewController.localeChanged(notif:)), name: NSLocale.currentLocaleDidChangeNotification, object: nil)
    }
    func loadDataArray() {
        // setup our data source
        // setup our data source
        let item00 = [titleKey: "Delivery Date", dateKey: NSDate()] as [String : Any]
        let item01 = [titleKey: "Purchase Order", valueKey: 23456 ] as [String : Any]
        let item02 = [titleKey: "Delivery Instructions"]
        //Section 1
        for index in 0...5 {
            let item10 = [titleKey: "Delivery Time", dateKey: NSDate()] as [String : Any]
            let item11 = [titleKey: "Quantity", valueKey: 6] as [String : Any]
            let item12 = [titleKey: "Slump(in)", valueKey: 7] as [String : Any]
            let item13 = [titleKey: "Spacing(min)", valueKey: 8] as [String : Any]
            let item14 = [titleKey: "Remove Product"]
            let datArr = [
                item10 as [String: AnyObject],
                item11 as [String: AnyObject],
                item12 as [String: AnyObject],
                item13 as [String: AnyObject],
                item14 as [String: AnyObject]
            ]
            dataArray1["\(index)"] = datArr
        }
        
        dataArray = [
            item00 as [String: AnyObject],
            item01 as [String: AnyObject],
            item02 as [String: AnyObject]
        ]
        let hItem0 = "Complete the form below to place this order again. Tap the fields to make modifications to the order details."
        let hItem1 = "Header 1"
        
        headerDataArray = [
            hItem0,
            hItem1,
            hItem1,
            hItem1,
            hItem1,
            hItem1,
            hItem1
        ]
    }
    // MARK: - Locale
    @objc func localeChanged(notif: NSNotification) {
    // the user changed the locale (region format) in Settings, so we are notified here to
    // update the date format in the table view cells
    //
        tableView.reloadData()
    }

    /*! Determines if the given indexPath has a cell below it with a UIDatePicker.
    @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
    */
    func hasPickerForIndexPath(indexPath: NSIndexPath) -> Bool {
        var hasDatePicker = false
        
        let targetedRow = indexPath.row + 1
        let checkDatePickerCell = tableView.cellForRow(at: IndexPath(row: targetedRow, section: indexPath.section))
        let checkDatePicker = checkDatePickerCell?.viewWithTag(datePickerTag)
        
        hasDatePicker = checkDatePicker != nil
        return hasDatePicker
    }

    /*! Updates the UIDatePicker's value to match with the date of the cell above it.
    */
    func updateDatePicker() {
        if let indexPath = datePickerIndexPath {
            let associatedDatePickerCell = tableView.cellForRow(at: indexPath as IndexPath)
            if let targetedDatePicker = associatedDatePickerCell?.viewWithTag(datePickerTag) as! UIDatePicker? {
                let itemData = dataArray[self.datePickerIndexPath!.row - 1]
                targetedDatePicker.setDate(itemData[dateKey] as! Date, animated: false)
            }
        }
    }
    
    /*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
    */
    func hasInlineDatePicker(_ section: Int?) -> Bool {
        return (datePickerIndexPath != nil && (section == nil ? true : section == datePickerIndexPath?.section))
    }
    
    /*! Determines if the given indexPath points to a cell that contains the UIDatePicker.
    
    @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
    */
    func indexPathHasPicker(indexPath: NSIndexPath) -> Bool {
        return hasInlineDatePicker(indexPath.section) && datePickerIndexPath?.row == indexPath.row
    }

    /*! Determines if the given indexPath points to a cell that contains the start/end dates.
    @param indexPath The indexPath to check if it represents start/end date cell.
    */
    func indexPathHasDate(indexPath: NSIndexPath) -> Bool {
        var hasDate = false
        if (indexPath.row == dateStartRow) ||
            (
                indexPath.row == dateEndRow ||
                    (
                        hasInlineDatePicker(indexPath.section) &&
                            (indexPath.row == dateEndRow + 1)
                )
            ) {
            hasDate = true
        }
        return hasDate
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight: CGFloat = 0.0
        if indexPath.section == 0 {
            rowHeight = rowHeightForSection0(indexPath)
        } else {
            rowHeight = rowHeightForSectionGreaterThan0(indexPath)
        }
        return rowHeight
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows(section)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = createCellFor(tableView, indexPath)
        if indexPath.row == 0 {
            // we decide here that first cell in the table is not selectable (it's just an indicator)
            cell.selectionStyle = .none;
        }
        return cell
    }
    
    /*! Adds or removes a UIDatePicker cell below the given indexPath.
    
    @param indexPath The indexPath to reveal the UIDatePicker.
    */
    func toggleDatePickerForSelectedIndexPath(indexPath: NSIndexPath) {
        
        tableView.beginUpdates()
        
        let indexPaths = [IndexPath(row: indexPath.row + 1, section: indexPath.section)]

        // check if 'indexPath' has an attached date picker below it
        if hasPickerForIndexPath(indexPath: indexPath) {
            // found a picker below it, so remove it
            tableView.deleteRows(at: indexPaths as [IndexPath], with: .fade)
        } else {
            // didn't find a picker below it, so we should insert it
            tableView.insertRows(at: indexPaths as [IndexPath], with: .fade)
        }
        
        tableView.endUpdates()
    }

    func indexPathForDetailCellWithDatePicker() -> IndexPath? {
        if let dPIP = datePickerIndexPath {
            let indexPath =  IndexPath(row: dPIP.row - 1, section: dPIP.section)
            return indexPath
        }
        return nil
    }
    /*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
    @param indexPath The indexPath to reveal the UIDatePicker.
    */
    func displayInlineDatePickerForRowAtIndexPath(indexPath: NSIndexPath, cell: DetailCell) {
        // display the date picker inline with the table content
        tableView.beginUpdates()
        
        var before = false // indicates if the date picker is below "indexPath", help us determine which row to reveal

        if hasInlineDatePicker(indexPath.section), let dpIP = datePickerIndexPath {
            before = dpIP.row < indexPath.row
        }
        
        //let sameCellClicked = (datePickerIndexPath?.row == indexPath.row + 1)
        let sameCellClicked: Bool = {() -> Bool in
            if let dpIP = datePickerIndexPath {
                return (dpIP.row == indexPath.row + 1)
            } else {
                return false
            }
        }()
        
        // remove any date picker cell if it exists
        if self.hasInlineDatePicker(indexPath.section), let dpIP = datePickerIndexPath {
            tableView.deleteRows(at: [IndexPath(row: dpIP.row, section: (dpIP.section))], with: .fade)
            datePickerIndexPath = nil
        }
        
        if !sameCellClicked {
            // hide the old date picker and display the new one
            let rowToReveal = (before ? indexPath.row - 1 : indexPath.row)
            let indexPathToReveal =  IndexPath(row: rowToReveal, section: indexPath.section)

            toggleDatePickerForSelectedIndexPath(indexPath: indexPathToReveal as NSIndexPath)
            datePickerIndexPath = IndexPath(row: indexPathToReveal.row + 1, section: indexPath.section) as NSIndexPath
        }
        
        // always deselect the row containing the start or end date
        tableView.deselectRow(at: indexPath as IndexPath, animated:true)
        tableView.endUpdates()
        
        // inform our date picker of the current date to match the current cell
        updateDatePicker()
    }
    func checkAndRemoveDatePicker(_ indexPath: IndexPath) {
        guard let dpIP = datePickerIndexPath as IndexPath? else {
            return
        }
        if dpIP.section == indexPath.section {
            //Same section is handled in displayInlineDatePickerForRowAtIndexPath
            return
        }
        hasInlineDatePicker(nil) ? addOrRemoveDatePicker() : ()
    }
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Did Select Section: \(indexPath.section), Row: \(indexPath.row)")
        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        if cell?.reuseIdentifier == detailCellID {
            displayInlineDatePickerForRowAtIndexPath(indexPath: indexPath as NSIndexPath, cell: cell as! DetailCell)
        } else {
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
    }
    // MARK: - Actions
    /*! User chose to change the date by changing the values inside the UIDatePicker.
    @param sender The sender for this action: UIDatePicker.
    */
    @IBAction func dateAction(_ sender: UIDatePicker) {
        var targetedCellIndexPath: NSIndexPath?
        if self.hasInlineDatePicker(nil) {
            // inline date picker: update the cell's date "above" the date picker cell
            //
            targetedCellIndexPath = IndexPath(row: datePickerIndexPath!.row - 1, section: (datePickerIndexPath?.section)!)
                as NSIndexPath
            
        } else {
            // external date picker: update the current "selected" cell's date
            targetedCellIndexPath = tableView.indexPathForSelectedRow! as NSIndexPath
        }
        
        let cell = tableView.cellForRow(at: targetedCellIndexPath! as IndexPath)
        let targetedDatePicker = sender
        
        // update our data model
        var itemData = dataArray[targetedCellIndexPath!.row]
        itemData[dateKey] = targetedDatePicker.date as AnyObject
        dataArray[targetedCellIndexPath!.row] = itemData
        
        
        
        // update the cell's date string
        // Section 1 - Time: 6:30 AM
        cell?.detailTextLabel?.text = targetedCellIndexPath?.section == 0 ?
            dateStringFrom(targetedDatePicker.date) :
            dateFormatter.string(from: targetedDatePicker.date)
    }
    
    func dateStringFrom(_ fromDate: Date) -> String {
        //Sun, Sep 4
        let dateComponents = Calendar.current.dateComponents([.weekday, .month, .day], from: fromDate)
        guard let weekInt = dateComponents.weekday,
            let weekDay = Weekday(rawValue: weekInt),
            let monthInt = dateComponents.month,
            let month = Month(rawValue: monthInt),
            let day = dateComponents.day
            else {
                return ""
        }
        return "\(weekDay.desc), \(month.desc) \(day)"
    }
    
    

}

enum Month: Int {
    case jan = 1, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec
    
    var desc: String {
        var description = ""
        switch self.rawValue {
        case 1:
            description = "Jan"
        case 2:
            description = "Feb"
        case 3:
            description = "Mar"
        case 4:
            description = "Apr"
        case 5:
            description = "May"
        case 6:
            description = "Jun"
        case 7:
            description = "Jul"
        case 8:
            description = "Aug"
        case 9:
            description = "Sep"
        case 10:
            description = "Oct"
        case 11:
            description = "Nov"
        case 12:
            description = "Dec"
        default:
            ()
        }
        return description
    }
}


enum Weekday: Int {
    case sun = 1 , mon, tue, wed, thu, fri, sat

    var desc: String {
        var description = ""
        switch self.rawValue {
        case 1:
            description = "Sun"
        case 2:
            description = "Mon"
        case 3:
            description = "Tue"
        case 4:
            description = "Wed"
        case 5:
            description = "Thu"
        case 6:
            description = "Fri"
        case 7:
            description = "Sat"
        default:
            description = ""
        }
        return description
    }
}
