defmodule Quilt.Images.Client do
  @doc """
  Given a URL that redirects to an image, it returns the final image
  URL. This allows us to send actual image URLs to consumers so they
  preview them correctly in Messages clients.
  """
  def get_resolved_url(url) when is_binary(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: status_code, headers: headers}}
      when status_code > 300 and status_code < 400 ->
        case get_location_header(headers) do
          [url] when is_binary(url) ->
            get_resolved_url(url)

          _ ->
            {:error, :no_location_header}
        end

      {:ok, %HTTPoison.Response{status_code: 200}} ->
        {:ok, url}

      reason ->
        {:error, reason}
    end
  end

  defp get_location_header(headers) do
    for {key, value} <- headers, String.downcase(key) == "location" do
      value
    end
  end
end
