defmodule QuiltWeb.JournalControllerTest do
  use QuiltWeb.ConnCase

  alias QuiltWeb.Guardian.Plug, as: Guardian

  describe "get :index" do
    test "renders the create form if the user has no journal", %{conn: conn} do
      raise "Not yet implemented"
    end

    test "renders the journal page if the user has a journal", %{conn: conn} do
      raise "Not yet implemented"
    end
  end

  describe "post :create" do
    test "errors and redirects back if the params are incorrect", %{conn: conn} do
      raise "Not yet implemented"
    end

    test "creates a journal and redirects to the journal page", %{conn: conn} do
      # assert name, onboarding text, response text are right
      # assert journal membership exists
      # assert new_sms_number was called and added to the journal
      raise "Not yet implemented"
    end
  end

  describe "put :update" do
    test "updates the user's journal and redirects back", %{conn: conn} do
      raise "Not yet implemented"
    end
  end
end
