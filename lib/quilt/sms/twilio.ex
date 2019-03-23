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

  def send_sms(message, to_number, from_number) do
    send_message(
      URI.encode_query(%{
        From: from_number,
        To: to_number,
        Body: message
      })
    )
  end

  def send_mms(media_urls, to_number, from_number) do
    number_params =
      URI.encode_query(%{
        From: from_number,
        To: to_number
      })

    url_params =
      Enum.map(media_urls, fn url ->
        "&MediaUrl[]=" <> url
      end)

    send_message(number_params <> url_params)
  end

  defp send_message(body) do
    Client.start()

    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]
    response = Client.post!("/Messages.json", body, headers)

    if response.status_code == 201 do
      {:ok, response.body}
    else
      :error
    end
  end
end
