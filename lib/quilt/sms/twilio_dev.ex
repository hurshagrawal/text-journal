defmodule Quilt.Sms.TwilioDev do
  alias Quilt.Sms.Twilio

  def get_available_phone_numbers do
    [%{"phone_number" => get_default_sms_number()}]
  end

  def provision_phone_number(phone_number) do
    {:ok, phone_number}
  end

  def get_default_sms_number() do
    System.get_env("DEFAULT_PHONE_NUMBER") || "+12407433481"
  end

  defdelegate send_sms(message, to_number, from_number), to: Twilio
  defdelegate send_mms(message, media_urls, to_number, from_number), to: Twilio
end
