define :console do

  description "Jump into an interactive REPL console"

  requirements :inherit do
    require 'colorize'

  end

  switches(inherit: false) do
    # option(:help, description: "display help")
  end

  run do
    Pry.config.prompt_name = "#{label} Console ".light_blue
    Pry.start
  end

  def support_method

  end
end
