defmodule QuiltWeb.JournalControllerTest do
  use QuiltWeb.ConnCase

  alias QuiltWeb.Guardian.Plug, as: Guardian

  describe "get :index" do
    test "renders the create journal form if the user has no journal" do
    end

    test "renders the journal page if the user has a journal" do
    end
  end

  describe "post :create" do
    test "errors and redirects back if the params are incorrect" do
    end

    test "creates a journal and redirects to the journal page" do
      # assert name, onboarding text, response text are right
      # assert journal membership exists
      # assert new_sms_number was called and added to the journal
    end
  end

  describe "put :update" do
    test "updates the user's journal and redirects back" do
    end
  end
end
