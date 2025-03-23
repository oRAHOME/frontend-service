defmodule Mix.Tasks.FlyDeploy.Hot do
  use Mix.Task

  @shortdoc "Deploys the app to Fly.io with hot upgrades"

  def run(_) do
    IO.puts("🔥 Deploying with hot upgrades to Fly.io...")

    image = System.get_env("DEPLOY_IMAGE") || "registry.fly.io/mockdash:deployment-01JM35378N0QTHBH8T571T4DTP"

    # Ensure migrations are run before the upgrade
    run_migrations()

    # Deploy the new image using Fly.io Machines API
    deploy_hot_upgrade(image)

    IO.puts("✅ Hot upgrade deployment complete!")
  end

  defp run_migrations do
    IO.puts("🚀 Running database migrations...")
    System.cmd("fly", ["ssh", "console", "--command", "bin/mockdash eval MyApp.Release.migrate"])
  end

  defp deploy_hot_upgrade(image) do
    IO.puts("🔥 Applying hot upgrade with image: #{image}")
    System.cmd("fly", ["deploy", "--image", image, "--strategy", "immediate"])
  end
end
