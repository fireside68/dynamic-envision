defmodule DynamicEnvisionWeb.FeatureCase do
  @moduledoc """
  This module defines the test case to be used by
  integration tests using Wallaby.

  Such tests interact with the application via a web browser
  and verify the full user experience.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL

      alias DynamicEnvision.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import DynamicEnvisionWeb.FeatureCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(DynamicEnvision.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(DynamicEnvision.Repo, {:shared, self()})
    end

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(DynamicEnvision.Repo, self())
    {:ok, session} = Wallaby.start_session(metadata: metadata)
    {:ok, session: session}
  end
end
