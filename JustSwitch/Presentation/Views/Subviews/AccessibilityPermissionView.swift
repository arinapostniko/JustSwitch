//
//  AccessibilityPermissionView.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/3/25.
//

import AppKit

class AccessibilityPermissionView: NSView {
    
    private enum Constants {
        static let iconSystemSymbolName = "exclamationmark.triangle"
        static let iconAccessibilityDescription = "Warning"
        static let settingsUrlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        static let fileURLWithPath = "/System/Library/PreferencePanes/Security.prefPane"
        static let iconSize: CGFloat = 16
        static let inset: CGFloat = 12
    }
    
    private let iconImageView: NSImageView = {
        let imageView = NSImageView()
        imageView.image = NSImage(systemSymbolName: Constants.iconSystemSymbolName,
                                  accessibilityDescription: Constants.iconAccessibilityDescription)
        return imageView
    }()
    private let titleLabel: NSTextField = {
        let textField = NSTextField()
        textField.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        textField.textColor = .labelColor
        textField.isEditable = false
        textField.isBordered = false
        textField.backgroundColor = .clear
        return textField
    }()
    private let descriptionLabel: NSTextField = {
        let textField = NSTextField()
        textField.font = NSFont.systemFont(ofSize: 11)
        textField.textColor = .secondaryLabelColor
        textField.isEditable = false
        textField.isBordered = false
        textField.backgroundColor = .clear
        textField.lineBreakMode = .byWordWrapping
        textField.maximumNumberOfLines = 0
        return textField
    }()
    private let settingsButton: NSButton = {
        let button = NSButton()
        button.bezelStyle = .rounded
        button.controlSize = .small
        return button
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    override var intrinsicContentSize: NSSize {
        NSSize(width: 280, height: 90)
    }
    
    @objc private func openSettings() {
        if let url = URL(string: Constants.settingsUrlString) {
            NSWorkspace.shared.open(url)
        } else {
            NSWorkspace.shared.open(URL(fileURLWithPath: Constants.fileURLWithPath))
        }
    }
}

// MARK: Setup
private extension AccessibilityPermissionView {
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.stringValue = AccessibilityPermission.Strings.title
        descriptionLabel.stringValue = AccessibilityPermission.Strings.description
        
        settingsButton.title = AccessibilityPermission.Strings.settingsButtonTitle
        settingsButton.target = self
        settingsButton.action = #selector(openSettings)
        
        [iconImageView, titleLabel, descriptionLabel, settingsButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        setConstraints()
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.inset),
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.inset),
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.iconSize),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.inset),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Constants.inset),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.inset),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Constants.inset),
            
            settingsButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.inset),
            settingsButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            settingsButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -Constants.inset),
            settingsButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
}

// MARK: Strings
private enum AccessibilityPermission {
    
    enum Strings {
        static let title = String(localized: "cccessibilityPermission.label.title")
        static let description = String(localized: "cccessibilityPermission.label.description")
        static let settingsButtonTitle = String(localized: "cccessibilityPermission.button.settings")
    }
}
