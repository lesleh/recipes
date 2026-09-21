require "test_helper"

# Several compact form controls are labelled with aria-label rather than a visible
# <label>, so Capybara needs to match on those.
Capybara.enable_aria_label = true

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
end
