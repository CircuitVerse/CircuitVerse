# frozen_string_literal: true

target :app do
  signature "sig"
  meta_tags_path = Gem::Specification.find_by_name("meta-tags").gem_dir
  rbs_files = Pathname.glob(File.join(meta_tags_path, "sig/**/*.rbs")).reject {|path| path.basename.to_s == "_rails.rbs" }
  signature *rbs_files
end
