require File.dirname(__FILE__) + '/../../../../config/environment'
require File.dirname(__FILE__) + '/../lib/render_with'

class String
  def to_regexp
    Regexp.new Regexp.escape(self), Regexp::IGNORECASE
  end
end
