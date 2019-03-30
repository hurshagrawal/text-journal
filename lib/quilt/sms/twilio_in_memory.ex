defmodule Quilt.Sms.TwilioInMemory do
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def clear do
    Agent.update(__MODULE__, fn state -> [] end)
  end

  def requests do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def get_available_phone_numbers do
    [%{phone_number: get_default_sms_number()}]
  end

  def provision_phone_number(phone_number) do
    {:ok, phone_number}
  end

  def get_default_sms_number() do
    "+12125793499"
  end

  def send_sms(message, to_number, from_number) do
    Agent.update(__MODULE__, fn state ->
      [
        %{
          message: message,
          media_urls: [],
          from_number: from_number,
          to_number: to_number
        }
        | state
      ]
    end)

    :ok
  end

  def send_mms(message, media_urls, to_number, from_number) do
    Agent.update(__MODULE__, fn state ->
      [
        %{
          message: message,
          media_urls: media_urls,
          from_number: from_number,
          to_number: from_number
        }
        | state
      ]
    end)

    :ok
  end
end
