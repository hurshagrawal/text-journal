defmodule QuiltWeb.JournalControllerTest do
  use QuiltWeb.ConnCase

  alias QuiltWeb.Guardian.Plug, as: Guardian

  describe "get :index" do
    @tag :pending
    test "renders the create form if the user has no journal", %{conn: conn} do
    end

    @tag :pending
    test "renders the journal page if the user has a journal", %{conn: conn} do
    end
  end

  describe "post :create" do
    @tag :pending
    test "errors and redirects back if the params are incorrect", %{conn: conn} do
    end

    @tag :pending
    test "creates a journal and redirects to the journal page", %{conn: conn} do
      # assert name, onboarding text, response text are right
      # assert journal membership exists
      # assert new_sms_number was called and added to the journal
    end
  end

  describe "put :update" do
    @tag :pending
    test "updates the user's journal and redirects back", %{conn: conn} do
    end
  end
end
