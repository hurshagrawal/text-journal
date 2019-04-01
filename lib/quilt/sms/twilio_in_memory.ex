defmodule Quilt.Sms.TwilioInMemory do
  @default_state %{
    force_error_responses: false,
    requests: []
  }

  @sample_success_response %{
    "account_sid" => "AC8d456cee62407d7fea7581280509ccca",
    "api_version" => "2010-04-01",
    "body" => "Some test body here",
    "date_created" => "Thu, 28 Mar 2019 20:39:53 +0000",
    "date_sent" => nil,
    "date_updated" => "Thu, 28 Mar 2019 20:39:53 +0000",
    "direction" => "outbound-api",
    "error_code" => nil,
    "error_message" => nil,
    "from" => "+17029454343",
    "messaging_service_sid" => nil,
    "num_media" => "1",
    "num_segments" => "1",
    "price" => nil,
    "price_unit" => "USD",
    "sid" => "MMf9dc9541bcaa48ebb272d4a66f721923",
    "status" => "queued",
    "subresource_uris" => %{
      "media" =>
        "/2010-04-01/Accounts/AC8d456cee62407d7fea7581280509b6ba/Messages/MMf9dc9541bcaa48ebb272d4a66f721435/Media.json"
    },
    "to" => "+12156200000",
    "uri" =>
      "/2010-04-01/Accounts/AC8d456cee62407d7fea7581280509b6ba/Messages/MMf9dc9541bcaa48ebb272d4a66f721435.json"
  }

  @sample_error_response %{
    "code" => 21_610,
    "message" => "The message From/To pair violates a blacklist rule.",
    "more_info" => "https://www.twilio.com/docs/errors/21610",
    "status" => 400
  }

  ### Existing Twilio functions

  def get_available_phone_numbers do
    [%{"phone_number" => get_default_sms_number()}]
  end

  def provision_phone_number(phone_number) do
    {:ok, phone_number}
  end

  def get_default_sms_number() do
    "+12125793499"
  end

  def send_sms(message, to_number, from_number) do
    send_mms(message, [], to_number, from_number)
  end

  def send_mms(message, media_urls, to_number, from_number) do
    new_request = %{
      message: message,
      media_urls: media_urls,
      from_number: from_number,
      to_number: to_number
    }

    # Update the state in the running agent
    Agent.update(__MODULE__, fn state ->
      %{state | requests: [new_request | state.requests]}
    end)

    if send_error_response?() do
      {:error, @sample_error_response}
    else
      {:ok, @sample_success_response}
    end
  end

  ### Test-specific functions

  def start_link do
    Agent.start_link(fn -> @default_state end, name: __MODULE__)
  end

  def reset do
    Agent.update(__MODULE__, fn _state -> @default_state end)
  end

  def requests do
    Agent.get(__MODULE__, fn state -> state.requests end)
  end

  def force_error_responses(should_force \\ true) do
    Agent.update(__MODULE__, fn state ->
      %{state | force_error_responses: should_force}
    end)
  end

  defp send_error_response? do
    Agent.get(__MODULE__, fn state -> state.force_error_responses end)
  end
end
