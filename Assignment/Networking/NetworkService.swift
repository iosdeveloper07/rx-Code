//
//  NetworkService.swift
//  Assignment
//
//  Created by Shashank on 07/04/25.
//

import Foundation
import Alamofire
import RxSwift

class NetworkService {
    static let shared = NetworkService()
    private init() {}

    func fetchPosts() -> Observable<[PostDecodable]> {
        return Observable.create { observer in
            let request = AF.request(APIConstants.postsUrl(), method: .get)
                .validate()
                .responseDecodable(of: [PostDecodable].self) { response in
                    switch response.result {
                    case .success(let posts):
                        observer.onNext(posts)
                        observer.onCompleted()
                    case .failure(let error):
                        print("\(error.localizedDescription)")
                        observer.onError(error)
                    }
            }

            return Disposables.create {
                request.cancel()
            }
        }
    }
}
