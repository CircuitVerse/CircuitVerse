say "Install rollup with config"
copy_file "#{__dir__}/rollup.config.js", "rollup.config.js"
run "yarn add rollup @rollup/plugin-node-resolve"

say "Add build script"
build_script = "rollup -c rollup.config.js"

if (`npx -v`.to_f < 7.1 rescue "Missing")
  say %(Add "scripts": { "build": "#{build_script}" } to your package.json), :green
else
  run %(npm set-script build "#{build_script}")
  run %(yarn build)
end
