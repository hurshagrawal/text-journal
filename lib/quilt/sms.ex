defmodule Quilt.Sms do
  alias Quilt.Sms.Twilio

  @doc """
  Sends a verification code SMS to the given number via Twilio.
  """
  def send_verification_code(phone_number, verification_code) do
    send_sms(
      "Your Quilt verification code is: #{verification_code}",
      phone_number,
      get_default_sms_number()
    )
  end

  @doc """
  Provisions a new US phone number. WARNING: This method call costs $1.
  """
  def get_new_sms_number() do
    # TODO: Convert this to a feature flag or ENV var. This is hacky AF.
    if Mix.env() == :prod do
      {:ok, phone_number} =
        Twilio.get_available_phone_numbers()
        |> List.first()
        |> Map.fetch("phone_number")

      {:ok, phone_number} = Twilio.provision_phone_number(phone_number)

      phone_number
    else
      get_default_sms_number()
    end
  end

  def get_default_sms_number() do
    System.get_env("DEFAULT_PHONE_NUMBER") || "+12407433481"
  end

  def send_sms(message, to_number, from_number) do
    Task.async(fn ->
      Twilio.send_sms(message, to_number, from_number)
    end)
  end

  def send_mms(message, media_urls, to_number, from_number) do
    Task.async(fn ->
      Twilio.send_mms(message, media_urls, to_number, from_number)
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
