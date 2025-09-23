say "Create controllers directory"
empty_directory "app/javascript/controllers"
copy_file "#{__dir__}/app/javascript/controllers/index_for_importmap.js",
  "app/javascript/controllers/index.js"
copy_file "#{__dir__}/app/javascript/controllers/application.js",
  "app/javascript/controllers/application.js"
copy_file "#{__dir__}/app/javascript/controllers/hello_controller.js",
  "app/javascript/controllers/hello_controller.js"

say "Import Stimulus controllers"
append_to_file "app/javascript/application.js", %(import "controllers"\n)

say "Pin Stimulus"
say %(Appending: pin "@hotwired/stimulus", to: "stimulus.min.js")
append_to_file "config/importmap.rb", %(pin "@hotwired/stimulus", to: "stimulus.min.js"\n)

say %(Appending: pin "@hotwired/stimulus-loading", to: "stimulus-loading.js")
append_to_file "config/importmap.rb", %(pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"\n)

say "Pin all controllers"
say %(Appending: pin_all_from "app/javascript/controllers", under: "controllers")
append_to_file "config/importmap.rb", %(pin_all_from "app/javascript/controllers", under: "controllers"\n)
