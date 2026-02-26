//
//  VimViewController.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-02-25.
//

import Cocoa
import libvim

class CustomTextView: NSTextView {
    var mode: Vim.State = [.normal] {
        didSet {
            caretWidth = if mode.contains(.normal) {
                15
            } else if mode.contains(.insert) {
                2
            } else {
                15
            }
        }
    }

    var caretWidth: CGFloat = 15

    open override func drawInsertionPoint(in rect: NSRect, color: NSColor, turnedOn flag: Bool) {
        var rect = rect
        rect.size.width = caretWidth
        super.drawInsertionPoint(in: rect, color: color, turnedOn: flag)
    }

    open override func setNeedsDisplay(_ rect: NSRect, avoidAdditionalLayout flag: Bool) {
        var rect = rect
        let width = rect.size.width + caretWidth - 1
        rect.size.width = max(rect.size.width, width)
        super.setNeedsDisplay(rect, avoidAdditionalLayout: flag)
    }
}

class VimViewController: NSViewController {
    var mode: Vim.State = [.normal] {
        didSet {
            textView.mode = mode
        }
    }

    var lines = [String]() {
        didSet {
            textView.string = lines.joined(separator: "\n")
        }
    }

    var cursor: Vim.Position = .init(lnum: 1, col: 0, coladd: 0) {
        didSet {
            let cursorLocation = location(for: cursor)

            if mode.contains(.visual) {
                let visualStartLocation = location(for: vimVisualGetRange().start)
                let minLocation = min(cursorLocation, visualStartLocation)
                let maxLocation = max(cursorLocation, visualStartLocation)
                textView.setSelectedRange(
                    .init(
                        location: minLocation,
                        length: maxLocation - minLocation + 1
                    )
                )
            } else {
                textView.setSelectedRange(.init(location: cursorLocation, length: 0))
            }
        }
    }

    func location(for position: Vim.Position) -> Int {
        let (row, col) = (position.lnum, position.col)
        var pos = 0
        for i in 0..<(row - 1) {
            pos += lines[Int(i)].count + 1
        }
        pos += Int(col)
        return pos
    }

    lazy var textView: CustomTextView = {
        let textView = CustomTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.textColor = .labelColor
        textView.font = .monospacedSystemFont(ofSize: 24, weight: .regular)
        textView.delegate = self
        let _ = textView.layoutManager
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textView)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    func updateTextView() {
        self.lines = vimEval("getline(1, '$')")!
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)
        self.mode = vimGetMode()
        self.cursor = vimCursorGetPosition()

        print(vimVisualGetRange())
    }
}

extension VimViewController: NSTextViewDelegate {
    override func keyUp(with event: NSEvent) {
        guard let chars = event.characters else { return }
        switch event.keyCode {
        case 51: vimKey("<c-h>")
        default: vimInput(chars)
        }
        updateTextView()
        print(event.characters, event.keyCode)
    }

    func textView(_ textView: NSTextView, shouldChangeTextInRanges affectedRanges: [NSValue], replacementStrings: [String]?) -> Bool {
        false
    }
}

@available(macOS 14, *)
#Preview {
    VimViewController()
}
