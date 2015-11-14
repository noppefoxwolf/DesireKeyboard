//
//  DesireKeyboardView.swift
//  DesireKeyboard
//
//  Created by Tomoya Hirano on 2015/11/12.
//  Copyright © 2015年 Tomoya Hirano. All rights reserved.
//

import UIKit







protocol DesireKeyboardKeysViewDelegate{
    func didSelectWord(word:String)
    func didPressDeleteKey()
    func didPressEnterKey()
    func didPressSpaceKey()
}

class PointerView:UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red:0.58, green:0.82, blue:0.86, alpha:0.5)
        layer.cornerRadius = frame.width/2
        layer.borderWidth = 2
        layer.borderColor = UIColor(red:0.58, green:0.82, blue:0.86, alpha:1).CGColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DesireKeyboardView: UIView,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,DesireKeyboardKeysViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var keysView: DesireKeyboardKeysView!
    
    var targetInput:UITextField?
    var pointerView = PointerView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customViewCommonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    var replace_words:[String:String] = [
        "あ":"ぁ","い":"ぃ","う":"ぅ","え":"ぇ","お":"ぉ",
        "や":"ゃ","ゆ":"ゅ","よ":"ょ","わ":"ゎ",
        "か":"が","き":"ぎ","く":"ぐ","け":"げ","こ":"ご",
        "さ":"ざ","し":"じ","す":"ず","せ":"ぜ","そ":"ぞ",
        "た":"だ","ち":"ぢ","つ":"づ","て":"で","と":"ど",
        "ば":"ぱ","び":"ぴ","ぶ":"ぷ","べ":"ぺ","ぼ":"ぽ",
        "は":"ば","ひ":"び","ふ":"ぶ","へ":"べ","ほ":"ぼ",
    ]
    
    var reverse_words:[String:String] = [
        "ぁ":"あ","ぃ":"い","ぅ":"う","ぇ":"え","ぉ":"お",
        "ゃ":"や","ゅ":"ゆ","ょ":"よ","ゎ":"わ",
        "が":"か","ぎ":"き","ぐ":"く","げ":"け","ご":"こ",
        "ざ":"さ","じ":"し","ず":"す","ぜ":"せ","ぞ":"そ",
        "だ":"た","ぢ":"ち","づ":"つ","で":"て","ど":"と",
        "ぱ":"は","ぴ":"ひ","ぷ":"ふ","ぺ":"へ","ぽ":"ほ",
        "ば":"は","び":"ひ","ぶ":"ふ","べ":"へ","ぼ":"ほ",
    ]
    
    func customViewCommonInit(){
        let view = NSBundle.mainBundle().loadNibNamed("DesireKeyboardView", owner: self, options: nil).first as! UIView
        view.frame = self.bounds
        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        view.backgroundColor = UIColor(red:0.08, green:0.08, blue:0.11, alpha:1)
        self.addSubview(view)
        
        let cellNib = UINib(nibName: "CandidateCell", bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self

        
        layer.cornerRadius = 6
        layer.masksToBounds = true
        layer.borderColor = UIColor.darkGrayColor().CGColor
        layer.borderWidth = 2
        
        keysView.delegate = self
        
        pointerView = PointerView(frame:CGRectMake(0,0,bounds.width/12,bounds.width/12))
        pointerView.hidden = true
        addSubview(pointerView)
    }
    
    var candidats:JSON?
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CandidateCell
        cell.textLabel.text = candidats![0][1][indexPath.row].string
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return candidats?[0][1].count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        let targetString  = candidats![0][0].string
        let replaceString = candidats![0][1][indexPath.row].string
        targetInput?.text = targetInput?.text!.stringByReplacingOccurrencesOfString(targetString!
            , withString: replaceString!)
        inputWord = ""
        candidats = nil
        collectionView.reloadData()
    }
    
    var inputWord:String = ""
    func didSelectWord(word: String) {
        if word == "、。" {
            if inputWord.characters.last == "、"{
                inputWord = inputWord.chopSuffix()
                targetInput?.text = targetInput?.text!.chopSuffix()
                inputWord += "。"
                targetInput?.text = (targetInput?.text)! + "。"
            }else if inputWord.characters.last == "。"{
                inputWord = inputWord.chopSuffix()
                targetInput?.text = targetInput?.text!.chopSuffix()
                inputWord += "、"
                targetInput?.text = (targetInput?.text)! + "、"
            }else{
                inputWord += "、"
                targetInput?.text = (targetInput?.text)! + "、"
            }
        }else if word == "小゛゜" {
            if let lastWord = inputWord.characters.last {
                if let c = replace_words["\(lastWord)"] {
                    inputWord = inputWord.chopSuffix()
                    inputWord += c
                    targetInput?.text = targetInput?.text!.chopSuffix()
                    targetInput?.text = (targetInput?.text)! + c
                }else if let c = reverse_words["\(lastWord)"]{
                    inputWord = inputWord.chopSuffix()
                    inputWord += c
                    targetInput?.text = targetInput?.text!.chopSuffix()
                    targetInput?.text = (targetInput?.text)! + c
                }
            }
        }else if word == "？！" {
            if inputWord.characters.last == "？"{
                inputWord = inputWord.chopSuffix()
                targetInput?.text = targetInput?.text!.chopSuffix()
                inputWord += "！"
                targetInput?.text = (targetInput?.text)! + "！"
            }else if inputWord.characters.last == "！"{
                inputWord = inputWord.chopSuffix()
                targetInput?.text = targetInput?.text!.chopSuffix()
                inputWord += "？"
                targetInput?.text = (targetInput?.text)! + "？"
            }else{
                inputWord += "？"
                targetInput?.text = (targetInput?.text)! + "？"
            }
        }else{
            inputWord += word
            targetInput?.text = (targetInput?.text)! + word
            getCandidate(inputWord)
        }
    }
    func didPressDeleteKey() {
        inputWord = inputWord.chopSuffix()
        targetInput?.text = targetInput?.text?.chopSuffix()
        getCandidate(inputWord)
    }
    func didPressEnterKey() {
        candidats = nil
        inputWord = ""
        self.collectionView.reloadData()
    }
    func didPressSpaceKey() {
        targetInput?.text = (targetInput?.text)! + " "
    }
    
    func getCandidate(words:String){
        let urlString = "http://www.google.com/transliterate?"
        let params:[String:String] = ["langpair":"ja-Hira|ja","text":words]
        let url = NSURL(string: urlString + params.urlEncodedQueryStringWithEncoding)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        let req = NSMutableURLRequest(URL: url!)
        let task = session.dataTaskWithRequest(req, completionHandler: {
            (data, resp, err) in
            self.candidats = JSON(data: data!)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView.reloadData()
            })
        })
        task.resume()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        pointerView.hidden = false
        pointerView.center = CGPointMake(bounds.width/2, bounds.height/2)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        pointerView.hidden = true
        keysView.deselectAllButtons()
    }
 
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        keysView.deselectAllButtons()
        let pos = touches.first?.locationInView(self)
        pointerView.center = pos!
        let v = keysView.hitTest(keysView.convertPoint(pos!, fromView: self), withEvent: nil)
        if let button = v as? KeyButton {
            button.hilight = true
        }
        
        (collectionView.visibleCells() as! [CandidateCell]).map({$0.hilight = false})
        if let index = collectionView.indexPathForItemAtPoint(collectionView.convertPoint(pos!, fromView: self)) {
            if let cell = collectionView.cellForItemAtIndexPath(index) as? CandidateCell {
                cell.hilight = true
            }
        }
    }
    
    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        super.pressesBegan(presses, withEvent: event)
        if presses.first?.type == UIPressType.Select {
            let v = keysView.hitTest(keysView.convertPoint(pointerView.center, fromView: self), withEvent: nil)
            if let button = v as? KeyButton {
                button.selectAction()
            }
            if let index = collectionView.indexPathForItemAtPoint(collectionView.convertPoint(pointerView.center, fromView: self)) {
                collectionView.delegate?.collectionView!(collectionView, didSelectItemAtIndexPath: index)
            }
        }
    }
    
    override func canBecomeFocused() -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.bounds.width/7, collectionView.bounds.height - 20)
    }
}

extension String {
    // URLエンコード
    var urlEncodedStringWithEncoding:String{
        let charactersToBeEscaped = ":/?&=;+!@#$()',*" as CFStringRef
        let charactersToLeaveUnescaped = "[]." as CFStringRef
        
        let raw = self
        
        let result = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, raw, charactersToLeaveUnescaped, charactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)) as NSString
        
        return result as String
    }
    
    func chopSuffix(count: Int = 1) -> String {
        if self.characters.count == 0 {
            return self
        }
        return self.substringToIndex(self.endIndex.advancedBy(-count))
    }
}


extension Dictionary {
    // Dictionary内のデータをエンコード
    var urlEncodedQueryStringWithEncoding:String{
        var parts = [String]()
        for (key, value) in self {
            let keyString = (key as! String).urlEncodedStringWithEncoding
            let valueString = (value as! String).urlEncodedStringWithEncoding
            let query = "\(keyString)=\(valueString)" as String
            parts.append(query)
        }
        return parts.joinWithSeparator("&") as String
    }
}



class DesireKeyboardKeysView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        userInteractionEnabled = true
        backgroundColor = UIColor.clearColor()
        setupKeys()
    }
    
    var delegate:DesireKeyboardKeysViewDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutKeyButtons()
    }
    
    var words = [
        ["あ","い","う","え","お"],
        ["か","き","く","け","こ"],
        ["さ","し","す","せ","そ"],
        ["た","ち","つ","て","と"],
        ["な","に","ぬ","ね","の"],
        ["は","ひ","ふ","へ","ほ"],
        ["ま","み","む","め","も"],
        ["や","ゆ","よ","、。","？！"],
        ["ら","り","る","れ","ろ"],
        ["わ","を","ん","ー","小゛゜"]
    ]

    
    var keyButtons:[[KeyButton]] = [[]]
    let space = KeyButton(frame: CGRectZero)
    let delete = KeyButton(frame: CGRectZero)
    let enter    = KeyButton(frame: CGRectZero)
    
    func setupKeys(){
        for (_, column) in words.enumerate() {
            var keyColumn:[KeyButton] = []
            for (_, word) in column.enumerate() {
                let key = KeyButton(frame: CGRectZero)
                key.text = word
                addSubview(key)
                keyColumn.append(key)
            }
            keyButtons.append(keyColumn)
        }
        space.text = "スペース"
        space.selectedAction = {(_) in
            self.delegate?.didPressSpaceKey()
        }
        addSubview(space)
        delete.text = "⇐"
        delete.selectedAction = {(_) in
            self.delegate?.didPressDeleteKey()
        }
        addSubview(delete)
        enter.text = "確定"
        enter.selectedAction = {(_) in
            self.delegate?.didPressEnterKey()
        }
        addSubview(enter)
    }
    
    func deselectAllButtons(){
        for column in keyButtons {
            for key in column {
                key.hilight = false
            }
        }
        space.hilight = false
        delete.hilight = false
        enter.hilight = false
    }
    
    func layoutKeyButtons(){
        let keyWidth:CGFloat = bounds.width/10.0 - 2
        let keyHeight:CGFloat = bounds.height/7.0 - 2
        for (i,column) in keyButtons.enumerate() {
            for (j,button) in column.enumerate() {
                button.frame = CGRectMake(bounds.width - CGFloat(i)*(keyWidth+2), CGFloat(j)*(keyHeight+2), keyWidth, keyHeight)
                button.selectedAction = { (word) in
                    self.delegate?.didSelectWord(word!)
                }
            }
        }
        space.frame  = CGRectMake((keyWidth+2)*3, (keyHeight+2)*5, keyWidth*4, keyHeight)
        delete.frame = CGRectMake((keyWidth+2)*8, (keyHeight+2)*5, keyWidth*2, keyHeight)
        enter.frame  = CGRectMake((keyWidth+2)*8, (keyHeight+2)*6, keyWidth*2, keyHeight)
    }
}

class CandidateCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!
    
    var hilight:Bool = false{
        didSet{
            if hilight {
                self.backgroundColor = UIColor.darkGrayColor()
            }else{
                self.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
        if self.focused {
            self.backgroundColor = UIColor.darkGrayColor()
        }else{
            self.backgroundColor = UIColor.clearColor()
        }
    }
}

class KeyButton: UILabel {
    
    var unfocusBorderColor = UIColor(red:0.19, green:0.2, blue:0.22, alpha:1).CGColor
    var focusBorderColor = UIColor(red:0.58, green:0.82, blue:0.86, alpha:1).CGColor
    var hilight:Bool = false{
        didSet{
            if hilight {
                self.layer.borderColor = focusBorderColor
            }else{
                self.layer.borderColor = unfocusBorderColor
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        userInteractionEnabled = true
        backgroundColor = UIColor(red:0.14, green:0.14, blue:0.14, alpha:1)
        layer.cornerRadius = 6
        layer.borderColor = unfocusBorderColor
        layer.borderWidth = 4
        layer.masksToBounds = true
        textColor = UIColor.whiteColor()
        font = UIFont.boldSystemFontOfSize(24)
        textAlignment = .Center
    }
    
    var selectedAction:((word:String?) -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func canBecomeFocused() -> Bool {
        return false
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
        if self.focused {
            self.layer.borderColor = focusBorderColor
        }else{
            self.layer.borderColor = unfocusBorderColor
        }
    }
    
    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        super.pressesBegan(presses, withEvent: event)
        if presses.first?.type == UIPressType.Select {
            selectedAction?(word: text)
        }
    }
    
    func selectAction(){
        selectedAction?(word: text)
    }
}

