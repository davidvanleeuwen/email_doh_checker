defmodule EmailDoHChecker.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      name: "EmailDoHChecker",
      app: :email_doh_checker,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  defp description do
    """
    Check the validity of email domains using DNS-over-HTTPS (DoH).
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["David van Leeuwen"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/davidvanleeuwen/email_doh_checker"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.34.2", only: :dev},
      {:httpoison, "~> 2.2"},
      {:jason, "~> 1.4"}
    ]
  end
end
