define :console do

  description "Jump into an interactive REPL console"

  options(inherit: false) do

  end

  run do
    Pry.config.prompt_name = "#{label} Console ".light_blue
    Pry.start
  end

  def support_method

  end
end
