//
//  Video.swift
//
//
//  Created by Ethan Lipnik on 8/4/22.
//

import Foundation

public struct Video: Codable, Identifiable, Hashable {
    public var id: Int
    public var pageURL: URL?
    public var type: VideoType
    public var tags: [String]
    public var duration: Int
    /// Legacy Vimeo thumbnail ID; Pixabay no longer returns it (use `thumbnailURL`).
    public var pictureID: String?
    public var items: [Item: Item.VideoItem]
    public var views: Int
    public var downloads: Int
    public var comments: Int
    public var user: User

    public enum VideoType: String, Codable {
        case all
        case film
        case animation
    }

    public enum Item: Codable, Hashable {
        case large
        case medium
        case small
        case tiny

        public struct VideoItem: Codable, Hashable {
            public var url: URL
            public var width: Int
            public var height: Int
            public var size: Int
            public var thumbnail: URL?
        }
    }

    /// Preview image: Pixabay's per-size thumbnail, or the legacy Vimeo one for old responses.
    public var thumbnailURL: URL? {
        if let url = [Item.medium, .small, .large, .tiny].lazy.compactMap({ items[$0]?.thumbnail }).first {
            return url
        }
        return pictureID.flatMap { URL(string: "https://i.vimeocdn.com/video/\($0)_720.jpg") }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case pageURL
        case type
        case tags
        case duration
        case pictureID = "picture_id"
        case items = "videos"
        case views
        case downloads
        case comments

        case username = "user"
        case userID = "user_id"
        case userProfilePic = "userImageURL"

        case large
        case medium
        case small
        case tiny
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        pageURL = try? container.decode(URL.self, forKey: .pageURL)
        type = try container.decode(VideoType.self, forKey: .type)
        tags = (try container.decode(String.self, forKey: .tags)).components(separatedBy: ", ")
            .map { String($0) }
        duration = try container.decodeIfPresent(Int.self, forKey: .duration) ?? 0
        pictureID = try? container.decode(String.self, forKey: .pictureID)
        views = try container.decodeIfPresent(Int.self, forKey: .views) ?? 0
        downloads = try container.decodeIfPresent(Int.self, forKey: .downloads) ?? 0
        comments = try container.decodeIfPresent(Int.self, forKey: .comments) ?? 0

        items = [:]
        let videosContainer = try container.nestedContainer(
            keyedBy: CodingKeys.self,
            forKey: .items
        )
        if let largeVideo = try? videosContainer.decode(Item.VideoItem.self, forKey: .large) {
            items[.large] = largeVideo
        }
        if let mediumVideo = try? videosContainer.decode(Item.VideoItem.self, forKey: .medium) {
            items[.medium] = mediumVideo
        }
        if let smallVideo = try? videosContainer.decode(Item.VideoItem.self, forKey: .small) {
            items[.small] = smallVideo
        }
        if let tinyVideo = try? videosContainer.decode(Item.VideoItem.self, forKey: .tiny) {
            items[.tiny] = tinyVideo
        }

        let username = try container.decode(String.self, forKey: .username)
        let userID = try container.decode(Int.self, forKey: .userID)
        let userProfilePic = try? container.decode(URL.self, forKey: .userProfilePic)
        user = User(id: userID, name: username, profilePic: userProfilePic)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(pageURL, forKey: .pageURL)
        try container.encode(type, forKey: .type)
        try container.encode(tags.joined(separator: ", "), forKey: .tags)
        try container.encode(duration, forKey: .duration)
        try container.encodeIfPresent(pictureID, forKey: .pictureID)
        try container.encode(views, forKey: .views)
        try container.encode(downloads, forKey: .downloads)
        try container.encode(comments, forKey: .comments)

        var videosContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .items)
        try videosContainer.encodeIfPresent(items[.large], forKey: .large)
        try videosContainer.encodeIfPresent(items[.medium], forKey: .medium)
        try videosContainer.encodeIfPresent(items[.small], forKey: .small)
        try videosContainer.encodeIfPresent(items[.tiny], forKey: .tiny)

        try container.encode(user.id, forKey: .userID)
        try container.encode(user.name, forKey: .username)
        try container.encode(user.profilePic, forKey: .userProfilePic)
    }
}
