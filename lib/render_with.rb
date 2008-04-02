class Renderer
  def initialize(context, generator_factory=ActionView::Helpers::PrototypeHelper::JavaScriptGenerator)
    # include_helpers_from(context)
    @context = context
    context.assigns.each_pair do |key,value|
      instance_variable_set "@#{key}", value
    end
    @page = generator_factory.new(context) {}
  end
  
  def to_s
    @page.to_s
  end

private
  # def include_helpers_from(context)
  #   context.extended_by.each do |mod|
  #     extend mod
  #   end
  # end
  
  def method_missing(*args, &block)
    if @page.respond_to?(args.first)
      @page.send(*args, &block)
    else
      @context.send *args, &block
    end
  end
  
end

class ActionView::Base
  def render_with(renderer_name, &block)
    renderer = "#{renderer_name}_renderer".classify.constantize.new(@template)
    yield renderer
    page = eval("page", block.binding)
    page << renderer.to_s
  end
end