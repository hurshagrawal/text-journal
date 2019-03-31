defmodule QuiltWeb.JournalControllerTest do
  use QuiltWeb.ConnCase

  alias Quilt.Repo
  alias Quilt.Content.{Journal, JournalMembership, Post}
  alias QuiltWeb.Guardian.Plug, as: Guardian

  describe "get :index" do
    test "renders the create form if the user has no journal", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> Guardian.sign_in(user)
        |> get(Routes.journal_path(conn, :index))

      assert html_response(conn, 200) =~ "Create a Journal"
    end

    test "renders the journal page if the user has a journal", %{conn: conn} do
      user = insert(:user)
      membership = insert(:journal_membership, user: user)
      journal = membership.journal

      conn =
        conn
        |> Guardian.sign_in(user)
        |> get(Routes.journal_path(conn, :index))

      assert html_response(conn, 200) =~ "Your Journal Information"
      assert html_response(conn, 200) =~ journal.name
    end
  end

  describe "post :create" do
    test "errors and redirects back if the params are incorrect", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> Guardian.sign_in(user)
        |> post(Routes.journal_path(conn, :create), name: nil)

      assert redirected_to(conn) == Routes.journal_path(conn, :index)
      assert get_flash(conn, :error) =~ "Oops! Name can't be blank."
    end

    test "creates a journal and redirects to the journal page", %{conn: conn} do
      name = "Journal name 9876"
      user = insert(:user)

      conn =
        conn
        |> Guardian.sign_in(user)
        |> post(Routes.journal_path(conn, :create), name: name)

      assert redirected_to(conn) == Routes.journal_path(conn, :index)

      membership = Repo.get_by(JournalMembership, user_id: user.id)

      assert membership != nil
      assert membership.type == "owner"

      journal = membership |> Ecto.assoc(:journal) |> Repo.one()

      assert journal != nil
      assert journal.name == name

      assert journal.onboarding_text =~
               "Hey! Thanks for subscribing to my journal."

      assert journal.subscriber_response_text =~ "Thanks for the message!"

      assert journal.phone_number ==
               Quilt.Sms.TwilioInMemory.get_default_sms_number()
    end
  end

  describe "put :update" do
    test "updates the user's journal and redirects back", %{conn: conn} do
      new_name = "Here is new journal name"
      new_onboarding_text = "Here is new onboarding text"
      new_subscriber_response_text = "Here is new subscriber response text"

      user = insert(:user)
      journal = insert(:journal)

      conn =
        conn
        |> Guardian.sign_in(user)
        |> put(Routes.journal_path(conn, :update, journal.id),
          name: new_name,
          onboarding_text: new_onboarding_text,
          subscriber_response_text: new_subscriber_response_text
        )

      assert redirected_to(conn) == Routes.journal_path(conn, :index)
      assert get_flash(conn, :info) =~ "Saved"

      journal = Repo.get_by(Journal, id: journal.id)

      assert journal.name == new_name
      assert journal.onboarding_text == new_onboarding_text
      assert journal.subscriber_response_text == new_subscriber_response_text
    end
  end
end
