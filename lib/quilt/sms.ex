defmodule Quilt.Sms do
  alias Quilt.Sms.Twilio

  defdelegate send_sms(message, to_number, from_number), to: Twilio
  defdelegate send_mms(media_urls, to_number, from_number), to: Twilio

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
    {:ok, phone_number} =
      Twilio.get_available_phone_numbers()
      |> List.first()
      |> Map.fetch("phone_number")

    {:ok, phone_number} = Twilio.provision_phone_number(phone_number)

    phone_number
  end

  def get_default_sms_number() do
    System.get_env("DEFAULT_PHONE_NUMBER") || "+12407433481"
  end

  def fan_out_sms(body, media_urls \\ [], to_numbers, from_number) do
    Enum.map(to_numbers, fn to_number ->
      if body |> String.trim() |> String.length() > 0 do
        send_sms(body, to_number, from_number)
      end

      if Enum.count(media_urls) > 0 do
        send_mms(media_urls, to_number, from_number)
      end
    end)
  end
end
