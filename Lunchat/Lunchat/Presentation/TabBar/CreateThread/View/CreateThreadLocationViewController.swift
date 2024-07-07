//
//  CreateThreadLocationViewController.swift
//  Lunchat
//
//  Created by 이경후 on 2023/09/24.
//

import UIKit
import RxSwift

final class CreateThreadLocationViewController: BaseViewController {
    
    private let titleLabel = UILabel()
    
    private let locationImageView = UIImageView(image: UIImage(named: "location"))
    private let locationTextField = UITextField()
    private let locationSubLabel = UILabel()
    private let locationBottomLine = UIView()
    
    private let tableView = UITableView()
    
    private let mapOverLayTouchedView = UIView()
    private let mapImageView = UIImageView(image: UIImage(named: "map"))
    private let mapTitleLabel = UILabel()
    private let mapViewButton = UIButton()
    private let mapBottomLine = UIView()
    
    private let nextButton = LunchatButton()
    
    private let viewModel: CreateThreadViewModel
    private var disposeBag = DisposeBag()
    
    init(viewModel: CreateThreadViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConfig()
        setUI()
        setConstraint()
        bind()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.reloadLocation, object: nil, queue: .main) { [weak self] noti in
            if let searchedPlace = noti.userInfo?["mapInfo"] as? SearchedPlace {
                self?.viewModel.choosePlace(place: searchedPlace)
                self?.locationTextField.text = searchedPlace.title
                self?.locationSubLabel.text = searchedPlace.roadAddress
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBottomLine()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deleteBottomLine()
        if isMovingFromParent {
            viewModel.finishCoordinator()
        }
    }
    
    @objc
    private func clearText() {
        self.locationTextField.text = ""
    }
    
    private func setConfig() {
        titleLabel.text = "식당 장소를 선택해주세요"
        titleLabel.font = AppFont.shared.getBoldFont(size: 18)
        titleLabel.textColor = AppColor.black.color
        
        let clearButton = UIButton()
        clearButton.setImage(UIImage(named: "clear"), for: .normal)
        clearButton.addTarget(self, action: #selector(clearText), for: .touchUpInside)
        locationTextField.rightView = clearButton
        locationTextField.rightViewMode = .whileEditing
        
        let attributedPlaceholder = NSAttributedString(string: "식당명 또는 지번, 도로명, 건물명으로 검색", attributes: [ NSAttributedString.Key.foregroundColor: AppColor.grayText.color, NSAttributedString.Key.font: AppFont.shared.getRegularFont(size: 16)])
        locationTextField.attributedPlaceholder = attributedPlaceholder
        locationTextField.textColor = AppColor.black.color
        locationTextField.font = AppFont.shared.getBoldFont(size: 15)
        
        locationSubLabel.font = AppFont.shared.getRegularFont(size: 9)
        locationSubLabel.textColor = AppColor.grayText.color
        
        locationImageView.contentMode = .scaleAspectFit
        locationBottomLine.backgroundColor = AppColor.grayText.color
        
        mapTitleLabel.text = "지도에서 위치 확인"
        mapTitleLabel.font = AppFont.shared.getBoldFont(size: 15)
        mapTitleLabel.textColor = AppColor.black.color
        mapTitleLabel.isHidden = true
        
        mapImageView.contentMode = .scaleAspectFit
        mapImageView.isHidden = true
        mapViewButton.setImage(UIImage(named: "arrow"), for: .normal)
        mapViewButton.isHidden = true
        mapBottomLine.backgroundColor = AppColor.purple.color
        mapBottomLine.isHidden = true
        
        mapOverLayTouchedView.backgroundColor = .clear
        mapOverLayTouchedView.isHidden = true
        
        tableView.isHidden = true
        tableView.backgroundColor = AppColor.white.color
        tableView.register(SearchLocationTableViewCell.self, forCellReuseIdentifier: SearchLocationTableViewCell.identifier)
        
        nextButton.setInActive()
        nextButton.setFont(of: 16)
        nextButton.setTitle("다음", for: .normal)
        nextButton.isEnabled = false
    }
    
    private func setUI() {
        view.addSubview(titleLabel)
        view.addSubview(locationImageView)
        view.addSubview(locationTextField)
        view.addSubview(locationSubLabel)
        view.addSubview(locationBottomLine)
        view.addSubview(tableView)
        view.addSubview(mapImageView)
        view.addSubview(mapTitleLabel)
        view.addSubview(mapViewButton)
        view.addSubview(mapBottomLine)
        view.addSubview(mapOverLayTouchedView)
        view.addSubview(nextButton)
    }
    
    private func setConstraint() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(20)
            make.leading.equalTo(16)
        }
        
        locationImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.leading.equalTo(16)
            make.width.height.equalTo(30)
        }
        
        locationTextField.snp.makeConstraints { make in
            make.centerY.equalTo(locationImageView.snp.centerY)
            make.leading.equalTo(locationImageView.snp.trailing).offset(10)
            make.trailing.equalTo(-16)
            make.height.equalTo(locationImageView.snp.height)
        }
        
        locationSubLabel.snp.makeConstraints { make in
            make.leading.equalTo(locationImageView.snp.trailing).offset(10)
            make.bottom.equalTo(locationBottomLine.snp.top).offset(-4)
        }
        
        locationBottomLine.snp.makeConstraints { make in
            make.top.equalTo(locationImageView.snp.bottom).offset(8)
            make.height.equalTo(3)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(locationBottomLine.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top).offset(-10)
        }
        
        mapImageView.snp.makeConstraints { make in
            make.top.equalTo(locationBottomLine.snp.bottom).offset(14)
            make.leading.equalTo(16)
            make.width.height.equalTo(30)
        }
        
        mapTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(mapImageView.snp.centerY)
            make.leading.equalTo(mapImageView.snp.trailing).offset(10)
        }
        
        mapViewButton.snp.makeConstraints { make in
            make.centerY.equalTo(mapImageView.snp.centerY)
            make.trailing.equalTo(-16)
            make.width.equalTo(12)
            make.height.equalTo(20)
        }
        
        mapBottomLine.snp.makeConstraints { make in
            make.top.equalTo(mapImageView.snp.bottom).offset(8)
            make.height.equalTo(3)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
        }
        
        mapOverLayTouchedView.snp.makeConstraints { make in
            make.top.equalTo(mapImageView.snp.top)
            make.leading.equalTo(mapImageView.snp.leading)
            make.trailing.equalTo(-16)
            make.bottom.equalTo(mapBottomLine.snp.top)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.height.equalTo(44)
        }
    }
    
    private func bind() {
        
        locationTextField.rx.controlEvent(.editingDidBegin)
            .subscribe({ [weak self] _ in
                self?.locationSubLabel.isHidden = true
            })
            .disposed(by: disposeBag)
        
        locationTextField.rx.controlEvent(.editingDidEndOnExit)
            .withLatestFrom(locationTextField.rx.text.orEmpty)
            .subscribe({ [weak self] _ in
                
                self?.showLoadingView()
                
                if let query = self?.locationTextField.text {
                    self?.viewModel.searchPlaces(place: query)
                    self?.tableView.isHidden = false
                    self?.mapImageView.isHidden = true
                    self?.mapTitleLabel.isHidden = true
                    self?.mapViewButton.isHidden = true
                    self?.mapBottomLine.isHidden = true
                    self?.mapOverLayTouchedView.isHidden = true
                    self?.locationBottomLine.backgroundColor = AppColor.purple.color
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.searchedPlaces
            .compactMap({ [weak self] searchedPlace -> SearchedPlaces? in
                self?.hideLoadingView(0.25)
                
                if searchedPlace == nil {
                    self?.tableView.isHidden = true
                }
                
                return searchedPlace == nil ? nil : searchedPlace
            })
            .bind(to: tableView.rx.items(cellIdentifier: SearchLocationTableViewCell.identifier, cellType: SearchLocationTableViewCell.self)) { [weak self] index, item, cell in
            cell.setDataSource(searchedPlace: item)
        }
        .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                if let selectedCell = self?.tableView.cellForRow(at: indexPath) as? SearchLocationTableViewCell {
                    self?.tableView.isHidden = true
                    self?.locationSubLabel.isHidden = false
                    self?.mapImageView.isHidden = false
                    self?.mapTitleLabel.isHidden = false
                    self?.mapViewButton.isHidden = false
                    self?.mapBottomLine.isHidden = false
                    self?.mapOverLayTouchedView.isHidden = false
                    self?.nextButton.setActive()
                    self?.nextButton.isEnabled = true
                    
                    if let place = selectedCell.getPlace() {
                        self?.locationTextField.text = place.title
                        self?.locationSubLabel.text = place.roadAddress
                        self?.viewModel.choosePlace(place: place)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        mapOverLayTouchedView.rx.tapGesture().subscribe({ [weak self] _ in
            self?.viewModel.showMapViewController()
        })
        .disposed(by: disposeBag)
        
        nextButton.rx.tap.subscribe({ [weak self] _ in
            if self?.locationTextField.text == "" || self?.locationSubLabel.text == "" || self?.viewModel.getChosenPlace() == nil {
                self?.viewModel.showMapChosenFailure()
            } else {
                self?.viewModel.showInfoViewController()
            }
        })
        .disposed(by: disposeBag)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        disposeBag = DisposeBag()
    }
}
