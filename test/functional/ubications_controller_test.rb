require 'test_helper'

class UbicationsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:ubications)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_ubication
    assert_difference('Ubication.count') do
      post :create, :ubication => { }
    end

    assert_redirected_to ubication_path(assigns(:ubication))
  end

  def test_should_show_ubication
    get :show, :id => ubications(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => ubications(:one).id
    assert_response :success
  end

  def test_should_update_ubication
    put :update, :id => ubications(:one).id, :ubication => { }
    assert_redirected_to ubication_path(assigns(:ubication))
  end

  def test_should_destroy_ubication
    assert_difference('Ubication.count', -1) do
      delete :destroy, :id => ubications(:one).id
    end

    assert_redirected_to ubications_path
  end
end
