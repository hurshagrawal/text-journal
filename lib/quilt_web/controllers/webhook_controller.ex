defmodule QuiltWeb.WebhookController do
  use QuiltWeb, :controller

  alias Quilt.{Accounts, Content, Sms}

  @doc """
  Incoming webhook from Twilio when someone sends an
  SMS to a connected phone number.
  """
  def run(conn, params) do
    %{
      "Body" => body,
      "From" => from_number,
      "To" => to_number,
      "NumMedia" => media_count_str
    } = params

    case Content.get_journal(phone_number: to_number) do
      nil ->
        Sms.send_sms(
          "Oops, something went wrong. There's no active journal at this number.",
          from_number,
          to_number
        )

      journal ->
        {media_count, ""} = Integer.parse(media_count_str)

        media_urls =
          if media_count > 0 do
            0..(media_count - 1)
            |> Enum.to_list()
            |> Enum.map(fn i ->
              {:ok, url} = Map.fetch(params, "MediaUrl#{i}")
              url
            end)
          else
            []
          end

        user = Accounts.get_or_create_user(phone_number: from_number)
        is_stop_post = body |> String.trim() |> String.downcase() == "stop"

        unless is_stop_post do
          {:ok, _} = Content.create_post(journal, user, body, media_urls)
        end

        case Content.get_membership(journal_id: journal.id, user_id: user.id) do
          # If membership doesn't exist, create it and send welcome SMS.
          nil ->
            Content.subscribe_user(journal, user)
            Quilt.Sms.send_sms(journal.onboarding_text, from_number, to_number)

          membership ->
            case membership.type do
              # If this message is from the owner, fan it out to subscribers
              "owner" ->
                subscriber_numbers =
                  Content.get_subscriber_phone_numbers(journal)

                Sms.fan_out_sms(body, media_urls, subscriber_numbers, to_number)

              "subscriber" ->
                case membership.subscribed do
                  # If this message is from an unsubscribed subscriber,
                  # resubscribe him and send him a welcome-back SMS
                  false ->
                    Content.subscribe_user(journal, user)

                    Quilt.Sms.send_sms(
                      journal.onboarding_text,
                      from_number,
                      to_number
                    )

                  true ->
                    if is_stop_post do
                      # If this subscriber messaged "stop", unsubscribe them
                      Content.unsubscribe_membership(membership)
                    else
                      # If this message is from a subscribed subscriber, send a
                      # text acknowledging receipt of the message
                      Quilt.Sms.send_sms(
                        journal.subscriber_response_text,
                        from_number,
                        to_number
                      )
                    end
                end
            end
        end
    end

    send_resp(conn, 200, "")
  end
end
