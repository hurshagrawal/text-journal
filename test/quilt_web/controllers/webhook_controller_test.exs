defmodule QuiltWeb.WebhookControllerTest do
  use QuiltWeb.ConnCase

  describe "for a new subscriber" do
    @tag :pending
    test "creates a subscription and sends a welcome sms", %{conn: conn} do
      # Creates a user
      # Creates a post
      # Creates a subscribed membership
      # Sends a welcome sms
    end
  end

  describe "for an owner's sms" do
    @tag :pending
    test "fans out the sms to all subscribers", %{conn: conn} do
      # Creates a post
      # Should not send to unsubscribed people
      # Should not send to random other users
      # Should not send to owner
      # Should send both body + media urls
    end
  end

  describe "for an existing, unsubscribed subscriber" do
    @tag :pending
    test "resubscribes the user and sends a welcome sms", %{conn: conn} do
      # Creates a post
      # Updates the membership as subscribed
      # Sends a welcome sms
    end
  end

  describe "for an existing, subscribed subscriber" do
    @tag :pending
    test "sends a response sms", %{conn: conn} do
      # Creates a post
      # Sends a response sms
    end
  end

  describe "for an sms that sends 'stop'" do
    @tag :pending
    test "unsubscribes the user", %{conn: conn} do
      # Does NOT create a post
      # Membership should be unsubscribed
    end
  end
end
