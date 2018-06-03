import Foundation
import RxSwift

class FluentNotification {
    private static let PAGE_SIZE = 10
    
    var session: Session
    
    lazy var unread: Unread = {
        Unread(self.session)
    }()
    lazy var read: Read = {
        Read(self.session)
    }()

    public init(_ session: Session) {
        self.session = session
    }
    
    class Unread {
        var session: Session
        
        public init(_ session: Session) {
            self.session = session
        }
        
        private func stream(_ page: Int, _ to: Int, _ obs: AnyObserver<PreviewNotification>) {
            if to > 0 {
                let _ = session.clientService.notification.listUnread(page, size: min(FluentNotification.PAGE_SIZE,to - (page * FluentNotification.PAGE_SIZE))).subscribe {
                    e in
                    if let e = e.element?.array {
                        let _ = e.map { obs.onNext($0) }
                        if e.count < FluentNotification.PAGE_SIZE {
                            obs.onCompleted()
                        } else {
                            self.stream(page + 1, to - FluentNotification.PAGE_SIZE, obs)
                        }
                    } else if let e = e.error {
                        obs.onError(e)
                    } else {
                        obs.onCompleted()
                    }
                }
            } else {
                obs.onCompleted()
            }
        }

        func blockingStream(limit: Int = Int.max) throws -> [PreviewNotification] {
            return try stream(limit: limit).toBlocking().toArray()
        }
        
        func stream(limit: Int = Int.max) -> Observable<PreviewNotification> {
            return list(page: 0, size: limit)
        }
        
        func blockingList(page: Int = 0, size: Int = 10) throws -> [PreviewNotification] {
            return try list(page: page, size: size).toBlocking().toArray()
        }
        
        func list(page: Int = 0, size: Int = 10) -> Observable<PreviewNotification> {
            return Observable.create {
                obs in
                self.stream(page, size, obs)
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
    
    class Read {
        var session: Session
        
        public init(_ session: Session) {
            self.session = session
        }
        
        private func stream(_ page: Int, _ to: Int, _ obs: AnyObserver<PreviewNotification>) {
            if to > 0 {
                let _ = session.clientService.notification.listRead(page, size: min(FluentNotification.PAGE_SIZE,to - (page * FluentNotification.PAGE_SIZE))).subscribe {
                    e in
                    if let e = e.element?.array {
                        let _ = e.map { obs.onNext($0) }
                        if e.count < FluentNotification.PAGE_SIZE {
                            obs.onCompleted()
                        } else {
                            self.stream(page + 1, to - FluentNotification.PAGE_SIZE, obs)
                        }
                    } else if let e = e.error {
                        obs.onError(e)
                    } else {
                        obs.onCompleted()
                    }
                }
            } else {
                obs.onCompleted()
            }
        }
        
        func blockingStream(limit: Int = Int.max) throws -> [PreviewNotification] {
            return try stream(limit: limit).toBlocking().toArray()
        }
        
        func stream(limit: Int = Int.max) -> Observable<PreviewNotification> {
            return list(page: 0, size: limit)
        }
        
        func blockingList(page: Int = 0, size: Int = 10) throws -> [PreviewNotification] {
            return try list(page: page, size: size).toBlocking().toArray()
        }
        
        func list(page: Int = 0, size: Int = 10) -> Observable<PreviewNotification> {
            return Observable.create {
                obs in
                self.stream(page, size, obs)
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
}
