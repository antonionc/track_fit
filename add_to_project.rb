require 'xcodeproj'

project_path = '/Users/anavarro/workspace/github/track_fit/track_fit/track_fit.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Targets
app_target = project.targets.find { |t| t.name == 'track_fit' }
widget_target = project.targets.find { |t| t.name == 'TrackFitWidget' }

abort("Could not find targets") unless app_target && widget_target

# Add files dynamically
def add_file_to_target(project, target, file_path, group_path)
  group = project.main_group
  group_path.split('/').each do |g|
    group = group.children.find { |c| c.display_name == g || c.name == g } || group.new_group(g)
  end
  
  file_ref = group.files.find { |f| f.real_path.to_s == file_path } || group.new_file(file_path)
  
  # Avoid adding to build phase if already there
  unless target.source_build_phase.files_references.include?(file_ref)
    target.source_build_phase.add_file_reference(file_ref)
    puts "Added #{file_path} to #{target.name}"
  else
    puts "#{file_path} already in #{target.name}"
  end
end

shared_attrs_path = '/Users/anavarro/workspace/github/track_fit/track_fit/track_fit/Shared/RestTimerAttributes.swift'
live_activity_manager_path = '/Users/anavarro/workspace/github/track_fit/track_fit/track_fit/LiveActivityManager.swift'

add_file_to_target(project, app_target, shared_attrs_path, 'track_fit/Shared')
add_file_to_target(project, widget_target, shared_attrs_path, 'track_fit/Shared')
add_file_to_target(project, app_target, live_activity_manager_path, 'track_fit')

# Enable Live Activities for App Target
app_target.build_configurations.each do |config|
  config.build_settings['INFOPLIST_KEY_NSSupportsLiveActivities'] = 'YES'
end

project.save
puts "Successfully saved project."
