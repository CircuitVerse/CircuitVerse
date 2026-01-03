---
sidebar_position: 10
---

# FileChooser


[FileChooser](./file_chooser) objects are dispatched by the page in the [`event: Page.fileChooser`] event.

```ruby
file_chooser = page.expect_file_chooser do
  page.get_by_text("Upload file").click # action to trigger file uploading
end
file_chooser.set_files("myfile.pdf")
```

## element

```
def element
```


Returns input element associated with this file chooser.

## multiple?

```
def multiple?
```


Returns whether this file chooser accepts multiple files.

## page

```
def page
```


Returns page this file chooser belongs to.

## set_files

```
def set_files(files, noWaitAfter: nil, timeout: nil)
```
alias: `files=`


Sets the value of the file input this chooser is associated with. If some of the `filePaths` are relative paths, then
they are resolved relative to the current working directory. For empty array, clears the selected files.
