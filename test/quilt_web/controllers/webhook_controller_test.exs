defmodule QuiltWeb.WebhookControllerTest do
  use QuiltWeb.ConnCase

  alias Quilt.Repo
  alias Quilt.Content.{Post, JournalMembership}
  alias Quilt.Accounts.User
  alias Quilt.Sms.TwilioInMemory

  setup do
    Quilt.Sms.TwilioInMemory.clear()
  end

  describe "for a new subscriber" do
    test "creates a subscription and sends a welcome sms", %{conn: conn} do
      sms_body = "Yo sign me up"
      from_number = "+12125791255"
      to_number = "+12125791333"

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
      texts_sent = TwilioInMemory.requests()
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
      to_number = "+12125791333"

      user = insert(:user, phone_number: from_number)
      journal = insert(:journal, phone_number: to_number)

      membership =
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
      texts_sent = TwilioInMemory.requests()
      assert length(texts_sent) == 2

      sms = Enum.at(texts_sent, 1)
      assert sms.message == sms_body
      assert sms.media_urls == [media_url]
      assert sms.from_number == to_number
      assert sms.to_number == subscriber_membership_1.user.phone_number

      sms = Enum.at(texts_sent, 0)
      assert sms.message == sms_body
      assert sms.media_urls == [media_url]
      assert sms.from_number == to_number
      assert sms.to_number == subscriber_membership_2.user.phone_number
    end
  end

  describe "for an existing, unsubscribed subscriber" do
    test "resubscribes the user and sends a welcome sms", %{conn: conn} do
      sms_body = "Yo sign me up"
      from_number = "+12125791255"
      to_number = "+12125791333"

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
      texts_sent = TwilioInMemory.requests()
      assert length(texts_sent) == 1

      sms = List.first(texts_sent)
      assert sms.message == journal.onboarding_text
      assert sms.to_number == from_number
    end
  end

  describe "for an existing, subscribed subscriber" do
    test "sends a response sms", %{conn: conn} do
      sms_body = "Yo here's a response"
      from_number = "+12125791255"
      to_number = "+12125791333"

      subscriber_response_text = "Sorry i can't see these messages"

      user = insert(:user, phone_number: from_number)

      journal =
        insert(:journal,
          phone_number: to_number,
          subscriber_response_text: subscriber_response_text
        )

      membership =
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
      texts_sent = TwilioInMemory.requests()
      assert length(texts_sent) == 1

      sms = List.first(texts_sent)
      assert sms.message == journal.subscriber_response_text
      assert sms.to_number == from_number
    end
  end

  describe "for an sms that sends 'stop'" do
    test "unsubscribes the user", %{conn: conn} do
      sms_body = "stop"
      from_number = "+12125791255"
      to_number = "+12125791333"

      user = insert(:user, phone_number: from_number)
      journal = insert(:journal, phone_number: to_number)

      membership =
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

      # post is NOT created
      post = Repo.get_by(Post, user_id: user.id)
      assert post == nil

      # membership is updated properly
      membership = Repo.get_by(JournalMembership, id: membership.id)
      assert membership.subscribed == false
    end
  end
end
