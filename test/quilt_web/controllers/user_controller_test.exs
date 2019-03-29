defmodule QuiltWeb.UserControllerTest do
  use QuiltWeb.ConnCase

  alias QuiltWeb.Guardian.Plug, as: Guardian

  describe "get :index" do
    test "renders the sign up page when unauthenticated", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 200) =~ "Sign up"
    end

    test "redirects to journal page when authenticated", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> Guardian.sign_in(user)
        |> get(Routes.user_path(conn, :index))

      assert redirected_to(conn) == Routes.journal_path(conn, :index)
    end
  end

  describe "post :create" do
    test "errors if no params are given" do
    end

    test "errors if an invalid phone number is given" do
    end

    test "creates a user and redirects to verify" do
      # Validate that the user in the db has attrs + verification code
      # Stub Sms.Twilio and ensure mocks are called
      # Ensure session has a :user_to_verify_id
      # Ensure redirect works
    end
  end

  describe "get :verify_index" do
    test "redirects to home if no id is found in session" do
    end

    test "renders the verification page" do
    end
  end

  describe "post :verify_user" do
    test "redirects back with flash message if code is incorrect" do
    end

    test "signs the user in if the code is correct" do
    end
  end

  describe "post :sign_in" do
    test "errors and redirects back if the phone is invalid" do
    end

    test "errors and redirects back if no user was found" do
    end

    test "sends a verification code and redirects to verify" do
    end
  end
end
