defmodule TwitterClient do
  require Logger

  @twitter_client Application.get_env(:my_app, :twitter_client)

  def log_twitter_client do
    Logger.info("Using #{@twitter_client}")
  end
end
