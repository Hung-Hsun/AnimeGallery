//
//  AnimeGalleryTests.swift
//  AnimeGalleryTests
//
//  Created by 林宏勳 on 2022/6/10.
//

import XCTest
@testable import AnimeGallery

class AnimeGalleryTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }

    func testGetTopAnimes() throws {
        
        let session = NetworkSessionMock()
        let server = RemoteServer(session: session)
        
        let dic = [
            "pagination": [
                "has_next_page": true,
                "current_page": 1
            ],
            "data": [[
                "mal_id": 50265,
                "url": "https://myanimelist.net/anime/50265/Spy_x_Family",
                "images": [
                    "jpg": [
                        "image_url": "https://cdn.myanimelist.net/images/anime/1441/122795.jpg",
                        "small_image_url": "https://cdn.myanimelist.net/images/anime/1441/122795t.jpg",
                        "large_image_url": "https://cdn.myanimelist.net/images/anime/1441/122795l.jpg"
                    ]
                ],
                "title": "Spy x Family",
                "type": "TV",
                "aired": [
                    "from": "2022-04-09T00:00:00+00:00",
                    "to": "2022-06-30T00:00:00+00:00"
                ],
                "rank": 11
            ]]] as [String : Any]
        
        let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        
        session.data = jsonData

        server.getTopAnimes(type: .all, filter: .all, page: 1) { (result) in
            switch result {
            case .failure(_):
                XCTFail()
            case .success(let data):
                if let page = data.currentPage {
                    XCTAssert(page == 1, "Returned currentPage not correct")
                }
                
                XCTAssert(data.hasNextPage == true, "Returned hasNextPage not correct")
                XCTAssert(data.data?.first?.title == "Spy x Family", "Returned title not correct")
            }
        }
    }

    func testPerformanceExample() throws {
        self.measure {
        }
    }

}

class NetworkSessionMock: NetworkSession {
    var data: Data?
    var error: Error?

    func loadData(from url: URLRequest,
                  completionHandler: @escaping (Data?, Error?) -> Void) {
        completionHandler(data, error)
    }
}
