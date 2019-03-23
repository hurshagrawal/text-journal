defmodule Quilt.Sms.Client do
  use HTTPoison.Base

  def process_request_url(url) do
    "https://api.twilio.com/2010-04-01/Accounts/#{account_sid()}" <> url
  end

  def process_response_body(body) do
    body
    |> Poison.decode!()
  end

  def process_request_headers(headers) do
    credentials = "#{account_sid()}:#{account_auth_token()}" |> Base.encode64()

    [
      {"Authorization", "Basic #{credentials}"} | headers
    ]
  end

  defp account_sid do
    Application.get_env(:quilt, :twilio_account_sid)
  end

  defp account_auth_token do
    Application.get_env(:quilt, :twilio_auth_token)
  end
end
