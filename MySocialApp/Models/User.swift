import Foundation
import RxSwift

class User: BaseCustomField {
    private static let PAGE_SIZE = 10

    var firstName: String?{
        get { return (super.getAttributeInstance("first_name") as! JSONableString?)?.string }
        set(firstName) { super.setStringAttribute(withName: "first_name", firstName) }
    }
    var lastName: String?{
        get { return (super.getAttributeInstance("last_name") as! JSONableString?)?.string }
        set(lastName) { super.setStringAttribute(withName: "last_name", lastName) }
    }
    var fullName: String?{
        get { return (super.getAttributeInstance("full_name") as! JSONableString?)?.string }
        set(fullName) { super.setStringAttribute(withName: "full_name", fullName) }
    }
    var presentation: String?{
        get { return (super.getAttributeInstance("presentation") as! JSONableString?)?.string }
        set(presentation) { super.setStringAttribute(withName: "presentation", presentation) }
    }
    var dateOfBirth: Date?{
        get { return (super.getAttributeInstance("date_of_birth") as! JSONableDate?)?.date }
        set(dateOfBirth) { super.setDateAttribute(withName: "date_of_birth", dateOfBirth) }
    }
    var gender: Gender?{
        get { if let g = (super.getAttributeInstance("gender") as! JSONableString?)?.string { return Gender(rawValue: g) } else { return nil } }
        set(gender) { super.setStringAttribute(withName: "gender", gender?.rawValue) }
    }
    var username: String?{
        get { return (super.getAttributeInstance("username") as! JSONableString?)?.string }
        set(username) { super.setStringAttribute(withName: "username", username) }
    }
    var password: String?{
        get { return (super.getAttributeInstance("password") as! JSONableString?)?.string }
        set(password) { super.setStringAttribute(withName: "password", password) }
    }
    var profilePhoto: Photo?{
        get { return super.getAttributeInstance("profile_photo") as? Photo }
        set(profilePhoto) { super.setAttribute(withName: "profile_photo", profilePhoto) }
    }
    var profileCoverPhoto: Photo?{
        get { return super.getAttributeInstance("profile_cover_photo") as? Photo }
        set(profileCoverPhoto) { super.setAttribute(withName: "profile_cover_photo", profileCoverPhoto) }
    }
    var email: String?{
        get { return (super.getAttributeInstance("email") as! JSONableString?)?.string }
        set(email) { super.setStringAttribute(withName: "email", email) }
    }
    var currentStatus: Status?{
        get { return super.getAttributeInstance("current_status") as? Status }
        set(currentStatus) { super.setAttribute(withName: "current_status", currentStatus) }
    }
    var commonFriends: [User]?{
        get { return (super.getAttributeInstance("common_friends") as! JSONableArray<User>?)?.array }
        set(commonFriends) { super.setArrayAttribute(withName: "common_friends", commonFriends) }
    }
    var isFriend: Bool?{
        get { return (super.getAttributeInstance("is_friend") as! JSONableBool?)?.bool }
        set(isFriend) { super.setBoolAttribute(withName: "is_friend", isFriend) }
    }
    var isRequestedAsFriend: Bool?{
        get { return (super.getAttributeInstance("is_requested_as_friend") as! JSONableBool?)?.bool }
        set(isRequestedAsFriend) { super.setBoolAttribute(withName: "is_requested_as_friend", isRequestedAsFriend) }
    }
    var livingLocation: Location?{
        get { return super.getAttributeInstance("living_location") as? Location }
        set(livingLocation) { super.setAttribute(withName: "living_location", livingLocation) }
    }
    var distance: Int?{
        get { return (super.getAttributeInstance("distance") as! JSONableInt?)?.int }
        set(distance) { super.setIntAttribute(withName: "distance", distance) }
    }
    var flag: UserFlag?{
        get { return super.getAttributeInstance("flag") as? UserFlag }
        set(flag) { super.setAttribute(withName: "flag", flag) }
    }
    var userStat: UserStat? {
        get { return super.getAttributeInstance("user_stat") as? UserStat }
        set(userStat) { super.setAttribute(withName: "user_stat", userStat) }
    }
    var userSettings: UserSettings? {
        get { return super.getAttributeInstance("user_settings") as? UserSettings }
        set(userSettings) { super.setAttribute(withName: "user_settings", userSettings) }
    }
    var spokenLanguage: InterfaceLanguage? {
        get { if let z = (super.getAttributeInstance("spoken_language") as! JSONableString?)?.string { return InterfaceLanguage(rawValue: z) } else { return nil } }
        set(spokenLanguage) { super.setStringAttribute(withName: "spoken_language", spokenLanguage?.rawValue) }
    }
    var authorities: [String] {
        get { if let a = super.getAttributeInstance("authorities") as? JSONableArray<JSONableString> { return a.array.flatMap { $0.string } } else { return [] } }
    }
    
    internal override func getAttributeCreationMethod(name: String) -> CreationMethod {
        switch name {
        case "first_name", "last_name", "full_name", "presentation", "gender", "username", "password", "email", "spoken_language":
            return JSONableString().initAttributes
        case "date_of_birth":
            return JSONableDate().initAttributes
        case "profile_photo", "profile_cover_photo":
            return Photo().initAttributes
        case "current_status":
            return Status().initAttributes
        case "common_friends":
            return JSONableArray<User>().initAttributes
        case "is_friend", "is_requested_as_friend", "stat_status_active":
            return JSONableBool().initAttributes
        case "living_location":
            return Location().initAttributes
        case "distance":
            return JSONableInt().initAttributes
        case "flag":
            return UserFlag().initAttributes
        case "user_stat":
            return UserStat().initAttributes
        case "user_settings":
            return UserSettings().initAttributes
        case "authorities":
            return JSONableArray<JSONableString>().initAttributes
        default:
            return super.getAttributeCreationMethod(name: name)
        }
    }
    
    override func getBodyImageURL() -> String? {
        return self.displayedPhoto?.getBodyImageURL()
    }
    
    func blockingSave() throws -> User? {
        return try self.save().toBlocking().first()
    }
    
    func save() -> Observable<User> {
        if let s = self.session {
            return s.clientService.account.update(self)
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
    
    func blockingRequestAsFriend() throws -> User? {
        return try requestAsFriend().toBlocking().first()
    }
    
    func requestAsFriend() -> Observable<User> {
        if let s = self.session {
            return s.clientService.user.requestAsFriend(self)
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
    
    func blockingCancelFriendRequest() throws -> Bool? {
        return try cancelFriendRequest().toBlocking().first()
    }
    
    func cancelFriendRequest() -> Observable<Bool> {
        if let s = self.session {
            return s.clientService.user.cancelRequestAsFriend(self)
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
    
    func blockingAcceptFriendRequest() throws -> User? {
        return try acceptFriendRequest().toBlocking().first()
    }
    
    func acceptFriendRequest() -> Observable<User> {
        if let s = self.session {
            return s.clientService.user.acceptAsFriend(self)
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
    
    func blockingRefuseFriendRequest() throws -> Bool? {
        return try refuseFriendRequest().toBlocking().first()
    }
    
    func refuseFriendRequest() -> Observable<Bool> {
        if let s = self.session {
            return s.clientService.user.refuseAsFriend(self)
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
    
    private func streamFriends(_ page: Int, _ to: Int, _ obs: AnyObserver<User>) {
        if to > 0, let session = self.session {
            let _ = session.clientService.user.list(page, size: min(User.PAGE_SIZE,to - (page * User.PAGE_SIZE)), friendsWith: self).subscribe {
                e in
                if let e = e.element?.array {
                    let _ = e.map { obs.onNext($0) }
                    if e.count < User.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.streamFriends(page + 1, to - User.PAGE_SIZE, obs)
                    }
                } else {
                    obs.onCompleted()
                }
            }
        } else {
            obs.onCompleted()
        }
    }
    
    func blockingListFriends() throws -> [User]? {
        return try listFriends().toBlocking().toArray()
    }
    
    func listFriends() -> Observable<User> {
        return Observable.create {
            obs in
            self.streamFriends(0, Int.max, obs)
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    private func streamFeed(_ page: Int, _ to: Int, _ obs: AnyObserver<Feed>) {
        if to > 0, let session = self.session {
            let _ = session.clientService.feed.list(page, size: min(User.PAGE_SIZE,to - (page * User.PAGE_SIZE)), forUser: self).subscribe {
                e in
                if let e = e.element?.array {
                    let _ = e.map { obs.onNext($0) }
                    if e.count < User.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.streamFeed(page + 1, to - User.PAGE_SIZE, obs)
                    }
                } else {
                    obs.onCompleted()
                }
            }
        } else {
            obs.onCompleted()
        }
    }
    
    func blockingStreamNewsFeed(limit: Int = Int.max) throws -> [Feed]? {
        return try streamNewsFeed(limit: limit).toBlocking().toArray()
    }
    
    func streamNewsFeed(limit: Int = Int.max) -> Observable<Feed> {
        return listNewsFeed(page: 0, size: limit)
    }
    
    func blockingListNewsFeed(page: Int = 0, size: Int = 10) throws -> [Feed] {
        return try listNewsFeed(page: page, size: size).toBlocking().toArray()
    }
    
    func listNewsFeed(page: Int = 0, size: Int = 10) -> Observable<Feed> {
        return Observable.create {
            obs in
            self.streamFeed(page, page*User.PAGE_SIZE+size, obs)
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    func blockingSendWallPost(_ feedPost: FeedPost) throws -> Feed? {
        return try sendWallPost(feedPost).toBlocking().first()
    }
    
    func sendWallPost(_ feedPost: FeedPost) -> Observable<Feed> {
        if let s = self.session {
            if let p = feedPost.photo {
                return Observable.create {
                    obs in
                    s.clientService.textWallMessage.post(forTarget: self, message: feedPost.textWallMessage, image: p) {
                        e in
                        if let e = e as? Feed {
                            obs.onNext(e)
                        } else {
                            obs.onCompleted()
                        }
                    }
                    return Disposables.create()
                    }.observeOn(MainScheduler.instance)
                    .subscribeOn(MainScheduler.instance)
            } else if let t = feedPost.textWallMessage {
                return Observable.create {
                    obs in
                    let _ = s.clientService.textWallMessage.post(forTarget: self, message: t).subscribe {
                        e in
                        if let e = e.element as? Feed {
                            obs.onNext(e)
                        } else if let e = e.error {
                            obs.onError(e)
                        } else {
                            obs.onCompleted()
                        }
                    }
                    return Disposables.create()
                    }.observeOn(MainScheduler.instance)
                    .subscribeOn(MainScheduler.instance)
            } else {
                return Observable.create {
                    obs in
                    let e = RestError()
                    e.setStringAttribute(withName: "message", "At least message or photo is mandatory to post a feed")
                    obs.onError(e)
                    return Disposables.create()
                    }.observeOn(MainScheduler.instance)
                    .subscribeOn(MainScheduler.instance)
            }
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        }
    }
    
    func blockingSendPrivateMessage(_ conversationMessagePost: ConversationMessagePost) throws -> ConversationMessage? {
        return try sendPrivateMessage(conversationMessagePost).toBlocking().first()
    }
    
    func sendPrivateMessage(_ conversationMessagePost: ConversationMessagePost) -> Observable<ConversationMessage> {
        if let s = session {
            return Observable.create {
                obs in
                let conversation = Conversation()
                conversation.members = [self]
                let _ = s.clientService.conversation.post(conversation).subscribe {
                    e in
                    if let e = e.element {
                        let _ = e.sendMessage(conversationMessagePost).subscribe {
                            e in
                            if let e = e.element {
                                obs.onNext(e)
                            } else if let e = e.error {
                                obs.onError(e)
                            } else {
                                obs.onCompleted()
                            }
                        }
                    }
                }
                return Disposables.create()
                }.observeOn(MainScheduler.instance)
                .subscribeOn(MainScheduler.instance)
        } else {
            return Observable.create {
                obs in
                let e = RestError()
                e.setStringAttribute(withName: "message", "No session associated with this entity")
                obs.onError(e)
                return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
        }
    }
    
    private func streamGroup(_ page: Int, _ to: Int, _ obs: AnyObserver<Group>) {
        if to > 0, let session = self.session {
            let _ = session.clientService.group.list(forUser: self, page: page, size: min(User.PAGE_SIZE,to - (page * User.PAGE_SIZE))).subscribe {
                e in
                if let e = e.element?.array {
                    let _ = e.map { obs.onNext($0) }
                    if e.count < User.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.streamGroup(page + 1, to - User.PAGE_SIZE, obs)
                    }
                } else {
                    obs.onCompleted()
                }
            }
        } else {
            obs.onCompleted()
        }
    }

    func blockingStreamGroup(limit: Int = Int.max) throws -> [Group] {
        return try streamGroup(limit: limit).toBlocking().toArray()
    }
    
    func streamGroup(limit: Int = Int.max) -> Observable<Group> {
        return listGroup(page: 0, size: limit)
    }
    
    func blockingListGroup(page: Int = 0, size: Int = 10) throws -> [Group] {
        return try listGroup(page: page, size: size).toBlocking().toArray()
    }
    
    func listGroup(page: Int = 0, size: Int = 10) -> Observable<Group> {
        return Observable.create {
            obs in
            self.streamGroup(page, page*User.PAGE_SIZE+size, obs)
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
    
    private func streamEvent(_ page: Int, _ to: Int, _ obs: AnyObserver<Event>) {
        if to > 0, let session = self.session, let id = self.id {
            let _ = session.clientService.event.list(forMember: id, page: page, size: min(User.PAGE_SIZE,to - (page * User.PAGE_SIZE))).subscribe {
                e in
                if let e = e.element?.array {
                    let _ = e.map { obs.onNext($0) }
                    if e.count < User.PAGE_SIZE {
                        obs.onCompleted()
                    } else {
                        self.streamEvent(page + 1, to - User.PAGE_SIZE, obs)
                    }
                } else {
                    obs.onCompleted()
                }
            }
        } else {
            obs.onCompleted()
        }
    }

    func blockingStreamEvent(limit: Int = Int.max) throws -> [Event] {
        return try streamEvent(limit: limit).toBlocking().toArray()
    }
    
    func streamEvent(limit: Int = Int.max) -> Observable<Event> {
        return listEvent(page: 0, size: limit)
    }
    
    func blockingListEvent(page: Int = 0, size: Int = 10) throws -> [Event] {
        return try listEvent(page: page, size: size).toBlocking().toArray()
    }
    
    func listEvent(page: Int = 0, size: Int = 10) -> Observable<Event> {
        return Observable.create {
            obs in
            self.streamEvent(page, page*User.PAGE_SIZE+size, obs)
            return Disposables.create()
            }.observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
    }
}
