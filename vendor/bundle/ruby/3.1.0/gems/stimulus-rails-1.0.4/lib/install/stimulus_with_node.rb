say "Create controllers directory"
empty_directory "app/javascript/controllers"
copy_file "#{__dir__}/app/javascript/controllers/index_for_node.js",
  "app/javascript/controllers/index.js"
copy_file "#{__dir__}/app/javascript/controllers/application.js",
  "app/javascript/controllers/application.js"
copy_file "#{__dir__}/app/javascript/controllers/hello_controller.js",
  "app/javascript/controllers/hello_controller.js"

if (Rails.root.join("app/javascript/application.js")).exist?
  say "Import Stimulus controllers"
  append_to_file "app/javascript/application.js", %(import "./controllers"\n)
else
  say %(Couldn't find "app/javascript/application.js".\nYou must import "./controllers" in your JavaScript entrypoint file), :red
end

say "Install Stimulus"
run "yarn add @hotwired/stimulus"
