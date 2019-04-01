defmodule QuiltWeb.WebhookController do
  use QuiltWeb, :controller

  alias Quilt.{Accounts, Content, Sms}

  @twilio_blacklist_error_code 21_610

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

    IO.puts("Incoming webhook with params: #{inspect(params)}")

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

        {:ok, user} = Accounts.get_or_create_user(phone_number: from_number)
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
                phone_numbers =
                  journal
                  |> Content.get_subscriber_phone_numbers()

                phone_numbers
                |> Sms.fan_out_sms(body, media_urls, to_number)
                |> Enum.with_index()
                |> Enum.each(fn {response, i} ->
                  case response do
                    # The phone number has been blacklisted by Twilio. We should
                    # unsubscribe the membership so it matches up with Twilio's status
                    {:error, %{"code" => @twilio_blacklist_error_code}} ->
                      phone_numbers
                      |> Enum.at(i)
                      |> Content.unsubscribe_phone_number(journal)

                    _ ->
                      nil
                  end
                end)

              # If the message is from a subscriber, figure out how to respond
              "subscriber" ->
                cond do
                  !membership.subscribed && is_stop_post ->
                    # Already unsubscribed with another stop post. Do nothing.
                    nil

                  !membership.subscribed ->
                    # If this message is from an unsubscribed subscriber,
                    # resubscribe him and send him a welcome-back SMS
                    Content.subscribe_user(journal, user)

                    Quilt.Sms.send_sms(
                      journal.onboarding_text,
                      from_number,
                      to_number
                    )

                  is_stop_post ->
                    # If this subscriber messaged "stop", unsubscribe them
                    Content.unsubscribe_membership(membership)

                  true ->
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

    send_resp(conn, 200, "")
  end
end
