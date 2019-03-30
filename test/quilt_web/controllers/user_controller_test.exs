defmodule QuiltWeb.UserControllerTest do
  use QuiltWeb.ConnCase

  alias Quilt.Repo
  alias Quilt.Accounts.User
  alias Quilt.Sms.TwilioInMemory
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
    test "errors if no params are given", %{conn: conn} do
      conn =
        post(conn, Routes.user_path(conn, :create), %{
          name: "foo"
        })

      assert redirected_to(conn) == Routes.user_path(conn, :index)
      assert get_flash(conn, :error) =~ "Oops! Phone_number can't be blank."
      assert get_flash(conn, :user_to_verify_id) == nil
    end

    test "errors if an invalid phone number is given", %{conn: conn} do
      conn =
        post(conn, Routes.user_path(conn, :create), %{
          name: "foo",
          phone_number: "+12345"
        })

      assert redirected_to(conn) == Routes.user_path(conn, :index)
      assert get_flash(conn, :error) =~ "Oops! Phone_number is invalid."
      assert get_flash(conn, :user_to_verify_id) == nil
    end

    test "creates a user and redirects to verify", %{conn: conn} do
      name = "Foo bar"
      phone_number = "+12125793412"

      conn =
        post(conn, Routes.user_path(conn, :create), %{
          name: name,
          phone_number: phone_number
        })

      user = Repo.get_by(User, phone_number: phone_number)
      assert user.name == name
      assert user.verification_code != nil

      texts_sent = TwilioInMemory.requests()
      assert length(texts_sent) == 1

      text = List.first(texts_sent)
      IO.inspect(text)
      assert text.message =~ "Your Quilt verification code"
      assert text.to_number == phone_number

      assert get_flash(conn, :user_to_verify_id) == nil
      assert redirected_to(conn) == Routes.user_path(conn, :verify_index)
    end
  end

  describe "get :verify_index" do
    test "redirects to home if no id is found in session", %{conn: conn} do
      raise "Not yet implemented"
    end

    test "renders the verification page", %{conn: conn} do
      raise "Not yet implemented"
    end
  end

  describe "post :verify_user" do
    test "redirects back with flash message if code is incorrect", %{conn: conn} do
      raise "Not yet implemented"
    end

    test "signs the user in if the code is correct", %{conn: conn} do
      raise "Not yet implemented"
    end
  end

  describe "post :sign_in" do
    test "errors and redirects back if the phone is invalid", %{conn: conn} do
      raise "Not yet implemented"
    end

    test "errors and redirects back if no user was found", %{conn: conn} do
      raise "Not yet implemented"
    end

    test "sends a verification code and redirects to verify", %{conn: conn} do
      raise "Not yet implemented"
    end
  end
end
