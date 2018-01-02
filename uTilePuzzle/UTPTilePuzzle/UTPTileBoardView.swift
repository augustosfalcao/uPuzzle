//
//  UTPTileBoardView.swift
//  uTilePuzzle
//
//  Created by Augusto Falcão on 9/21/17.
//  Copyright © 2017 Augusto Falcão. All rights reserved.
//

import Foundation

 protocol UTPTileBoardViewDelegate {
    func tileBoardViewDidFinished(_ tileBoardView: UTPTileBoardView)
    func tileBoardView(_ tileBoardView: UTPTileBoardView, tileDidMove position: CGPoint)
}

class UTPTileBoardView: UIViewFocusEnviroment {

    var motionEffectGroupArray = UIMotionEffectGroup()

    var delegate: UTPTileBoardViewDelegate? = nil

    var tileWidth: CGFloat = 0
    var tileHeight: CGFloat = 0

    var isGestureRecognized: Bool = false

    // var board = UTPTileBoard()
    var board = IXNTileBoard()
    var tiles: [UIImageViewFocusEnviroment] = []
    var boardSize: Int = 3

    var draggedTile = UIImageViewFocusEnviroment()
    var draggedDirection: Int = 0

    var zeroCoordinate = CGPoint.zero

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    init(withImage image: UIImage, size: Int, frame: CGRect) {
        super.init(frame: frame)
        play(with: image, size: size)
        alpha = 1.0
        isHidden = false
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // fatalError("init(coder:) has not been implemented")
    }

    func play(with image: UIImage, size: Int) {
        // board = UTPTileBoard(withSize: size)!
        board = IXNTileBoard(size: size)
        boardSize = size

        let resizedImage = image.resizedImage(with: frame.size)
        tileWidth = (resizedImage!.size.width) / CGFloat(size)
        tileHeight = (resizedImage!.size.height) / CGFloat(size)
        tiles = sliceImageToAnArray(resizedImage!)

        if !isGestureRecognized {
            addGestures()
        }
    }

    func sliceImageToAnArray(_ image: UIImage) -> [UIImageViewFocusEnviroment] {
        var slices: [UIImageViewFocusEnviroment] = []

//        for i in 0 ..< board!.size {
//            for j in 0 ..< board!.size {
//                if i == board!.size && j == board!.size {
        for i in 0 ..< board.size {
            for j in 0 ..< board.size {
                if i == board.size && j == board.size {
                    continue
                }
                let f: CGRect = CGRect(x: CGFloat(j) * tileWidth, y: CGFloat(i) * tileHeight, width: tileWidth, height: tileHeight)
                let tileImageView: UIImageViewFocusEnviroment = tileImageViewWithImage(image: image, frame: f)
                slices.append(tileImageView)

                let pieceCoord: CGPoint = coordinateFromPoint(point: f.origin)

                if board.tile(atCoordinate: pieceCoord) == 0 {
                    zeroCoordinate = pieceCoord
                }

//                if board!.tileAtCoordinate(coor: pieceCoord) == 100 {
//                    zeroCoordinate = pieceCoord
//                }
            }
        }
        return slices
    }

    func tileImageViewWithImage(image: UIImage, frame: CGRect) -> UIImageViewFocusEnviroment {
        //let tileImage: UIImage = image.cropImageFromFrame(frame)
        let tileImage: UIImage = image.cropImage(fromFrame: frame)

        let tileImageView: UIImageViewFocusEnviroment = UIImageViewFocusEnviroment(image: tileImage)
        tileImageView.layer.shadowColor = UIColor.black.cgColor
        tileImageView.layer.shadowOpacity = 0.65
        tileImageView.layer.shadowRadius = 1.5
        tileImageView.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        tileImageView.layer.shadowPath = UIBezierPath(rect: tileImageView.layer.bounds).cgPath

        tileImageView.isUserInteractionEnabled = true
        tileImageView.isHighlighted = true

        return tileImageView
    }

    func addGestures() {
        let swipeGestureUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler))
        swipeGestureUp.direction = UISwipeGestureRecognizerDirection.up
        addGestureRecognizer(swipeGestureUp)

        let swipeGestureDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler))
        swipeGestureDown.direction = UISwipeGestureRecognizerDirection.down
        addGestureRecognizer(swipeGestureDown)

        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler))
        swipeGestureLeft.direction = UISwipeGestureRecognizerDirection.left
        addGestureRecognizer(swipeGestureLeft)

        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler))
        swipeGestureRight.direction = UISwipeGestureRecognizerDirection.right
        addGestureRecognizer(swipeGestureRight)
    }

    // MARK: Public Methods for playing puzzle

    func shuffleTimes(_ times: Int) {
//        board!.shuffle(times: times)
        board.shuffle(times)
        drawTiles()
    }

    func drawTiles() {
        for view in subviews {
            view.removeFromSuperview()
        }

        traverseTilesWithBlock({
            (tileImageView, i, j) in
            let frame = CGRect(x: tileWidth * CGFloat(i - 1), y: tileHeight * CGFloat(j - 1), width: tileWidth, height: tileHeight)
            tileImageView.frame = frame
            addSubview(tileImageView)
        })
    }

    func orderingTiles() {
        traverseTilesWithBlock({
            (tileImageView, i, j) in
            bringSubview(toFront: tileImageView)
        })
    }

    func traverseTilesWithBlock(_ block: (_ tileImageView: UIImageViewFocusEnviroment, _ i: Int, _ j: Int) -> Void) {
//        for i in 1 ... board!.size {
//            for j in 1 ... board!.size {
        for i in 1 ... board.size {
            for j in 1 ... board.size {
//                let value = board!.tileAtCoordinate(coor: CGPoint(x: i, y: j))
                let value = board.tile(atCoordinate: CGPoint(x: i, y: j))
                if value == 0 {
                    zeroCoordinate = CGPoint(x: i, y: j)
                    continue
                }

//                let tileImageView: UIImageViewFocusEnviroment = tiles[value - 1]
                let tileImageView: UIImageViewFocusEnviroment = tiles[value!.intValue - 1]
                block(tileImageView, i, j)
            }
        }
    }

    // MARK: Movers Methods

    func tileViewAtPosition(position: CGPoint) -> UIImageViewFocusEnviroment {
        var tileView: UIImageViewFocusEnviroment = UIImageViewFocusEnviroment()

        for enumTile in tiles {
            if enumTile.frame.contains(position) {
                tileView = enumTile
                break
            }
        }

        return tileView
    }

    func tileWasMoved() {
        orderingTiles()

//        if board!.isAllTilesCorrect() && delegate != nil {
        if board.isAllTilesCorrect() && delegate != nil {
            delegate?.tileBoardViewDidFinished(self)
        }
    }

    func coordinateFromPoint(point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x / tileWidth + 1, y: point.y / tileHeight + 1)
    }

    // MARK: Direction Tap Movement Pattern

    func mappingTapTileFromDirection(press: UIPress) -> CGPoint {
        var pressedTargetTile = zeroCoordinate

        switch press.type {
        case .upArrow:
            pressedTargetTile.y = zeroCoordinate.y + 1
        case .downArrow:
            pressedTargetTile.y = zeroCoordinate.y - 1
        case .leftArrow:
            pressedTargetTile.x = zeroCoordinate.x + 1
        case .rightArrow:
            pressedTargetTile.x = zeroCoordinate.x - 1
        default:
            break
        }

        return pressedTargetTile
    }

    func mappingSwipeTileFromSwipeDirection(direction: UISwipeGestureRecognizerDirection) -> CGPoint{
        var swipeTargetTile = zeroCoordinate

        switch direction {
        case .up:
            swipeTargetTile.y = zeroCoordinate.y + 1
        case .down:
            swipeTargetTile.y = zeroCoordinate.y - 1
        case .left:
            swipeTargetTile.x = zeroCoordinate.x + 1
        case .right:
            swipeTargetTile.x = zeroCoordinate.x - 1
        default:
            break
        }

        return swipeTargetTile
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            let targetTile: CGPoint = mappingTapTileFromDirection(press: press)

            if Int(targetTile.x) > boardSize || Int(targetTile.y) > boardSize || targetTile.x < 1 || targetTile.y < 1 {
                continue
            }

//            if !board!.canMoveTile(coor: targetTile) {
            if !board.canMoveTile(targetTile) {
                return
            }

//            let p: CGPoint = board!.shouldMove(true, tileAtCoordinate: targetTile)
            let p: CGPoint = board.shouldMove(true, tileAtCoordinate: targetTile)
            let tilePosition: CGPoint = CGPoint(x: tileWidth * (targetTile.x - 1), y: tileHeight * (targetTile.y - 1))
            let tileView: UIImageViewFocusEnviroment = tileViewAtPosition(position: tilePosition)
            let newFrame = CGRect(x: tileWidth * (p.x - 1), y: tileHeight * (p.y - 1), width: tileWidth, height: tileHeight)

            UIView.animate(withDuration: 0.1, animations: {
                tileView.frame = newFrame
            }, completion: {
                (finished) in
                if self.delegate != nil {
                    self.delegate?.tileBoardView(self, tileDidMove: tilePosition)
                }
                self.tileWasMoved()
            })

            zeroCoordinate = targetTile
        }
    }



    func swipeHandler(swipeRecognizer: UISwipeGestureRecognizer) {
        print("oleoleoleole")
        let targetPoint: CGPoint = mappingSwipeTileFromSwipeDirection(direction: swipeRecognizer.direction)

        if Int(targetPoint.x) > boardSize || Int(targetPoint.y) > boardSize || targetPoint.x < 1 || targetPoint.y < 1 {
            return
        }

//        if !board!.canMoveTile(coor: targetPoint) {
        if !board.canMoveTile(targetPoint) {
            return
        }

//        let p: CGPoint = board!.shouldMove(true, tileAtCoordinate: targetPoint)
        let p: CGPoint = board.shouldMove(true, tileAtCoordinate: targetPoint)
        let tilePosition: CGPoint = CGPoint(x: tileWidth * (targetPoint.x - 1), y: tileHeight * (targetPoint.y - 1))
        let tileView: UIImageViewFocusEnviroment = tileViewAtPosition(position: tilePosition)
        let newFrame = CGRect(x: tileWidth * (p.x - 1), y: tileHeight * (p.y - 1), width: tileWidth, height: tileHeight)

        UIView.animate(withDuration: 0.1, animations: {
            tileView.frame = newFrame
        }, completion: {
            (finished) in
            if self.delegate != nil {
                self.delegate?.tileBoardView(self, tileDidMove: tilePosition)
            }
            self.tileWasMoved()
        })

        zeroCoordinate = targetPoint
    }
}
