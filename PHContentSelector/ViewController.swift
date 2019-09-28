//
//  ViewController.swift
//  PHAsset
//
//  Created by Mike Ogawa on 2019/09/25.
//  Copyright © 2019 TechMO. All rights reserved.
//  Thanks to :
//        https://qiita.com/nnsnodnb/items/6b149a73645206a5600f
//        https://superhahnah.com/swift-range-slider/
//        http://io-enjoy.info/【swift】avplayerの使い方/
//

import UIKit
import Photos
import AVKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var topView: TopView!
    @IBOutlet weak var sliderView: DoubleSliderView!
    @IBOutlet weak var multiButton: MultiButtonsView!
    @IBOutlet weak var collections: UICollectionView!
    
    
    var asset_list = PHFetchResult<PHAsset>()
    var player = MoviePlayer()
    var mode:PHAssetMediaType = .image
    var currentAsset:PHAsset?
    
    var start:Double=0
    var end:Double=10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mode = .image
        libraryRequestAuthorization()
        prepareTopViewButton()
        load()
        disable_range()
        preparePlayer()
        view.backgroundColor = .black
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func load(){
        prepareTopLayer()
        prepareSlider()
        prepareMultiButton()
        prepareCollection()
    }
    
    func orientLoad(){
        orientTopLayer()
        prepareSlider()
        orientMultiButton()
        orientCollection()
    }
    
    func prepareTopLayer(){
        let x:CGFloat = 0
        let y:CGFloat = 0
        let h:CGFloat = orient == .portrait ? shorter_length*0.7: shorter_length - 60 * view_ratio
        let w:CGFloat = shorter_length
        topView.frame = CGRect(x: x, y: y, width: w, height: h)
        topView.backgroundColor = .clear
    }
    
    func prepareSlider(){
        let x:CGFloat = 0
        let y:CGFloat = topView.frame.height
        let h:CGFloat = 60 * view_ratio
        let w:CGFloat = shorter_length
        
        sliderView.frame = CGRect(x: x, y: y, width: w, height: h)
        sliderView.load()
        sliderView.delegate = self
    }
    
    func prepareMultiButton(){
        setMultiButton()
        multiButton.set_variable(["picture", "movie"])
        multiButton.delegate = self
        multiButton.load()
    }
    
    func setMultiButton(){
        let x:CGFloat = orient == .portrait ? 0:sliderView.frame.maxX
        let y:CGFloat = orient == .portrait ? sliderView.frame.maxY:0
        let w:CGFloat = orient == .portrait ? shorter_length:view.frame.width - topView.frame.maxX
        let h:CGFloat = 40 * view_ratio
        multiButton.frame = CGRect(x: x, y: y, width: w, height: h)
    }
    
    func prepareCollection(){
        let x:CGFloat = orient == .portrait ? 0:topView.frame.maxX
        let y:CGFloat = multiButton.frame.maxY + 2
        let w:CGFloat = orient == .portrait ? shorter_length:longer_length - topView.frame.maxX
        let h:CGFloat = view.frame.height - multiButton.frame.maxY
        
        let i_w:CGFloat = orient == .portrait ? (view.frame.width/3 - CGFloat(1)) : (view.frame.width/7 - CGFloat(1))
        let i_space:CGFloat = 0
        
        let flowLayout: UICollectionViewFlowLayout! = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: i_w,
                                     height: i_w)
        flowLayout.sectionInset = UIEdgeInsets(top: i_space, left: i_space, bottom: i_space, right: i_space)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0.0
        
        collections.frame = CGRect(x: x, y: y, width: w, height: h)
        collections.collectionViewLayout = flowLayout
        collections.dataSource = self
        collections.delegate = self
        collections.allowsSelection = true
        collections.backgroundColor = .clear
    }
    
    func preparePlayer(){
        player.delegate = self
    }
    
    func prepareTopViewButton(){
        let tap = UITapGestureRecognizer()
        topView.addGestureRecognizer(tap)
        tap.addTarget(self, action: #selector(tap(tapGesture:)))
    }
    
    func selectFirst(){
        let asset = asset_list[0]
        currentAsset = asset
        set_image(asset: asset)
    }
    
    func prepareData() {
        getAllPhotosInfo()
    }
    
    // カメラロールへのアクセス許可
    fileprivate func libraryRequestAuthorization() {
        let group = DispatchGroup()
        group.enter()
        var stat:PHAuthorizationStatus?
        DispatchQueue.main.async {
            PHPhotoLibrary.requestAuthorization({ [weak self] status in
                stat = status
                group.leave()
            })
        }
        
        group.notify(queue: .main){
            switch stat! {
            case .authorized:
                self.getAllPhotosInfo()
            case .denied:
                self.showDeniedAlert()
            default:
                print("nothing")
            }
            self.collections.reloadData()
            self.selectFirst()
        }
    }
}

extension ViewController {
    // カメラロールから全て取得する
    fileprivate func getAllPhotosInfo() {
        let fetchOptions = PHFetchOptions()
        let sortOrder = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.sortDescriptors = sortOrder
        asset_list = PHAsset.fetchAssets(with: mode, options: fetchOptions)
    }
    
    // カメラロールへのアクセスが拒否されている場合のアラート
    fileprivate func showDeniedAlert() {
        let alert: UIAlertController = UIAlertController(title: "エラー",
                                                         message: "「写真」へのアクセスが拒否されています。設定より変更してください。",
                                                         preferredStyle: .alert)
        let cancel: UIAlertAction = UIAlertAction(title: "キャンセル",
                                                  style: .cancel,
                                                  handler: nil)
        let ok: UIAlertAction = UIAlertAction(title: "設定画面へ",
                                              style: .default,
                                              handler: { [weak self] (action) -> Void in
                                                guard let wself = self else {
                                                    return
                                                }
                                                wself.transitionToSettingsApplition()
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func transitionToSettingsApplition() {
        let url = URL(string: UIApplication.openSettingsURLString)
        if let url = url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return asset_list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! OriginalCollectionViewCell
        cell.load()
        let asset = asset_list[indexPath.row]
        cell.setConfigure(assets: asset)
        return cell
    }
    
    func reset(){
        for s in topView.subviews{
            s.removeFromSuperview()
        }
    }
    
    func clear_subview_except_last(){
        if topView.subviews.count > 1{
            for s in topView.subviews[0..<topView.subviews.count-1]{
                s.removeFromSuperview()
            }
        }
    }
    
    func reset_for_video(mode:PHAssetMediaType){
        if mode == .video{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                self.clear_subview_except_last()
            }
        } else {
            clear_subview_except_last()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        reset()
        let asset = asset_list[indexPath.row]
        currentAsset = asset
        if asset.mediaType == .video{
            set_video(asset: asset)
        } else if asset.mediaType == .image {
            set_image(asset: asset)
        }
    }
    
    func set_video(asset:PHAsset){
        
        var url_res:URL?
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.main.async {
            asset.getURL() { url in
                url_res = url
                group.leave()
            }
        }
        
        group.notify(queue: .main){
            let sub_view = UIView()
            sub_view.frame.size = self.topView.frame.size
            sub_view.frame.origin = CGPoint(x: 0, y: 0)
            self.player.set(url_res!,preview: sub_view)
            self.player.isMuted = true
            self.topView.addSubview(sub_view)
            self.enable_range()
            self.topView.prepare()
        }
    }
    
    func set_image(asset:PHAsset){
        let imageView = UIImageView()
        imageView.frame.size = self.topView.frame.size
        
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: imageView.frame.size,
                                              contentMode: .aspectFill,
                                              options: nil,
                                              resultHandler: { [weak self] (image, info) in
                                                imageView.image = image
                                                imageView.contentMode = .scaleAspectFit
        })
        self.topView.addSubview(imageView)
        self.disable_range()
    }
}

extension ViewController{
    @objc
    func tap(tapGesture:UITapGestureRecognizer){
        if currentAsset?.mediaType == .video{
            video_tap()
        }
    }
    
    func video_tap(){
        if player.isPlaying{
            player.pause()
            topView.pause()
        }else{
            player.play()
            topView.play()
        }
    }
    
}

extension ViewController:RangeDelegate{
    func rangeSlider(didChangeTo:Double, lowerValue:Bool, higherValue:Bool){
        player.seek(to: didChangeTo, is_low: lowerValue, is_high:higherValue)
        if higherValue{
            topView.pause()
        }
    }
    
    func enable_range(){
        sliderView.isHidden = false
        sliderView.setValue(array:player.return_values())
    }
    
    func disable_range(){
        sliderView.isHidden = true
    }
}

extension ViewController:MultiButtonDelegate{
    func tapped(_ button: UIButton, _ tag: Int) {
        let prev_mode = mode
        mode = button.tag == 0 ? .image : .video
        if mode == prev_mode{return}
        prepareData()
        collections.reloadData()
    }
}

extension ViewController:MoviePlayerDelegate{
    func moviePlayer(ends_at: Double) {
        topView.pause()
    }
}

extension ViewController{
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
        }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            UIView.animate(withDuration: 0.05, animations: {
                self.orientLoad()
            })
        })
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func orientTopLayer(){
        topView.orient()
        prepareTopLayer()
        for b in topView.subviews{
            b.center = CGPoint(x: topView.frame.width/2, y: topView.frame.height/2)
        }
    }
    
    func orientSlider(){
        prepareSlider()
    }
    
    func orientCollection(){
        prepareCollection()
        for cell in collections.visibleCells{
            let orgn_cell = cell as! OriginalCollectionViewCell
            orgn_cell.orient()
        }
    }
    
    func orientMultiButton(){
        setMultiButton()
        multiButton.orientLoad()
    }
}



class OriginalCollectionViewCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func load(){
        addSubview(imageView)
        imageView.frame.size = frame.size
        imageView.contentMode = .scaleAspectFill
        imageView.image = nil
    }
    
    func orient(){
        imageView.frame.size = frame.size
        imageView.contentMode = .scaleAspectFill
    }
    
    // 画像を表示する
    func setConfigure(assets: PHAsset) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        
        PHImageManager.default().requestImage(for: assets,
                                              targetSize: frame.size,
                                              contentMode: .aspectFill,
                                              options: nil,
                                              resultHandler: { [weak self] (image, info) in
                                                guard let wself = self else {
                                                    return
                                                }
                                                wself.imageView.image = image
        })
    }
}
