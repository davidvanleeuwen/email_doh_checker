defmodule EmailDoHChecker do
  @moduledoc """
  `EmailDoHChecker` is a module to check the validity of email domains using DNS-over-HTTPS (DoH).

  It allows verification of whether a domain resolves correctly or if it is being blocked by a DNS provider.
  """

  @doc """
  Checks if a domain or email's domain is valid by querying the specified DNS-over-HTTPS server.

  ## Parameters
  - `input`: The domain name or email address to check (e.g., "example.com" or "user@example.com").
  - `doh_server` (optional): The DoH server URL to use. Defaults to `https://dns.nextdns.io/`.

  ## Examples

      iex> EmailDoHChecker.valid?("example.com")
      true

      iex> EmailDoHChecker.valid?("user@example.com", "https://zero.dns0.eu/")
      true

      iex> EmailDoHChecker.valid?("blocked@blocked.example", "https://zero.dns0.eu/")
      false

  """
  @spec valid?(String.t(), String.t()) :: boolean()
  def valid?(
        input,
        doh_server \\ Application.get_env(
          :email_doh_checker,
          :doh_server,
          "https://dns.nextdns.io/"
        )
      ) do
    domain = extract_domain(input)

    case query_doh(domain, doh_server) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  @doc false
  defp extract_domain(input) do
    case String.split(input, "@") do
      [_user, domain] -> domain
      [domain] -> domain
    end
  end

  @doc false
  defp query_doh(domain, doh_server) do
    params =
      URI.encode_query(%{
        name: domain,
        type: "A"
      })

    url = "#{doh_server}?#{params}"

    case HTTPoison.get(url, [], follow_redirect: true) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_doh_response(body)

      {:ok, %HTTPoison.Response{status_code: status}} ->
        {:error, "HTTP request failed with status code: #{status}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{reason}"}
    end
  end

  @doc false
  defp parse_doh_response(body) do
    case Jason.decode(body) do
      {:ok, %{"Status" => 0} = decoded_body} ->
        if Map.get(decoded_body, "Answer", []) != [] do
          if blocked_by_nextdns?(decoded_body) do
            {:error, "Domain blocked by NextDNS"}
          else
            {:ok, "Domain resolved successfully"}
          end
        else
          {:error, "No records found for the domain (NODATA)"}
        end

      {:ok, %{"Status" => 3}} ->
        {:error, "Domain does not exist (NXDOMAIN)"}

      {:ok, %{"Status" => status}} ->
        {:error, "DNS query failed with status: #{status}"}

      {:error, _} ->
        {:error, "Failed to parse DoH response"}
    end
  end

  @doc false
  defp blocked_by_nextdns?(decoded_body) do
    Enum.any?(decoded_body["Additional"] || [], fn additional ->
      String.contains?(additional["data"] || "", "Blocked by NextDNS")
    end)
  end
end
