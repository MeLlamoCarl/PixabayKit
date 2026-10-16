> **Fork notice:** fork of [EthanLipnik/PixabayKit](https://github.com/EthanLipnik/PixabayKit)
> used by [MeLlamoCarl/Meshy](https://github.com/MeLlamoCarl/Meshy). Original work by Ethan
> Lipnik; licensed under the MIT License (see `LICENSE.txt`). Fork changes: decodes the current
> API response (Pixabay dropped `picture_id`; thumbnails now come from each video size's
> `thumbnail`), `PixabayError.invalidAPIKey`, `validateAPIKey()`, and requests that bypass the
> shared URL cache so a revoked key is detected.


# PixabayKit

PixabayKit is a Swift package that makes it easy to interact with the Pixabay API to fetch and manage video data. It's a simple, efficient, and powerful way to integrate Pixabay's vast library of videos into your Swift applications.

## Requirements

- Swift 5.8+
- iOS 13+
- macOS 12+
- watchOS 6+
- tvOS 13+

## Installation

To add PixabayKit to your Swift package, add the following line to your package dependencies in your `Package.swift` file:

```swift
.package(url: "https://github.com/EthanLipnik/PixabayKit.git", from: "1.0.0")
```

Then add `PixabayKit` to your target dependencies:

```swift
.target(name: "YourTarget", dependencies: ["PixabayKit"]),
```

## Usage

First, import PixabayKit at the top of your Swift file:

```swift
import PixabayKit
```

Then, initialize PixabayKit with your Pixabay API key:

```swift
private let pixabay = PixabayKit("PIXABAY_API_KEY")
```

To search videos, you can use the `searchVideos` function with async/await like this:

```swift
let videos = try await pixabay.searchVideos(
    searchText,
    safeSearch: shouldEnableSafeSearch,
    type: .all,
    count: 200
)
```

## `searchVideos` function

The `searchVideos` function allows you to search videos with a variety of parameters:

- `query`: The search term. Defaults to nil.
- `safeSearch`: Enables or disables safe search. Defaults to true.
- `order`: Sorts the results by popularity or latest. Defaults to "popular".
- `type`: The type of the video. Defaults to `.all`.
- `editorsChoice`: Only return videos that have been marked as Editor's Choice. Defaults to false.
- `category`: The category of the video. Defaults to `.all`.
- `minWidth`: The minimum width of the video. Defaults to 0.
- `minHeight`: The minimum height of the video. Defaults to 0.
- `count`: The number of results to return. Defaults to 20.

## License

PixabayKit is released under the MIT License. See the [LICENSE](LICENSE.md) file for more information.

## Support

If you have any questions or suggestions, feel free to open an issue or submit a pull request.
