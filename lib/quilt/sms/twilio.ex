defmodule Quilt.Sms.Twilio do
  alias Quilt.Sms.Client

  def get_available_phone_numbers do
    Client.start()

    response =
      Client.get!("/AvailablePhoneNumbers/US/Local.json", [],
        SmsEnabled: true,
        MmsEnabled: true
      )

    response.body["available_phone_numbers"]
  end

  def provision_phone_number(phone_number) do
    Client.start()

    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

    body =
      URI.encode_query(%{
        PhoneNumber: phone_number,
        SmsApplicationSid: Application.get_env(:quilt, :twilio_twiml_sid)
      })

    response = Client.post!("/IncomingPhoneNumbers.json", body, headers)

    if response.status_code == 201 do
      {:ok, response.body["phone_number"]}
    else
      :error
    end
  end

  def get_default_sms_number() do
    System.get_env("DEFAULT_PHONE_NUMBER") || "+12407433481"
  end

  def send_sms(message, to_number, from_number) do
    request_body =
      URI.encode_query(%{
        From: from_number,
        To: to_number,
        Body: message
      })

    IO.puts("Twilio: Sending SMS to #{to_number}")

    case send_message(request_body) do
      {:ok, _} ->
        IO.puts("Twilio: SMS sent successfully to #{to_number}")

      {:error, response_body} ->
        IO.puts(
          "Twilio: SMS error to #{to_number} with body- #{
            inspect(response_body)
          }"
        )
    end
  end

  def send_mms(message, media_urls, to_number, from_number) do
    number_params =
      URI.encode_query(%{
        From: from_number,
        To: to_number,
        Body: message
      })

    url_params =
      media_urls
      |> Enum.map(&("&MediaUrl=" <> URI.encode(&1)))
      |> Enum.join("")

    IO.puts("Twilio: Sending MMS to #{to_number}")

    case send_message(number_params <> url_params) do
      {:ok, body} ->
        IO.puts(
          "Twilio: MMS sent successfully to #{to_number} with body- #{
            inspect(body)
          }"
        )

      {:error, body} ->
        IO.puts("Twilio: MMS error to #{to_number} with body- #{inspect(body)}")
    end
  end

  defp send_message(body) do
    Client.start()

    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]
    response = Client.post!("/Messages.json", body, headers)

    if response.status_code == 201 do
      {:ok, response.body}
    else
      {:error, response.body}
    end
  end
end
