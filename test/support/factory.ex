defmodule Quilt.Factory do
  use ExMachina.Ecto, repo: Quilt.Repo

  alias Quilt.Accounts.User
  alias Quilt.Content.{Journal, JournalMembership, Post}

  def user_factory do
    %User{
      name: sequence(:name, &"Jane Smith #{&1}"),
      phone_number:
        sequence(:phone_number, fn _i ->
          get_random_phone_number()
        end)
    }
  end

  def journal_factory do
    %Journal{
      phone_number:
        sequence(:phone_number, fn _i ->
          get_random_phone_number()
        end),
      name: sequence(:name, &"Journal #{&1}"),
      type: "broadcast",
      onboarding_text: sequence(:onboarding_text, &"Onboarding text #{&1}."),
      subscriber_response_text:
        sequence(:subscriber_response_text, &"Onboarding text #{&1}.")
    }
  end

  def journal_membership_factory do
    %JournalMembership{
      type: "owner",
      user: build(:user),
      journal: build(:journal),
      subscribed: true
    }
  end

  def subscriber_journal_membership_factory do
    struct!(
      journal_membership_factory(),
      %{type: "subscriber"}
    )
  end

  def post_factory do
    %Post{
      body: sequence(:body, &"Here is a post message #{&1}."),
      media_urls: [get_sample_media_url()],
      journal: build(:journal),
      user: build(:user)
    }
  end

  defp get_random_phone_number do
    "+1212#{Enum.random(2_000_000..9_999_999)}"
  end

  defp get_sample_media_url do
    "https://images.unsplash.com/photo-1518791841217-8f162f1e1131?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=225&q=80"
  end
end
