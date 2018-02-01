//
//  EmailIssueController.swift
//  BalanceiOS
//
//  Created by Benjamin Baron on 2/1/18.
//  Copyright © 2018 Balanced Software, Inc. All rights reserved.
//

import UIKit

class EmailIssueController: UIViewController {
    fileprivate let margin = 25
    
    fileprivate let apiInstitution: ApiInstitution?
    fileprivate let errorType: String?
    fileprivate let errorCode: String?
    
    fileprivate var isConnectionIssue: Bool {
        return apiInstitution != nil
    }
    
    private var submitButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(submit))
    }()
    
    fileprivate let titleLabel = UILabel()
    fileprivate let institutionLabel = UILabel()
    fileprivate let versionLabel = UILabel()
    fileprivate let hardwareLabel = UILabel()
    fileprivate let operatingSystemLabel = UILabel()
    fileprivate let emailField = UITextField()
    fileprivate let notesPlaceholderLabel = UILabel()
    fileprivate let notesField = UITextView()
    
    fileprivate var isEmailValid: Bool {
        return validateEmail(emailField.text ?? "")
    }
    
    init(apiInstitution: ApiInstitution, errorType: String? = nil, errorCode: String? = nil) {
        self.apiInstitution = apiInstitution
        self.errorType = errorType
        self.errorCode = errorCode
        log.info("Opened send email controller for source \(apiInstitution.source), sourceInstitutionId: \(apiInstitution.sourceInstitutionId)")
        super.init(nibName: nil, bundle: nil)
    }
    
    init() {
        self.apiInstitution = nil
        self.errorType = nil
        self.errorCode = nil
        log.info("Opened send email controller for feedback")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = isConnectionIssue ? "Report a connection problem" : "Submit Feedback"
        self.navigationItem.rightBarButtonItem = submitButton
        submitButton.isEnabled = false
        
        // Navigation bar
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        emailField.becomeFirstResponder()
    }
    
    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = .white

        if let name = apiInstitution?.name {
            institutionLabel.attributedText = attributedString(name: "Institution", value: name)
        }
        institutionLabel.textAlignment = .left
        institutionLabel.lineBreakMode = .byTruncatingTail
        self.view.addSubview(institutionLabel)
        institutionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
            make.top.equalToSuperview().offset(23)
            make.height.equalTo(isConnectionIssue ? 20 : 0)
        }
        
        versionLabel.attributedText = attributedString(name: "Version", value: appVersionAndBuildString)
        versionLabel.textAlignment = .left
        versionLabel.lineBreakMode = .byTruncatingTail
        self.view.addSubview(versionLabel)
        versionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
            make.top.equalTo(institutionLabel.snp.bottom)
            make.height.equalTo(20)
        }
        
        hardwareLabel.attributedText = attributedString(name: "Hardware", value: hardwareModelString)
        hardwareLabel.textAlignment = .left
        hardwareLabel.lineBreakMode = .byTruncatingTail
        self.view.addSubview(hardwareLabel)
        hardwareLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
            make.top.equalTo(versionLabel.snp.bottom)
            make.height.equalTo(20)
        }
        
        operatingSystemLabel.attributedText = attributedString(name: "Operating System", value: osVersionString)
        operatingSystemLabel.textAlignment = .left
        operatingSystemLabel.lineBreakMode = .byTruncatingTail
        self.view.addSubview(operatingSystemLabel)
        operatingSystemLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
            make.top.equalTo(hardwareLabel.snp.bottom)
            make.height.equalTo(20)
        }
        
        emailField.delegate = self
        emailField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        emailField.font = UIFont.systemFont(ofSize: 17)
        emailField.textColor = .black
        emailField.placeholder = "Your email"
        self.view.addSubview(emailField)
        emailField.snp.makeConstraints { make in
            make.top.equalTo(operatingSystemLabel.snp.bottom).offset(10)
            make.height.equalTo(30)
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
        }
        
        notesField.delegate = self
        notesField.font = UIFont.systemFont(ofSize: 17)
        notesField.textColor = .black
        notesField.textContainer.lineFragmentPadding = 0
        self.view.addSubview(notesField)
        notesField.snp.makeConstraints { make in
            make.top.equalTo(emailField.snp.bottom).offset(10)
            make.height.equalTo(100)
            make.left.equalToSuperview().offset(margin)
            make.right.equalToSuperview().offset(-margin)
        }
        
        notesPlaceholderLabel.font = UIFont.systemFont(ofSize: 17)
        notesPlaceholderLabel.textColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
        notesPlaceholderLabel.textAlignment = .left
        notesPlaceholderLabel.text = isConnectionIssue ? "Add your notes (optional)" : "Your feedback"
        self.view.addSubview(notesPlaceholderLabel)
        notesPlaceholderLabel.snp.makeConstraints { make in
            make.top.equalTo(notesField).offset(6)
            make.left.equalTo(notesField)
        }
    }
    
    fileprivate func attributedString(name: String, value: String) -> NSAttributedString {
        let nameAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12, weight: .medium),
                              NSAttributedStringKey.foregroundColor: UIColor.black]
        let nameAttributedString = NSAttributedString(string: name + ": ", attributes: nameAttributes)
        
        let valueAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12, weight: .medium),
                               NSAttributedStringKey.foregroundColor: UIColor.gray]
        let valueAttributedString = NSAttributedString(string: value, attributes: valueAttributes)
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(nameAttributedString)
        attributedString.append(valueAttributedString)
        return attributedString
    }
    
    @objc fileprivate func submit() {
        guard submitButton.isEnabled else {
            return
        }
        
        submitButton.isEnabled = false
        
        // Show sending activity spinner
        let activityAlertController = UIAlertController(title: "Sending...", message: nil, preferredStyle: .alert);
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.frame = activityIndicator.frame.offsetBy(dx: 30, dy: (activityAlertController.view.bounds.height - activityIndicator.frame.height) / 2)
        activityIndicator.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        activityIndicator.startAnimating()
        activityAlertController.view.addSubview(activityIndicator)
        self.present(activityAlertController, animated: true, completion: nil)
        
        Feedback.send(apiInstitution: apiInstitution, errorType: errorType, errorCode: errorCode, email: emailField.text ?? "", comment: notesField.text ?? "") { success, error in
            activityAlertController.dismiss(animated: true, completion: nil)

            if success {
                let title = self.isConnectionIssue ? "Report Sent" : "Feedback Sent"
                let message = "We will get back to you as soon as possible."
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { result in
                    self.navigationController?.popViewController(animated: true)
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                let title = self.isConnectionIssue ? "Problem Sending Report" : "Problem Sending Feedback"
                let message = self.isConnectionIssue ? "Well isn't this embarrassing. It looks like somehow the report about your connection issue had a connection issue. Please contact us directly at support@balancemy.money to let us know how bad we messed up, and so that we can help you in any way possible. We apologize for the double inconvenience!" : "Well isn't this embarrassing. Please contact us directly at support@balancemy.money to let us know how bad we messed up, and so that we can help you in any way possible. We apologize for the inconvenience!"
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { result in
                    self.submitButton.isEnabled = true
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func handleTextChange() {
        if isConnectionIssue {
            submitButton.isEnabled = isEmailValid
        } else {
            submitButton.isEnabled = isEmailValid && notesField.text.count > 0
        }
    }
}

extension EmailIssueController: UITextFieldDelegate {
    @objc func textFieldDidChange(_ textField: UITextField) {
        handleTextChange()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            notesField.becomeFirstResponder()
            return false
        }
        return true
    }
}

extension EmailIssueController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        handleTextChange()
        notesPlaceholderLabel.isHidden = textView.text.count > 0
    }
}
