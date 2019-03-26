defmodule QuiltWeb.JournalController do
  use QuiltWeb, :controller
  use QuiltWeb.GuardedController

  alias Quilt.{Content, Sms}

  plug :ensure_authenticated

  def index(conn, _params, current_user) do
    if journal = Content.get_user_journal(current_user) do
      subscriber_count = Content.get_journal_subscribers_count(journal)
      posts_count = Content.get_journal_owner_posts_count(journal)
      replies_count = Content.get_journal_replies_count(journal)

      render(conn, "index.html",
        title: "Journal Settings",
        show_sign_out: true,
        journal: journal,
        subscriber_count: subscriber_count,
        posts_count: posts_count,
        replies_count: replies_count
      )
    else
      render(conn, "index.html", journal: nil)
    end
  end

  def create(conn, %{"name" => name}, current_user) do
    journal_attrs = %{
      name: name,
      onboarding_text: Content.default_onboarding_text(),
      subscriber_response_text: Content.default_subscriber_response_text()
    }

    case Content.create_user_journal(current_user, journal_attrs) do
      {:ok, %{journal: journal}} ->
        number = Sms.get_new_sms_number()
        Content.update_journal(journal, %{phone_number: number})

        conn
        |> redirect(to: Routes.journal_path(conn, :index))

      {:error, _failed_operation, %Ecto.Changeset{} = changeset, _changes} ->
        error_messages = Enum.join(changeset_errors(changeset), ", ")

        conn
        |> put_flash(:error, "Oops! #{String.capitalize(error_messages)}.")
        |> redirect(to: Routes.journal_path(conn, :index))
    end
  end

  def update(conn, params, current_user) do
    attrs = %{
      name: params["name"],
      onboarding_text: params["onboarding_text"],
      subscriber_response_text: params["subscriber_response_text"]
    }

    current_user
    |> Content.get_user_journal()
    |> Content.update_journal(attrs)

    conn
    |> put_flash(:info, "Saved")
    |> redirect(to: Routes.journal_path(conn, :index))
  end
end
