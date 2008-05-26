require File.dirname(__FILE__) + '/test_helper'

class TestRenderer < Renderer
  def display_ivar
    page.replace :foo_container, @foo
  end
    
  def set_notice msg
    page.replace_html :notice, msg
  end
end

class ExampleRenderer < TestRenderer
end


class TestController < ActionController::Base
  def render_inline_update
    @foo = "Goodbye World!"
    render :update do |p|
      p.render_with :test do |renderer|
        renderer.display_ivar
      end
    end
  end
  
  def render_rjs_with_ivars
    @foo = 'Hello World!'
    respond_to :js
  end
  
  def render_rjs_with_single_renderer
    respond_to :js
  end

  def render_rjs_with_multiple_renderers
    respond_to :js
  end
end
TestController.view_paths = [ File.dirname(__FILE__) + "/fixtures/" ]

class RenderWithRendererTest < Test::Unit::TestCase
  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @controller = TestController.new

    @request.host = "www.nextangle.com"
  end
  
  def test_it_renders_inline_update_with_a_single_renderer
    xhr :get, :render_inline_update
    assert_match 'Element.replace("foo_container", "Goodbye World!")'.to_regexp, @response.body, "didn't have the ivar's value in the renderered RJS"
  end
  
  def test_it_renders_rjs_with_a_single_renderer
    xhr :get, :render_rjs_with_single_renderer
    assert_match 'Element.update("notice", "This is the notice")'.to_regexp, @response.body, "didn't have the expected RJS"
  end
  
  def test_it_renders_rjs_with_multiple_renderers
    xhr :get, :render_rjs_with_multiple_renderers
    assert_match 'Element.update("notice", "This is the test notice")'.to_regexp, @response.body, "didn't have the first renderer's RJS"
    assert_match 'Element.update("notice", "This is the example notice")'.to_regexp, @response.body, "didn't have the second renderer's RJS"
  end
  
  def test_it_gives_access_to_controller_instance_variables
    xhr :get, :render_rjs_with_ivars
    assert_match 'Element.replace("foo_container", "Hello World!")'.to_regexp, @response.body, "didn't have the ivar's value in the renderered RJS"
  end
end
