//
//  ViewController.swift
//  M17_Concurrency
//
//  Created by Maxim NIkolaev on 08.12.2021.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    var imageArray: [UIImage] = []
    let group = DispatchGroup()
    
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fillEqually
        return view
    }()
    
    let service = Service()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoader()
        setupStack()
        
        for _ in 1...5 {
            onLoad()
        }
        group.notify(queue: .main) { [ weak self ] in
            self?.fillStack()
        }
    }

    private func onLoad() {
        group.enter()
        service.getImageURL { [ weak self ] urlString, error in
            guard
                let urlString = urlString
            else {
                return
            }
            
            guard let image = self?.service.loadImage(urlString: urlString) else {
                return
            }
            DispatchQueue.main.sync {
                self?.imageArray.append(image)
            }
            self?.group.leave()
        }
    }
    func setupStack() {
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        stackView.isHidden = true
    
    }
    
    func setupLoader() {
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        activityIndicator.startAnimating()
    }
    
    func fillStack() {
        for image in imageArray {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
            imageView.snp.makeConstraints { make in
                make.height.equalTo(100)
            }
            stackView.addArrangedSubview(imageView)
        }
        stackView.isHidden = false
        activityIndicator.stopAnimating()
    }
    
}

