defmodule QuiltWeb.WebhookControllerTest do
  use QuiltWeb.ConnCase

  alias Quilt.Repo
  alias Quilt.Content.{Post, JournalMembership}
  alias Quilt.Accounts.User
  alias Quilt.Sms.Twilio.InMemory, as: Twilio

  setup do
    Twilio.reset()
  end

  describe "for a new subscriber" do
    test "creates a subscription and sends a welcome sms", %{conn: conn} do
      sms_body = "Yo sign me up"
      from_number = "+12125791255"
      to_number = "+15409864232"

      onboarding_text = "Sample onboarding text here lalala"

      journal =
        insert(:journal,
          phone_number: to_number,
          onboarding_text: onboarding_text
        )

      conn =
        post(conn, Routes.webhook_path(conn, :run),
          Body: sms_body,
          From: from_number,
          To: to_number,
          NumMedia: "0"
        )

      assert response(conn, 200) == ""

      # user is created properly
      user = Repo.get_by(User, phone_number: from_number)
      assert user != nil

      # post is created properly
      post = Repo.get_by(Post, user_id: user.id)
      assert post.body == sms_body
      assert post.journal_id == journal.id

      # membership is created properly
      membership = Repo.get_by(JournalMembership, user_id: user.id)
      assert membership.journal_id == journal.id
      assert membership.type == "subscriber"

      # Sends a welcome sms
      texts_sent = Twilio.requests()
      assert length(texts_sent) == 1

      sms = List.first(texts_sent)
      assert sms.message == journal.onboarding_text
      assert sms.to_number == from_number
    end
  end

  describe "for an owner's sms" do
    test "fans out the sms to all subscribers", %{conn: conn} do
      sms_body = "Check out this post guys"
      media_url = "http://catpicture.com/image.png"
      from_number = "+12125791255"
      to_number = "+15409864232"

      user = insert(:user, phone_number: from_number)
      journal = insert(:journal, phone_number: to_number)

      insert(:journal_membership, type: "owner", user: user, journal: journal)

      subscriber_membership_1 =
        insert(:journal_membership, type: "subscriber", journal: journal)

      subscriber_membership_2 =
        insert(:journal_membership, type: "subscriber", journal: journal)

      # unsubscribed membership (should not recieve a text)
      insert(:journal_membership,
        type: "subscriber",
        journal: journal,
        subscribed: false
      )

      # another random user (should not receive a text)
      insert(:user)

      conn =
        post(conn, Routes.webhook_path(conn, :run),
          Body: sms_body,
          From: from_number,
          To: to_number,
          NumMedia: "1",
          MediaUrl0: media_url
        )

      assert response(conn, 200) == ""

      # post is created properly
      post = Repo.get_by(Post, user_id: user.id)
      assert post.body == sms_body
      assert post.media_urls == [media_url]
      assert post.journal_id == journal.id

      # Fans out the sms
      texts_sent = Twilio.requests()
      assert length(texts_sent) == 4

      sms = Enum.at(texts_sent, 3)
      assert sms.message == sms_body
      assert sms.media_urls == []
      assert sms.from_number == to_number
      assert sms.to_number == subscriber_membership_1.user.phone_number

      sms = Enum.at(texts_sent, 2)
      assert sms.message == media_url
      assert sms.media_urls == []
      assert sms.from_number == to_number
      assert sms.to_number == subscriber_membership_1.user.phone_number

      sms = Enum.at(texts_sent, 1)
      assert sms.message == sms_body
      assert sms.media_urls == []
      assert sms.from_number == to_number
      assert sms.to_number == subscriber_membership_2.user.phone_number

      sms = Enum.at(texts_sent, 0)
      assert sms.message == media_url
      assert sms.media_urls == []
      assert sms.from_number == to_number
      assert sms.to_number == subscriber_membership_2.user.phone_number
    end

    test "unsubscribes users where Twilio has blacklisted them", %{conn: conn} do
      from_number = "+12125791255"
      to_number = "+15409864232"

      user = insert(:user, phone_number: from_number)
      journal = insert(:journal, phone_number: to_number)
      insert(:journal_membership, type: "owner", user: user, journal: journal)

      membership =
        insert(:journal_membership,
          type: "subscriber",
          subscribed: true,
          journal: journal
        )

      Twilio.force_error_responses()

      conn =
        post(conn, Routes.webhook_path(conn, :run),
          Body: "Foo bar baz",
          From: from_number,
          To: to_number,
          NumMedia: "0"
        )

      assert response(conn, 200) == ""

      # Fans out the sms
      texts_sent = Twilio.requests()
      assert length(texts_sent) == 1

      sms = Enum.at(texts_sent, 0)
      assert sms.from_number == to_number
      assert sms.to_number == membership.user.phone_number

      membership = Repo.get(JournalMembership, membership.id)
      assert membership.subscribed == false
    end

    test "sends media urls properly", %{conn: conn} do
      from_number = "+12125791255"
      to_number = "+15409864232"
      media_url = "http://www.example.com/cat.jpg"

      user = insert(:user, phone_number: from_number)
      journal = insert(:journal, phone_number: to_number)
      insert(:journal_membership, type: "owner", user: user, journal: journal)

      membership =
        insert(:journal_membership,
          type: "subscriber",
          subscribed: true,
          journal: journal
        )

      conn =
        post(conn, Routes.webhook_path(conn, :run),
          Body: "",
          From: from_number,
          To: to_number,
          NumMedia: "1",
          MediaUrl0: media_url
        )

      assert response(conn, 200) == ""

      # Fans out the sms
      texts_sent = Twilio.requests()
      assert length(texts_sent) == 1

      sms = Enum.at(texts_sent, 0)
      assert sms.from_number == to_number
      assert sms.to_number == membership.user.phone_number
      assert sms.message == media_url
      assert sms.media_urls == []
    end

    test "sends a link to images for international numbers", %{conn: conn} do
      from_number = "+12125791255"
      to_number = "+15409864232"
      body = "Hi there this is body"
      media_url = "http://www.example.com/cat.jpg"

      user = insert(:user, phone_number: from_number)
      journal = insert(:journal, phone_number: to_number)
      insert(:journal_membership, type: "owner", user: user, journal: journal)

      subscriber_user = insert(:user, phone_number: "+44 (0)20 8977 3252")

      membership =
        insert(:journal_membership,
          type: "subscriber",
          subscribed: true,
          journal: journal,
          user: subscriber_user
        )

      conn =
        post(conn, Routes.webhook_path(conn, :run),
          Body: body,
          From: from_number,
          To: to_number,
          NumMedia: "1",
          MediaUrl0: media_url
        )

      assert response(conn, 200) == ""

      # Fans out the sms
      texts_sent = Twilio.requests()
      assert length(texts_sent) == 2

      sms = Enum.at(texts_sent, 0)
      assert sms.from_number == to_number
      assert sms.to_number == membership.user.phone_number
      assert sms.message == media_url
      assert sms.media_urls == []

      sms = Enum.at(texts_sent, 1)
      assert sms.from_number == to_number
      assert sms.to_number == membership.user.phone_number
      assert sms.message == body
      assert sms.media_urls == []
    end
  end

  describe "for an existing, unsubscribed subscriber" do
    test "resubscribes the user and sends a welcome sms", %{conn: conn} do
      sms_body = "Yo sign me up"
      from_number = "+12125791255"
      to_number = "+15409864232"

      onboarding_text = "Sample onboarding text here lalala"

      user = insert(:user, phone_number: from_number)

      journal =
        insert(:journal,
          phone_number: to_number,
          onboarding_text: onboarding_text
        )

      membership =
        insert(:journal_membership,
          type: "subscriber",
          subscribed: false,
          user: user,
          journal: journal
        )

      conn =
        post(conn, Routes.webhook_path(conn, :run),
          Body: sms_body,
          From: from_number,
          To: to_number,
          NumMedia: "0"
        )

      assert response(conn, 200) == ""

      # post is created properly
      post = Repo.get_by(Post, user_id: user.id)
      assert post.body == sms_body
      assert post.journal_id == journal.id

      # membership is updated properly
      membership = Repo.get_by(JournalMembership, id: membership.id)
      assert membership.subscribed == true

      # Sends a welcome sms
      texts_sent = Twilio.requests()
      assert length(texts_sent) == 1

      sms = List.first(texts_sent)
      assert sms.message == journal.onboarding_text
      assert sms.to_number == from_number
    end
  end

  describe "for an existing, subscribed subscriber" do
    test "sends a response sms once", %{conn: conn} do
      sms_body = "Yo here's a response"
      from_number = "+12125791255"
      to_number = "+15409864232"

      subscriber_response_text = "Sorry i can't see these messages"

      user = insert(:user, phone_number: from_number)

      journal =
        insert(:journal,
          phone_number: to_number,
          subscriber_response_text: subscriber_response_text
        )

      insert(:journal_membership,
        type: "subscriber",
        subscribed: true,
        user: user,
        journal: journal
      )

      conn =
        post(conn, Routes.webhook_path(conn, :run),
          Body: sms_body,
          From: from_number,
          To: to_number,
          NumMedia: "0"
        )

      assert response(conn, 200) == ""

      # post is created properly
      post = Repo.get_by(Post, user_id: user.id)
      assert post.body == sms_body
      assert post.journal_id == journal.id

      # Sends a response sms
      texts_sent = Twilio.requests()
      assert length(texts_sent) == 1

      sms = List.first(texts_sent)
      assert sms.message == journal.subscriber_response_text
      assert sms.to_number == from_number

      # The response text should only be sent once
      conn =
        conn
        |> recycle()
        |> post(Routes.webhook_path(conn, :run),
          Body: "Here's another response",
          From: from_number,
          To: to_number,
          NumMedia: "0"
        )

      assert length(Twilio.requests()) == 1
    end
  end

  describe "for an sms that sends 'stop'" do
    def run_stop_request(conn, subscribed) do
      sms_body = "stop"
      from_number = "+12125791255"
      to_number = "+15409864232"

      user = insert(:user, phone_number: from_number)
      journal = insert(:journal, phone_number: to_number)

      membership =
        insert(:journal_membership,
          type: "subscriber",
          subscribed: subscribed,
          user: user,
          journal: journal
        )

      conn =
        post(conn, Routes.webhook_path(conn, :run),
          Body: sms_body,
          From: from_number,
          To: to_number,
          NumMedia: "0"
        )

      %{conn: conn, user: user, membership: membership}
    end

    test "unsubscribes the user", %{conn: conn} do
      %{
        conn: conn,
        user: user,
        membership: membership
      } = run_stop_request(conn, true)

      assert response(conn, 200) == ""

      # post is NOT created
      post = Repo.get_by(Post, user_id: user.id)
      assert post == nil

      # membership is updated properly
      membership = Repo.get_by(JournalMembership, id: membership.id)
      assert membership.subscribed == false
    end

    test "doesn't resubscribe the user if they're unsubscribed", %{conn: conn} do
      %{
        conn: conn,
        user: user,
        membership: membership
      } = run_stop_request(conn, false)

      assert response(conn, 200) == ""

      # post is NOT created
      post = Repo.get_by(Post, user_id: user.id)
      assert post == nil

      # membership is still unsubscribed false
      membership = Repo.get_by(JournalMembership, id: membership.id)
      assert membership.subscribed == false
    end
  end
end
