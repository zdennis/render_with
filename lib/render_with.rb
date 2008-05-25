class Renderer
  include ActionController::UrlWriter

  attr_reader :page
  
  def initialize(page=nil, context=nil)
    if context
      @context = context
      
      # allow an array of assignments to be passed in for testing
      assigns = context.is_a?(Hash) ? context : context.assigns
      
      assigns.each_pair do |key,value|
        instance_variable_set "@#{key}", value
      end
    end
    
    if page
      @page = page
    elsif context
      @page = ActionView::Helpers::PrototypeHelper::JavaScriptGenerator.new(context){}
    else
      raise ArgumentError, "can't construct a page without a context"
    end
  end
  
  def to_s
    @page.to_s
  end

private
  
  def method_missing(*args, &block)
    @context.send *args, &block
  end
end

class ActionView::Base
  def render_with(renderer_name, &block)
    page = eval("page", block.binding)
    renderer = "#{renderer_name}_renderer".classify.constantize.new(page, @template)
    yield renderer
  end
end

# Alternative way to use render_with. Doesn't rely on eval voodoo.
# example use:
# page.render_with :foo do |foo|
#   foo.do_something_cool
# end
module ActionView::Helpers::PrototypeHelper::JavaScriptGenerator::GeneratorMethods
  def render_with(renderer_name, &block)
    renderer = "#{renderer_name}_renderer".classify.constantize.new(self, @context)
    yield renderer
  end
end
