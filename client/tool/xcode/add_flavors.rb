require "xcodeproj"

project_path, bundle_id, product_name, deep_link_scheme = ARGV
abort "usage: ruby add_flavors.rb <Runner.xcodeproj> <bundle-id> <product-name> <deep-link-scheme>" unless deep_link_scheme

FLAVORS = {
  "prod" => { bundle_id: bundle_id, product_name: product_name, icon: "AppIcon", scheme: deep_link_scheme },
  "dev" => {
    bundle_id: "#{bundle_id}.dev",
    product_name: "#{product_name} Dev",
    icon: "devAppIcon",
    scheme: "#{deep_link_scheme}-dev",
  },
}.freeze
BUILD_TYPES = %w[Debug Release Profile].freeze

project = Xcodeproj::Project.open(project_path)
runner = project.targets.find { |target| target.name == "Runner" }
lists = [project.build_configuration_list] + project.targets.map(&:build_configuration_list)

def copy_configuration(project, list, source_name, name)
  return list[name] if list[name]

  source = list[source_name]
  copy = project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
  copy.name = name
  copy.build_settings = Marshal.load(Marshal.dump(source.build_settings))
  copy.base_configuration_reference = source.base_configuration_reference
  list.build_configurations << copy
  copy
end

BUILD_TYPES.each do |build_type|
  FLAVORS.each do |flavor, values|
    name = "#{build_type}-#{flavor}"
    lists.each { |list| copy_configuration(project, list, build_type, name) }
    settings = runner.build_configuration_list[name].build_settings
    settings["PRODUCT_BUNDLE_IDENTIFIER"] = values[:bundle_id]
    settings["PRODUCT_NAME"] = values[:product_name]
    settings["ASSETCATALOG_COMPILER_APPICON_NAME"] = values[:icon]
    settings["DEEP_LINK_SCHEME"] = values[:scheme]
  end
end
project.save

FLAVORS.each_key do |flavor|
  scheme = Xcodeproj::XCScheme.new
  scheme.add_build_target(runner)
  scheme.set_launch_target(runner)
  scheme.launch_action.build_configuration = "Debug-#{flavor}"
  scheme.test_action.build_configuration = "Debug-#{flavor}"
  scheme.analyze_action.build_configuration = "Debug-#{flavor}"
  scheme.profile_action.build_configuration = "Profile-#{flavor}"
  scheme.archive_action.build_configuration = "Release-#{flavor}"
  scheme.save_as(project_path, flavor, true)
end
