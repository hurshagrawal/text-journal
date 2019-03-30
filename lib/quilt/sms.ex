defmodule Quilt.Sms do
  @twilio_client Application.get_env(:quilt, :twilio_client)

  @doc """
  Sends a verification code SMS to the given number via Twilio.
  """
  def send_verification_code(phone_number, verification_code) do
    send_sms(
      "Your Quilt verification code is: #{verification_code}",
      phone_number,
      @twilio_client.get_default_sms_number()
    )
  end

  @doc """
  Provisions a new US phone number. WARNING: This method call costs $1.
  """
  def get_new_sms_number() do
    {:ok, phone_number} =
      @twilio_client.get_available_phone_numbers()
      |> List.first()
      |> Map.fetch("phone_number")

    {:ok, phone_number} = @twilio_client.provision_phone_number(phone_number)

    phone_number
  end

  def send_sms(message, to_number, from_number) do
    Task.async(fn ->
      @twilio_client.send_sms(message, to_number, from_number)
    end)
  end

  def send_mms(message, media_urls, to_number, from_number) do
    Task.async(fn ->
      @twilio_client.send_mms(message, media_urls, to_number, from_number)
    end)
  end

  def fan_out_sms(body, media_urls \\ [], to_numbers, from_number) do
    has_body = body |> String.trim() |> String.length() > 0
    has_media = Enum.count(media_urls) > 0

    if has_body || has_media do
      IO.puts(
        "Webhook: Fanning out message from #{from_number} to #{
          Enum.count(to_numbers)
        } numbers."
      )

      IO.puts("Body: #{inspect(body)}")
      IO.puts("Media Urls: #{inspect(media_urls)}")

      Enum.map(to_numbers, fn to_number ->
        send_mms(body, media_urls, to_number, from_number)
      end)
    end
  end
end
