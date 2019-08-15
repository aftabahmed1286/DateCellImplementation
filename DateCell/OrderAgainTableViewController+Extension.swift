//
//  OrderAgainTableViewController+Extension.swift
//  ForemanApp
//
//  Created by Aftab Ahmed on 12/02/18.
//
//

import Foundation
import UIKit

extension OrderAgainTableViewController {
    func numberOfRows(_ section: Int) -> Int {
        var numberofRows = section == 0 ? rowsForSection0 : rowsForSectionGraterThan0
        if hasInlineDatePicker(section) {
            // we have a date picker, so allow for it in the number of rows in this section
            numberofRows += 1
        }
        return numberofRows
    }
    func rowHeightForSectionGreaterThan0(_ indexPath: IndexPath) -> CGFloat {
        var rowHeight: CGFloat = tableViewRowHeight
        switch indexPath.row {
        case 0:
            ()//rowHeight = tableView.rowHeight
        case 1:
            if indexPathHasPicker(indexPath: indexPath as NSIndexPath) {
                rowHeight = pickerCellRowHeight
            }
        case 2, 3, 4:
            rowHeight = tableViewRowHeight
        default:()
        }
        return rowHeight
    }
    func rowHeightForSection0(_ indexPath: IndexPath) -> CGFloat {
        var rowHeight: CGFloat = 44.0
        switch indexPath.row {
        case 0:
            ()//rowHeight = tableView.rowHeight
        case 1:
            if indexPathHasPicker(indexPath: indexPath as NSIndexPath) {
                rowHeight = pickerCellRowHeight
            }
        case 2:
            //Delivery instructions cell if !picker
            if !hasInlineDatePicker(indexPath.section) {
                rowHeight = deliveryInstructionsRowHeight
            }
        case 3:
            //Delivery instructions cell if picker
            if hasInlineDatePicker(indexPath.section) {
                rowHeight = deliveryInstructionsRowHeight
            }
        default:()
        }
        return rowHeight
    }
    func cellIDFor(_ indexPath: IndexPath) -> String {
        var cellID = ""
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cellID = detailCellID
            case 1:
                cellID = detailEditCellID
            case 2:
                cellID = deliveryInstructionsCellID
            default:()
            }
        } else {
            switch indexPath.row {
            case 0:
                cellID = detailCellID
            case 1, 2, 3:
                cellID = detailEditCellID
            case 4:
                cellID = removeProductCellID
            default:()
            }
        }
        return cellID
    }
    func createCellID(_ indexPath: IndexPath) -> String {
        var cellID = removeProductCellID
        if indexPathHasPicker(indexPath: indexPath as NSIndexPath) {
            // the indexPath is the one containing the inline date picker
            cellID = datePickerCellID     // the current/opened date picker cell
        } else if indexPathHasDate(indexPath: indexPath as NSIndexPath) {
            // the indexPath is one that contains the date information
            cellID = detailCellID       // the start/end date cells
        } else {
            cellID = cellIDFor(indexPath)
        }
        return cellID
    }
    func modelRow(_ indexPath: IndexPath) -> Int {
        var modelRow = indexPath.row
        guard let datePickerIndexPathRow = datePickerIndexPath?.row else {
            return modelRow
        }
        let isLessThanDatePickerIndexPathRow = datePickerIndexPathRow <= indexPath.row
        if datePickerIndexPath != nil && isLessThanDatePickerIndexPathRow {
            modelRow -= 1
        }
        return modelRow
    }
    func detailCell(_ cellID: String,
                    _ tableView: UITableView,
                    _ indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? DetailCell else {
            return UITableViewCell()
        }
        let itemData = indexPath.section == 0 ?
            dataArray[modelRow(indexPath)] :
            dataArray1["\(indexPath.section)"]![modelRow(indexPath)]
        // we have either start or end date cells, populate their date field
        //
        cell.textLabel?.text = itemData[titleKey] as? String
        guard let date = ((itemData[dateKey] as? NSDate) as Date?) else {
            return cell
        }
        cell.detailTextLabel?.text = indexPath.section == 0 ?
            dateStringFrom(date) :
            dateFormatter.string(from: date)
        return cell
    }
    func datePickerCell(_ cellID: String,
                        _ tableView: UITableView,
                        _ indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? DatePickerCell else {
            return UITableViewCell()
        }
        cell.datePicker.datePickerMode = indexPath.section == 0 ? .date : .countDownTimer
        cell.datePicker.minuteInterval = 10
        return cell
    }
    func detailCellEdit(_ cellID: String,
                        _ tableView: UITableView,
                        _ indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? DetailCellEdit else {
            return UITableViewCell()
        }
        let itemData = indexPath.section == 0 ?
            dataArray[modelRow(indexPath)] :
            dataArray1["\(indexPath.section)"]![modelRow(indexPath)]
        // we have either start or end date cells, populate their date field
        //
        guard let value = itemData[valueKey] else {
            return cell
        }
        cell.titleLabel.text = itemData[titleKey] as? String
        cell.detailTextField.text = "\(value)"  //detailTextLabel?.text = "\(value)"
        cell.detailTextField.delegate = self
        return cell
    }
    func removeProductCell(_ cellID: String,
                           _ tableView: UITableView,
                           _ indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? RemoveProductCell else {
            return UITableViewCell()
        }
        let itemData = indexPath.section == 0 ? dataArray[modelRow(indexPath)] : dataArray1["\(indexPath.section)"]![modelRow(indexPath)]
        cell.textLabel?.text = itemData[titleKey] as? String
        return cell
    }
    func deliveryInstrucionsCell(_ cellID: String,
                                 _ tableView: UITableView,
                                 _ indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.section)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? DeliveryInstructionsCell else {
            return UITableViewCell()
        }
        let itemData = indexPath.section == 0 ? dataArray[modelRow(indexPath)] : dataArray1["\(indexPath.section)"]![modelRow(indexPath)]
        cell.textLabel?.text = itemData[titleKey] as? String
        cell.deliverInstructionsTextView.text = itemData[titleKey] as? String
        return cell
    }
    func designCellforCellID(_ cellID: String,
                             _ tableView: UITableView,
                             _ indexPath: IndexPath) -> UITableViewCell {
        switch cellID {
        case detailCellID:
            return detailCell(cellID, tableView, indexPath)
        case detailEditCellID: ()
        return detailCellEdit(cellID, tableView, indexPath)
        case datePickerCellID:
            return datePickerCell(cellID, tableView, indexPath)
        case removeProductCellID:
            return removeProductCell(cellID, tableView, indexPath)
        case deliveryInstructionsCellID:
            return deliveryInstrucionsCell(cellID, tableView, indexPath)
        default:()
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) else {
            return UITableViewCell()
        }
        //cell.textLabel?.text = "Not in 1"
        return cell
    }
    func createCellFor(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cellID = createCellID(indexPath)
        // if we have a date picker open whose cell is above the cell we want to update,
        // then we have one more cell than the model allows
        //
        return designCellforCellID(cellID, tableView, indexPath)
    }
}

extension OrderAgainTableViewController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(OrderAgainTableViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension OrderAgainTableViewController: UITextFieldDelegate {
    func parentCellTVTF(for textFieldView: UIView) -> UITableViewCell? {
        /*
         po textField.superview?.superview as! UITableViewCell
         <DateCell.DetailCellEdit: 0x7fcce706ca00; baseClass = UITableViewCell; frame = (0 363; 414 44); autoresize = W; layer = <CALayer: 0x600000427800>>
         */
        guard let superView = textFieldView.superview else {
            return nil
        }
        guard let supView = superView.superview as? UITableViewCell else {
            return nil
        }
        return supView
    }
    func indexPathForParentCellTVTF(for textFieldView: UIView) -> IndexPath? {
        guard let cell = parentCellTVTF(for: textFieldView) else {
            return nil
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            return nil
        }
        return indexPath
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addOrRemoveDatePicker()
        selectedTextFieldIndexPath = indexPathForParentCellTVTF(for: textField)
    }
    func addOrRemoveDatePicker() {
        if let indexPath = indexPathForDetailCellWithDatePicker() {
            let cell = tableView.cellForRow(at: indexPath as IndexPath)
            if cell?.reuseIdentifier == detailCellID, let detailCell =  cell as? DetailCell {
                displayInlineDatePickerForRowAtIndexPath(indexPath: indexPath as NSIndexPath, cell: detailCell )
            }
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        //addOrRemoveDatePicker()
        guard let cell = parentCell(for: textField) else {
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        //TextField Validations
        if indexPath.section == 0 {
            dataArray[indexPath.row][valueKey] = textField.text as AnyObject
        } else {
            dataArray1["\(indexPath.section)"]![indexPath.row][valueKey] = textField.text as AnyObject
        }
    }
    func parentCell(for textFiled: UITextField) -> UITableViewCell? {
        /*
         po textField.superview?.superview as! UITableViewCell
         <DateCell.DetailCellEdit: 0x7fcce706ca00; baseClass = UITableViewCell; frame = (0 363; 414 44); autoresize = W; layer = <CALayer: 0x600000427800>>
         */
        guard let superView = textFiled.superview else {
            return nil
        }
        guard let supView = superView.superview as? UITableViewCell else {
            return nil
        }
        return supView
    }
}

class DatePickerCell: UITableViewCell {
    @IBOutlet weak var datePicker: UIDatePicker!
}

class DetailCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
}

class DetailCellEdit: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailTextField: UITextField!
    @IBOutlet weak var detTextFieldWidthConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        detailTextField.textAlignment = .right
        titleLabel.textAlignment = .left
    }
}

class RemoveProductCell: UITableViewCell {
    @IBOutlet weak var removeProductLabel: UILabel!
}

class DeliveryInstructionsCell: UITableViewCell {
    @IBOutlet weak var deliverInstructionsTextView: UITextView!
}

