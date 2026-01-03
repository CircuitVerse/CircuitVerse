---
sidebar_position: 10
---

# Recording video

Playwright allows us to record the browser screen during automation.
https://playwright.dev/docs/videos

With this awesome feature, NO NEED to keep our attention focused on the screen during the automation :)

```ruby {7,11-12,15-16}
require 'tmpdir'

playwright.chromium.launch do |browser|
  Dir.mktmpdir do |tmp|
    video_path = nil

    browser.new_context(record_video_dir: tmp) do |context|
      page = context.new_page
      # play with page

      # NOTE: Page#video is available **only when browser context is alive.**
      video_path = page.video.path
    end

    # NOTE: video is completely saved **only after browser context is closed.**
    handle_video_as_you_like(video_path)
  end
```

## Specify where to put videos

Playwright puts videos on the directory specified at `record_video_dir`.

The previous example uses [Dir#mktmpdir](https://docs.ruby-lang.org/ja/latest/method/Dir/s/mktmpdir.html) for storing videos into a temprary directory. Also we simply specify a relative or absolute path like `./my_videos/` or `/path/to/videos`.

## Getting video path and recorded video

This is really confusing for beginners, but in Playwright

* We can get the video path **only when page is alive (before calling BrowserContext#close or Page#close)**
* We can acquire the completely saved video **only after calling  BrowserContext#close**

So in most case, we have to store the video path in advance, and handle the saved video after BrowserContext is closed, as is shown the previous example code.

### Using `video#save_as(path)`

If you want to just save video to somewhere without handling the video using `File.open`, you can simply use `video#save_as(path_to_save)`.

```ruby {5,8,12-13}
require 'tmpdir'

playwright.chromium.launch do |browser|
  Dir.mktmpdir do |tmp|
    page = nil

    browser.new_context(record_video_dir: tmp) do |context|
      page = context.new_page
      # play with page
    end

    # NOTE: video is completely saved **only after browser context is closed.**
    page.video.save_as('my-important-video.webm')
  end
```

## Using screen recording from Capybara driver

capybara-playwright-driver exposes a function to store the video.

```ruby
Capybara.current_session.driver.on_save_screenrecord do |video_path|
  # Handling recorded video here.
  # video_path is like '/var/folders/xx/xxxxxxxxxx_xxxxxxxx/T/xxxxxxx-xxxxx-xxxxxxxx/e6bde41c5d05b2a02344b058bf1bfea2.webm'
end
```

With this callback registration, we can record the videos without specifying `record_video_dir` explicitly or preparing a temporary directory. capybara-playwright-driver automatically prepare and set `record_video_dir` internally.
