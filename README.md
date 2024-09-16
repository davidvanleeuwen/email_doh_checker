# EmailDoHChecker

[![Build Status](https://github.com/davidvanleeuwen/email_doh_checker/workflows/Test/badge.svg)](https://github.com/davidvanleeuwen/email_doh_checker/actions)
[![Coverage Status](https://coveralls.io/repos/github/davidvanleeuwen/email_doh_checker/badge.svg?branch=master)](https://coveralls.io/github/davidvanleeuwen/email_doh_checker?branch=master)
[![Module Version](https://img.shields.io/hexpm/v/email_doh_checker.svg)](https://hex.pm/packages/email_doh_checker)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/email_doh_checker/)
[![Total Download](https://img.shields.io/hexpm/dt/email_doh_checker.svg)](https://hex.pm/packages/email_doh_checker)
[![License](https://img.shields.io/hexpm/l/email_doh_checker.svg)](https://hex.pm/packages/email_doh_checker)
[![Last Updated](https://img.shields.io/github/last-commit/davidvanleeuwen/email_doh_checker.svg)](https://github.com/davidvanleeuwen/email_doh_checker/commits/master)

`EmailDoHChecker` is an Elixir library designed to check the validity of email domains using DNS-over-HTTPS (DoH). It allows you to verify whether a domain resolves correctly or is blocked by a DNS provider. Defaults to using the NextDNS DoH server, and can be used with a profile. Powerful in combination with your own configuration in the profile, such as blocking malicious domains.

## Features

- Validate domains and email addresses.
- Use DNS-over-HTTPS to perform domain resolution.
- Configurable DoH server URL.
- Easy configuration through DNS server profiles (e.g. NextDNS).

## Installation

Add `:email_doh_checker` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:email_doh_checker, "~> 0.1.0"}
  ]
end
```

Then, run mix deps.get to fetch and install the dependency.

## Configuration

You can configure the default DoH server URL in your application's configuration:

```elixir
# config/config.exs

config :email_doh_checker,
  doh_server: "https://dns.nextdns.io/"
```

## Usage

Here's an example usage of the EmailDoHChecker library:

```elixir
iex> EmailDoHChecker.valid?("example.com")
true

iex> EmailDoHChecker.valid?("user@example.com")
true

iex> EmailDoHChecker.valid?("blocked@blocked.example")
false
```

## With Ecto

You can also use the EmailDoHChecker library with Ecto to validate email domains in your Ecto schemas:

```elixir
def changeset(model, params) do
  model
  |> cast(attrs, [:email])
  |> update_change(:email, &String.trim/1)
  |> validate_email()
end

@email_regex ~r/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

defp validate_email(%{changes: %{email: email}} = changeset) do
  case Regex.match?(@email_regex, email) do
    true ->
      case EmailDoHChecker.valid?(email) do
        true -> add_error(changeset, :email, "forbidden_provider")
        false -> changeset
      end
    false -> add_error(changeset, :email, "invalid_format")
  end
end
defp validate_email(changeset), do: changeset
```

## Acknowledgements

This library is inspired by [Burnex](https://github.com/Betree/burnex) and [EmailChecker](https://github.com/maennchen/email_checker).

## License

This project is licensed under the MIT License - see the LICENSE file for details.
