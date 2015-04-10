# Encoding: UTF-8

guard :rspec, all_on_start: true, notification: false do
  watch(%r{^spec/.+_spec\.rb$})
  watch('spec/spec_helper.rb')  { 'spec' }

  watch(%r{^recipes/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^attributes/(.+)\.rb$})
  watch(%r{^files/(.+)})
  watch(%r{^templates/(.+)})
  watch(%r{^providers/(.+)\.rb})
  watch(%r{^resources/(.+)\.rb})
  watch(%r{^libraries/(.+)\.rb})
end

# guard :foodcritic, cookbook_paths: '.', cli: '-t ~FC023 -f any' do
#   watch(/^.*\.rb$/)
# end

# guard :kitchen do
#   watch(/test\/.+/)
#   watch(/^recipes\/(.+)\.rb$/)
#   watch(/^attributes\/(.+)\.rb$/)
#   watch(/^files\/(.+)/)
#   watch(/^templates\/(.+)/)
#   watch(/^providers\/(.+)\.rb/)
#   watch(/^resources\/(.+)\.rb/)
# end
